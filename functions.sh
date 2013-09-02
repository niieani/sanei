#!/bin/bash

# load argument loading
__IMPORT__BASE_PATH="$SCRIPT_DIR/vendor/bash-modules/main/bash-modules/src/bash-modules"
source $SCRIPT_DIR/vendor/bash-modules/main/bash-modules/src/import.sh arguments log
parse_arguments "-v|--verbose)VERBOSE;I" "-r|--reinstall)REINSTALL;B" -- "${@:+$@}"
# parse_arguments "-n|--name)NAME;S" -- "$@" || {
#   error "Cannot parse command line."
#   exit 1
# }
# info "Hello, $NAME!"

# echo "Arguments count: ${#ARGUMENTS[@]}."
# echo "Arguments: ${ARGUMENTS[0]:+${ARGUMENTS[@]}}."

# load configuration and save to a variable
if [[ -z $CONFIG ]]; then
    ( set -o posix ; set ) >/tmp/variables.before
    for file in $SCRIPT_DIR/config/* ; do
      if [ -f "$file" ] ; then
        if [[ $VERBOSE ]]; then info "Loading config: $file"; fi
        source "$file"
      fi
    done

    ## load shared overrides
    # for file in $SCRIPT_DIR/.config-shared/* ; do
    #   if [ -f "$file" ] ; then
    #     if [[ $VERBOSE ]]; then echo "Loading shared config: $file"; fi
    #     source "$file"
    #   fi
    # done

    # load local overrides
    for file in /opt/.config/* ; do
      if [ -f "$file" ] ; then
        if [[ $VERBOSE ]]; then info "Loading local config: $file"; fi
        source "$file"
      fi
    done

    unset file
    ( set -o posix ; set ) >/tmp/variables.after

    CONFIG=$(comm --nocheck-order -13 /tmp/variables.before /tmp/variables.after)
    rm /tmp/variables.before /tmp/variables.after

    # make it an assoc array
    declare -A ConfigArr
    while IFS= read -r ConfigLine; do
    	IFS='=' read -ra ThisConfig <<< "$ConfigLine"
    	ThisConfigTrim=${ThisConfig[1]#"'"}
    	ThisConfigTrim=${ThisConfigTrim%"'"}
    	ThisConfigTrim=$(echo $ThisConfigTrim | sed "s/'\\\'//g") # unescape
    	ConfigArr["${ThisConfig[0]}"]="$ThisConfigTrim"
    done <<< "$CONFIG"
fi

# globals
space="|    |    |    |    |    |"
LIGHTGREEN=$'\033[1;32m'
LIGHTBLUE=$'\033[1;34m'
LIGHTRED=$'\033[1;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
RED=$'\033[0;31m'
WHITE=$'\033[0;37m'
RESET=$'\033[0;00m'
PADDING_SIZE=5

asksure(){
    local text=$1
    echo -n "$text (Y/N)? "
    while read -r -n 1 answer; do
      if [[ $answer = [YyNn] ]]; then
        [[ $answer = [Yy] ]] && retval=0
        [[ $answer = [Nn] ]] && retval=1
        break
      fi
    done
    echo # just a final linefeed, optics...
    return $retval
}
askbreak(){
    if [[ -z $silent ]]; then
        local text=$1
        if ! asksure "$text"; then
            exit 1
        fi
    else
        echo "$text (Y)."
    fi
}
print_config(){
    for index in ${!ConfigArr[*]}
    do
        echo "${LIGHTBLUE}$index${RESET}: ${WHITE}${ConfigArr["$index"]}${RESET}"
    done
}
is_installed(){
    local what=$1
    if [[ -e $TEMPLATE_ROOT/opt/.install.$what ]]; then
	    return 0
    fi
    return 1
}
set_installed(){
    local what=$1
    local norun=$2
    local noinfo=$3
    touch $TEMPLATE_ROOT/opt/.install.$what
    if [[ -z $norun ]]; then
        #source $SCRIPT_DIR/create-links.sh
        sanei_update $what
    fi
    if [[ -z $noinfo ]]; then
        info "Set as installed: $what"
    fi
}
rm_installed(){
    local what=$1
    if [[ -f $TEMPLATE_ROOT/opt/.install.$what ]]; then
        rm $TEMPLATE_ROOT/opt/.install.$what
    fi
}
store_memory_config(){
    local var=$1
    local def=$2
    export $var=$def
    ConfigArr["${var}"]="${def}"
}
store_config_file(){
    local var=$1
    local def=$2
    local path=$3
    mkdir -p $SCRIPT_DIR/config
    echo "$var=\"$def\"" > "${path}${var}"
    chmod 700 "${path}${var}"
    store_memory_config "$var" "$def"
}
store_local_config(){
    local var=$1
    local def=$2
    mkdir -p $TEMPLATE_ROOT/opt/.config
    store_config_file "$var" "$def" "$TEMPLATE_ROOT/opt/.config/"
}
store_shared_config(){
    local var=$1
    local def=$2
    mkdir -p $SCRIPT_DIR/config
    store_config_file "$var" "$def" "$SCRIPT_DIR/config/50-"
}
apt_install(){
    local packages="$1"
    local ppa="$2"
    local norecommends="$3"
    if [[ ! -z $ppa ]]; then
        add-apt-repository $(add_silent_opt) $ppa
        apt-get update
    fi
    if $norecommends; then
        norecommends="--no-install-recommends"
    fi
    apt-get $(add_silent_opt) "$norecommends" install $packages
}
is_apt_installed(){
    local package="$1"
    if (dpkg -s "$package" >/dev/null); then
        return 0
    else
        return 1
    fi
}
backup_file(){
    local file=$1
    local backup=$2
    local padding=$3
    if [[ -z $backup ]]; then backup=$BACKUP_DIR; fi

    targetdir=$(dirname $file)
    fullpath=$(echo $targetdir/$(basename $file))

    if [[ -e $fullpath || -d $fullpath || -h $fullpath ]];
	then
	    # uncomment for verbose backup
	    if [[ $VERBOSE == 3 ]]; then echo "${space:0:$padding}Backing up: $fullpath => $backup/$TIME_NOW$targetdir"; fi
	    mkdir -p $backup/$TIME_NOW$targetdir | sed "s/^/${space:0:$padding}/";
	    mv $fullpath $backup/$TIME_NOW$fullpath | sed "s/^/${space:0:$padding}/";
    fi
}
list_dirs_recursive(){
    local dir=$1
    if [[ -d $dir ]];
    then
        find -L ${dir} -mindepth 1 -depth -type d -printf "%P\n" | sed '/^$/d' | sort
    fi
}
list_dirs(){
    local dir=$1
    if [[ -d $dir ]];
    then
        find -L ${dir} -maxdepth 1 -depth -type d -printf "%P\n" | sed '/^$/d' | sort
    fi
}
list_files(){
    local dir=$1
    if [[ -d $dir ]];
    then
        find -L ${dir} -maxdepth 1 -type f -printf "%P\n" | sed '/^$/d' | sort
    fi
}
list_installed(){
    local dir=$1
    list_files $TEMPLATE_ROOT/opt | grep ".install." | sed s/.install.//
}
link(){
    local source=$1
    local target=$2
    local padding=$3
    local newpadding=$(( $padding + 5 ))

    if [[ ! $source == *.gitignore ]]; 
    then
        if [[ $VERBOSE == 1 ]]; then info "${space:0:$padding}Linking: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
        backup_file $target "" $newpadding
        ln -nfs "$source" "$target" | sed "s/^/${space:0:$newpadding}/"
    fi
}
link_all_files(){
    local source=$1
    local target=$2
    if [[ -d $source ]]; then
        if [[ $VERBOSE == 1 ]]; then info "Linking files in directory: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
        (cd $target; find -L $source -maxdepth 1 -type f -printf "%P\n" | while read file; do link "$source/$file" "$target/$file" 5; done)
    fi
}
link_all_files_recursive(){
    local source=$1
    local target=$2
    if [[ -d $source ]]; then
        if [[ $VERBOSE == 1 ]]; then info "Linking files recursively in: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
        (mkdir -v -p $target | sed "s/^/${space:0:5}/"; cd $target; find -L ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
        (cd $target; find -L $source -type f -printf "%P\n" | while read file; do link "$source/$file" "$target/$file" 5; done)
    fi
}
link_all_dirs(){
    local source=$1
    local target=$2
    local padding=$3
    # non-recursive linking of folders #
    for to_link in $(list_dirs $source)
    do
        link $source/$to_link $target/$to_link | sed "s/^/${space:0:$padding}/"
    done
}
add_verbosity_opt(){
    local at_level=$1
    local param=$2
    if [[ -z $param ]]; then param="-v"; fi
    if [[ $VERBOSE == $at_level ]]; then
        echo $param
    fi
}
add_silent_opt(){
    local param=$1
    if [[ -z $param ]]; then param="-y"; fi
    if [[ $SILENT == true ]]; then
        echo $param
    fi
}
copy_all_files_recursive(){
    local source=$1
    local target=$2
    local padding=$3
    if [[ -d $source ]]; then
        cp $(add_verbosity_opt 1) -T -R $source $target | sed "s/^/${space:0:$padding}/"
    fi
}
fill_template(){
    local source=$1
    local target=$2
    local padding=$3
    local newpadding=$(( $padding + 5 ))

    if [[ ! $source == *.gitignore ]]; then
        if [[ $VERBOSE == 2 ]]; then info "${space:0:$padding}Copying: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
        backup_file $target "" $newpadding
        cp -a $source $target

	if [[ ! -h $source ]]; then
            for key in ${!ConfigArr[@]}; do
                # debug:
	        	#echo "s/@@${key}@@/${ConfigArr[$key]}/g"
			    # escape
			    newOutput=$(echo ${ConfigArr[$key]} | sed -e 's/[\/&]/\\&/g')
		        sed -i "s/@@${key}@@/${newOutput}/g" $target
		        #echo "ConfigArr[$key] = ${ConfigArr[$key]}"
            done
        fi
    fi
}
fill_template_recursive(){
    local source=$1
    local target=$2
    local padding=$3
    local newpadding=$(( $padding + 5 ))
    if [[ -d $source ]]; then
        if [[ $VERBOSE == 1 ]]; then info "Copying & filling files recursively in: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
        (mkdir -v -p $target | sed "s/^/${space:0:$newpadding}/"; cd $target; find -L ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
        (cd $target; find -L $source -type f -printf "%P\n" | while read file; do fill_template "$source/$file" "$target/$file" $padding; done)
    fi
}
enter_container(){
    local container=$1

    REAL_TEMPLATE_ROOT=$TEMPLATE_ROOT
    REAL_BACKUP_DIR=$BACKUP_DIR
    TEMPLATE_ROOT=/lxc/$container/rootfs
    BACKUP_DIR=$TEMPLATE_ROOT/root/.backups
    CONTAINER_NAME=$container
    info "Entered container ${LIGHTBLUE}$CONTAINER_NAME${RESET}, with root: ${WHITE}$TEMPLATE_ROOT${RESET}."
}
exit_container(){
    TEMPLATE_ROOT=$REAL_TEMPLATE_ROOT
    BACKUP_DIR=$REAL_BACKUP_DIR
    info "Exited container ${LIGHTBLUE}$CONTAINER_NAME${RESET}."
    unset CONTAINER_NAME
}
is_special_module_runtime(){
    if [ -z $__SPECIAL ]; then
        error "You can't install this module this way. "
        return 1
    fi
}
generate_passphrase() {
    # http://cl4ssic4l.wordpress.com/2011/05/12/generate-strong-password-inside-bash-shell/
    local l=$1
    [ "$l" == "" ] && l=20
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}
is_empty_config(){
    # http://stackoverflow.com/questions/228544/how-to-tell-if-a-string-is-not-defined-in-a-bash-shell-script
    local varname_to_test=$1
    if [ -z "${!varname_to_test}" ] && [ "${!varname_to_test+test}" = "test" ]; then
        return 0
    else
        return 1
    fi
}
non_default_setting_needed(){
    local error=false
    for var in "$@"
    do
        if is_empty_config "$var"; then
            error "You need to set ${WHITE}${var}${RESET} first."
            error=true
        fi
    done
    if $error; then
        exit 1
    fi
}
# dialog:
dialog_setup_vars(){
    : ${DIALOG=dialog}
    : ${DIALOG_OK=0}
    : ${DIALOG_CANCEL=1}
    : ${DIALOG_HELP=2}
    : ${DIALOG_EXTRA=3}
    : ${DIALOG_ITEM_HELP=4}
    : ${DIALOG_ESC=255}
}
dialog_setup_tempfile(){
    tempfile=$(tempfile 2>/dev/null) || tempfile=/tmp/test$$
    trap "rm -f $tempfile" 0 1 2 5 15
}
dialog_selector_generate(){
    dialog_setup_vars
    dialog_setup_tempfile
    local title=$1
    local text=$2
    local values=$3

    DIALOG_CMD="$DIALOG --backtitle "SANEi" --title '"$(echo $title)"' --checklist '"$(echo "$text \n\nPress SPACE to toggle a value on/off.")"' 20 50 10 $values 2> $tempfile"
    eval $DIALOG_CMD
    return $?
}

# sanei specific functions:
sanei_install(){
    local module=$1

    if [[ ! -z $module ]]; then
        if [[ -d $SCRIPT_DIR/modules/$module ]]; then
            if is_installed "$module"; then
                if [[ ! $REINSTALL ]]; then
                    info "You already installed: $module. Skipping..."
                    return 1
                else
                    local re="RE"
                fi
            fi

            #info "${LIGHTBLUE}WILL ${re}INSTALL: ${WHITE}$module.${RESET}"
            info "${LIGHTBLUE}WILL ${re}INSTALL: ${WHITE}$module.${RESET}"

            if [[ -f $SCRIPT_DIR/modules/$module/question.sh ]]; then
                askbreak "$( $SCRIPT_DIR/modules/$module/question.sh ${ARGUMENTS[@]:2:${#ARGUMENTS[@]}} )"
            else
                askbreak "Are you sure this is what you want?"
            fi

            if [[ -f $SCRIPT_DIR/modules/$module/install.sh ]]; then
                source $SCRIPT_DIR/modules/$module/install.sh "${ARGUMENTS[@]:2:${#ARGUMENTS[@]}}"
            else
                set_installed $module
            fi
        else
            error "Module $module does not exist."
        fi
    else
        error "No module provided."
    fi
}
sanei_install_dependencies(){
    for module in "$@"
    do
        if ! is_installed "$module"; then
            if [[ $module == apt\:* ]]; then
                apt_package=$(echo "$module" | cut -c "5-")
                if ! is_apt_installed "$apt_package"; then
                    info "In order to continue, apt package $module needs to be installed."
                    apt_install "$apt_package"
                fi
                # set_installed "$module"
            else
                info "In order to continue, $module needs to be installed."
                sanei_install "$module"
            fi
        fi
    done
}
sanei_update(){
    # TODO: change $TEMPLATE_ROOT for a local variable passed to the function
    local module=$1

    if [[ ! -z $module && -d $SCRIPT_DIR/modules/$module ]]; then
        info "${LIGHTRED}UPDATING${RESET}: ${WHITE}${module}${RESET}."

        # /etc #
        # recursive linking #
        link_all_files_recursive $SCRIPT_DIR/modules/$module/etc $TEMPLATE_ROOT/etc $PADDING_SIZE

        # recursive copying and filling #
        fill_template_recursive $SCRIPT_DIR/modules/$module/etc-template $TEMPLATE_ROOT/etc $PADDING_SIZE

        # recursive copying #
        copy_all_files_recursive $SCRIPT_DIR/modules/$module/etc-copy $TEMPLATE_ROOT/etc $PADDING_SIZE

        # non-recursive linking of folders #
        link_all_dirs $SCRIPT_DIR/modules/$module/etc-link $TEMPLATE_ROOT/etc $PADDING_SIZE

        # others #
        # copy /usr if exists #
        copy_all_files_recursive $SCRIPT_DIR/modules/$module/usr $TEMPLATE_ROOT/usr $PADDING_SIZE

        # dotfiles
        fill_template_recursive $SCRIPT_DIR/modules/$module/root-template $TEMPLATE_ROOT/root $PADDING_SIZE

        if [[ -d $SCRIPT_DIR/modules/$module/root ]]; then
            link_all_files $SCRIPT_DIR/modules/$module/root $TEMPLATE_ROOT/root $PADDING_SIZE
            # link also folders #
            link_all_dirs $SCRIPT_DIR/modules/$module/root $TEMPLATE_ROOT/root $PADDING_SIZE
        fi

        if [[ -f $SCRIPT_DIR/modules/$module/post-update.sh ]]; then
            source $SCRIPT_DIR/modules/$module/post-update.sh
        fi
    else
        error "No module provided or module doesn't exist."
    fi
}
sanei_updateall(){
    # TODO: change $TEMPLATE_ROOT for a local variable passed to the function
    for module in $(list_installed)
    do
        sanei_update $module
    done
}
sanei_updateall_containers(){
    # for each container that wants to have auto-updated links
    containers=($(/usr/bin/lxc-ls -1))

    for container in ${containers[@]}
    do
        enter_container $container
            #TEMPLATE_ROOT=/lxc/$container/rootfs
            sanei_updateall
        exit_container
    done
}
sanei_override(){
    dialog_selector_generate 'MODULE OVERRIDE LIST' "Use this to override the installed \n\
modules on the local system" "$(sanei_list_modules_with_status true)"
    # dialog_selector_generate testa testa 'test test on'
    retval=$?
    case $retval in
      $DIALOG_OK)
        sanei_clean_installed_modules
        for module in $(cat $tempfile); do
            set_installed $(eval echo $module) norun noinfo # TODO FIX
        done
        ;;
      $DIALOG_CANCEL)
        info "Cancelled."
        ;;
      $DIALOG_ESC)
        if test -s $tempfile ; then
          # cat $tempfile
          error "This shouldn't happen."
        else
          info "ESC pressed."
        fi
        ;;
    esac
}
sanei_list_modules(){
    list_dirs $SCRIPT_DIR/modules
}
sanei_list_modules_with_status(){
    local dialog_mode=$1
    for module in $(sanei_list_modules); do
        if [[ $dialog_mode ]]; then
            printf "$module $(sanei_get_module_description $module) $(if is_installed $module; then printf on; else printf off; fi) "
        else
            echo $(if is_installed $module; then echo -e ${LIGHTBLUE}; else echo -e ${LIGHTRED}; fi) "$module" "${RESET}"
        fi
    done
}
sanei_clean_installed_modules(){
    for module in $(sanei_list_modules); do
        rm_installed $module
    done
}
sanei_get_module_description(){
    # TODO:
    printf "\"\""
}