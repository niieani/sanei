#!/bin/bash

# load argument loading
__IMPORT__BASE_PATH="$SCRIPT_DIR/vendor/bash-modules/main/bash-modules/src/bash-modules"
source $SCRIPT_DIR/vendor/bash-modules/main/bash-modules/src/import.sh arguments log
parse_arguments "-v|--verbose)VERBOSE;I" "-r|--reinstall)REINSTALL;B" "--skip-apt)SKIPAPT;B" "-s|--silent)SILENT;B" -- "${@:+$@}"
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
    for file in /opt/sanei/.config/* ; do
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

    # finally add the variable added at the beginning
    ConfigArr["SCRIPT_DIR"]="${SCRIPT_DIR}"
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
    if [[ $SILENT -eq true ]]; then
        local text=$1
        if ! asksure "$text"; then
            exit 1
        fi
    else
        echo "$text (Y)."
    fi
}
print_config(){
    local index
    for index in ${!ConfigArr[*]}
    do
        echo "${LIGHTBLUE}$index${RESET}: ${WHITE}${ConfigArr["$index"]}${RESET}"
    done
}
is_installed(){
    local what=$1
    if [[ -e "$TEMPLATE_ROOT$SANEI_DIR/.install.$what" ]]; then
	    return 0
    fi
    return 1
}
set_installed(){
    local what=$1
    local norun=$2
    local noinfo=$3
    mkdir -p "$TEMPLATE_ROOT$SANEI_DIR"
    touch "$TEMPLATE_ROOT$SANEI_DIR/.install.$what"
    if [[ -z $norun ]]; then
        sanei_update "$what"
    fi
    if [[ -z $noinfo ]]; then
        info "Set as installed: $what"
    fi
}
rm_installed(){
    local what=$1
    if [[ -f $TEMPLATE_ROOT$SANEI_DIR/.install.$what ]]; then
        rm $TEMPLATE_ROOT$SANEI_DIR/.install.$what
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
    mkdir -p $TEMPLATE_ROOT$SANEI_DIR/.config
    store_config_file "$var" "$def" "$TEMPLATE_ROOT$SANEI_DIR/.config/"
}
store_shared_config(){
    local var=$1
    local def=$2
    mkdir -p $SCRIPT_DIR/config
    store_config_file "$var" "$def" "$SCRIPT_DIR/config/50-"
}
apt_install(){
    if [[ -z $SKIPAPT || $SKIPAPT -ne true ]]; then
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
    fi
}
is_apt_installed(){
    local package="$1"
    if (dpkg -s "$package" >/dev/null); then
        return 0
    else
        return 1
    fi
}
create_directory_structure(){
    local filename=$1
    mkdir -p "$(dirname "$filename")"
}
backup_file(){
    local file=$1
    local backup=$2
    local padding=$3
    if [[ -z $backup ]]; then backup=$BACKUP_DIR; fi

    targetdir=$(dirname "$file")
    fullpath=$(echo "$targetdir/$(basename $file)")

    if [[ -e $fullpath || -d $fullpath || -h $fullpath ]];
	then
	    # uncomment for verbose backup
	    if [[ $VERBOSE == 3 ]]; then echo "${space:0:$padding}Backing up: $fullpath => $backup/$TIME_NOW$targetdir"; fi
	    mkdir -p "$backup/$TIME_NOW$targetdir" | sed "s/^/${space:0:$padding}/";
	    mv "$fullpath" "$backup/$TIME_NOW$fullpath" | sed "s/^/${space:0:$padding}/";
    fi
}
cleanup(){
    # TODO
    if [[ -h $target ]]; then
        rm "$target"
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
list_files_recursive(){
    local dir=$1
    if [[ -d $dir ]];
    then
        find -L ${dir} -type f -printf "%P\n" | sed '/^$/d' | sort
    fi
}
list_installed(){
    local dir=$1
    list_files $TEMPLATE_ROOT$SANEI_DIR | grep ".install." | sed s/.install.//
}
link(){
    local source=$1
    local target=$2
    local padding=$3
    local newpadding=$(( $padding + 5 ))

    if [[ ! $source == *.gitignore ]]; 
    then
        if [[ $VERBOSE == 1 ]]; then info "${space:0:$padding}Linking: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
        backup_file "$target" "" $newpadding
        # this shouldn't be necessary:
        if [[ -h "$target" ]]; then rm "$target"; fi
        # actual link:
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
    local to_link
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
    if [[ $SILENT -ne true ]]; then
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
    local key

    if [[ ! $source == *.gitignore ]]; then
        if [[ $VERBOSE == 2 ]]; then info "${space:0:$padding}Copying: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
        backup_file $target "" $newpadding
        cp -a $source $target

	if [[ ! -h $source ]]; then
            for key in ${!ConfigArr[@]}; do
                # debug:
	        	# echo "s/@@${key}@@/${ConfigArr[$key]}/g"
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
        cleanup "$target"
        (mkdir -v -p $target | sed "s/^/${space:0:$newpadding}/"; cd $target; find -L ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
        (cd $target; find -L $source -type f -printf "%P\n" | while read file; do fill_template "$source/$file" "$target/$file" $padding; done)
    fi
}
enter_container(){
    local container=$1

    REAL_TEMPLATE_ROOT=$TEMPLATE_ROOT
    REAL_BACKUP_DIR=$BACKUP_DIR
    REAL_HOME_DIR=$HOME_DIR
    TEMPLATE_ROOT=/lxc/$container/rootfs
    BACKUP_DIR=$TEMPLATE_ROOT/root/.backups
    # we always want $HOME of containers to be /root
    HOME_DIR=/root
    CONTAINER_NAME=$container
    info "Entered container ${LIGHTBLUE}$CONTAINER_NAME${RESET}, with root: ${WHITE}$TEMPLATE_ROOT${RESET}."
}
exit_container(){
    TEMPLATE_ROOT=$REAL_TEMPLATE_ROOT
    BACKUP_DIR=$REAL_BACKUP_DIR
    HOME_DIR=$REAL_HOME_DIR
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
ask_for_config(){
    local var=$1
    local input
    read input
    if [[ -z "$input" ]]; then
        return 1
    else
        store_shared_config "$var" "$input"
    fi
}
non_default_setting_needed(){
    local error=false
    local var
    for var in "$@"
    do
        if is_empty_config "$var"; then
            info "You need to provide ${WHITE}${var}${RESET} first:"
            if ! ask_for_config "$var"; then
                error=true
            fi
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
sanei_invoke_module_script(){
    # $1 module
    # $2 script
    # $@ arguments
    local MODULE_DIR
    local LOCAL_MODULE_DIR
    if [[ $1 && -d $SCRIPT_DIR/modules/$1 ]]; then
        if [[ -f $SCRIPT_DIR/modules/$1/$2.sh ]]; then
            ( # start a subshell
                # locally available variables
                MODULE="$1"
                MODULE_DIR="$SCRIPT_DIR/modules/$1"
                LOCAL_MODULE_DIR="$SANEI_DIR/$1"
                if [[ -f $MODULE_DIR/functions.sh ]]; then
                    source $MODULE_DIR/functions.sh
                fi
                if [[ -f $MODULE_DIR/dependencies.sh ]]; then
                    source $MODULE_DIR/dependencies.sh
                fi

                # "" at the end as we must pass a final empty argument not to break certain scripts
                source $MODULE_DIR/$2.sh "${@:3:${#@}}" ""
            )
        else
            if [[ $2 ]]; then
                error "No operation $2 for module $1."
            fi
            echo "Available commands are:"
            list_files "$SCRIPT_DIR/modules/$1" | grep "\.sh$" | sed s/.sh$// | sed "s/^/  /"
        fi
    fi
}
sanei_install_select(){
    local module
    dialog_selector_generate 'SELECT MODULES TO INSTALL' "Use this to mass install \n\
modules on the local system" "$(sanei_list_modules_with_status true)"
    retval=$?
    case $retval in
      $DIALOG_OK)
        for module in $(cat $tempfile); do
            if ! is_installed $(eval echo "$module"); then
                sanei_install $(eval echo "$module")
            fi
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
                    rm_installed "$module"
                fi
            fi

            info "${LIGHTBLUE}WILL ${re}INSTALL: ${WHITE}$module${RESET}."

            if [[ -f $SCRIPT_DIR/modules/$module/question.sh ]]; then
                # TODO: correct ARGUMENTS
                askbreak "$( $SCRIPT_DIR/modules/$module/question.sh ${ARGUMENTS[@]:2:${#ARGUMENTS[@]}} )"
            else
                askbreak "Are you sure this is what you want?"
            fi

            if [[ -f $SCRIPT_DIR/modules/$module/install.sh ]]; then
                # TODO: correct ARGUMENTS
                sanei_invoke_module_script "$module" install ${ARGUMENTS[@]:2:${#ARGUMENTS[@]}}
                if ! is_installed $module; then
                    set_installed $module
                fi
            else
                set_installed $module
            fi
        else
            error "Module $module does not exist."
        fi
    else
        sanei_install_select
        #error "No module provided."
    fi
}
sanei_create_module_dir(){
    subpath=$1 # optional
    if [[ ! -z $LOCAL_MODULE_DIR ]]; then
        mkdir -p $LOCAL_MODULE_DIR$subpath
    else
        error "Local module directory not defined."
        return 1
    fi
}
sanei_resolve_dependencies(){
    REAL_LOCAL_MODULE_DIR=$LOCAL_MODULE_DIR
    local module
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
    LOCAL_MODULE_DIR=$REAL_LOCAL_MODULE_DIR
}
sanei_update(){
    # TODO: change $TEMPLATE_ROOT for a local variable passed to the function
    # TODO: support multiple modules passed
    local module=$1

    if [[ ! -z $module && -d $SCRIPT_DIR/modules/$module ]]; then
        info "${LIGHTRED}UPDATING${RESET}: ${WHITE}${module}${RESET}."

        # TODO: add a function to do this also before invoking a module script
        store_memory_config MODULE "$module"
        store_memory_config MODULE_DIR "$SCRIPT_DIR/modules/$module"

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
        fill_template_recursive $SCRIPT_DIR/modules/$module/root-template $TEMPLATE_ROOT$HOME_DIR $PADDING_SIZE

        if [[ -d $SCRIPT_DIR/modules/$module/root ]]; then
            link_all_files $SCRIPT_DIR/modules/$module/root $TEMPLATE_ROOT$HOME_DIR $PADDING_SIZE
            # link also folders #
            link_all_dirs $SCRIPT_DIR/modules/$module/root $TEMPLATE_ROOT$HOME_DIR $PADDING_SIZE
        fi

        if [[ -f $SCRIPT_DIR/modules/$module/post-update.sh ]]; then
            source $SCRIPT_DIR/modules/$module/post-update.sh
        fi

        if [ "$HOME_DIR" != "/root" ]; then
            if logname; then
                user=$(logname)
                # TODO: do this at the copying/linking level
                chown -R "$user:$user" "$TEMPLATE_ROOT$HOME_DIR"
            else
                error "Cannot find the real username."
            fi
        fi
    else
        error "No module provided or module ${WHITE}$module${RESET} doesn't exist."
    fi
}
sanei_updateall(){
    # TODO: change $TEMPLATE_ROOT for a local variable passed to the function
    local module
    for module in $(list_installed)
    do
        sanei_update $module
    done
}
sanei_updateall_containers(){
    # for each container that wants to have auto-updated links
    local containers=($(/usr/bin/lxc-ls -1))

    for container in ${containers[@]}
    do
        enter_container $container
            #TEMPLATE_ROOT=/lxc/$container/rootfs
            sanei_updateall
        exit_container
    done
}
sanei_override(){
    local module

    dialog_selector_generate 'MODULE OVERRIDE LIST' "Use this to override the installed \n\
modules on the local system" "$(sanei_list_modules_with_status true)"
    # dialog_selector_generate testa testa 'test test on'
    retval=$?
    case $retval in
      $DIALOG_OK)
        sanei_clean_installed_modules
        for module in $(cat $tempfile); do
            set_installed $(eval echo "$module") norun noinfo # TODO FIX
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
    local module
    for module in $(sanei_list_modules); do
        if [[ $dialog_mode ]]; then
            printf "$module $(sanei_get_module_description $module) $(if is_installed $module; then printf on; else printf off; fi) "
        else
            echo $(if is_installed $module; then echo -e ${LIGHTBLUE}; else echo -e ${LIGHTRED}; fi) "$module" "${RESET}"
        fi
    done
}
sanei_clean_installed_modules(){
    local module
    for module in $(sanei_list_modules); do
        rm_installed $module
    done
}
sanei_get_module_description(){
    # TODO:
    printf "\"\""
}