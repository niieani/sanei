#!/bin/bash

# load argument loading
__IMPORT__BASE_PATH="$CURDIR/vendor/bash-modules/main/bash-modules/src/bash-modules"
source $CURDIR/vendor/bash-modules/main/bash-modules/src/import.sh arguments log
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
    for file in $CURDIR/config/* ; do
      if [ -f "$file" ] ; then
        if [[ $VERBOSE ]]; then echo "Loading config: $file"; fi
        source "$file"
      fi
    done

    # load shared overrides
    for file in $SCRIPT_DIR/.config-shared/* ; do
      if [ -f "$file" ] ; then
        if [[ $VERBOSE ]]; then echo "Loading shared config: $file"; fi
        source "$file"
      fi
    done

    # load local overrides
    for file in /opt/.config/* ; do
      if [ -f "$file" ] ; then
        if [[ $VERBOSE ]]; then echo "Loading local config: $file"; fi
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

# variables
if [[ -z $now ]]; then now=`date +'%Y_%m_%d_(%H_%M)'`; fi
HOSTNAME=$(hostname --fqdn)
IP=$(ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

# globals
space="|    |    |    |    |    |"
LIGHTGREEN="\033[1;32m"
LIGHTBLUE="\033[1;34m"
LIGHTRED="\033[1;31m"
WHITE="\033[0;37m"
RESET="\033[0;00m"
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
        #source $CURDIR/create-links.sh
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
store_local_config(){
    local var=$1
    local def=$2
    mkdir -p $TEMPLATE_ROOT/opt/.config
    echo "$var=\"$def\"" > $TEMPLATE_ROOT/opt/.config/$var
    chmod 700 $TEMPLATE_ROOT/opt/.config/$var
    ConfigArr["${var}"]=${def}
}
store_shared_config(){
    local var=$1
    local def=$2
    mkdir -p $SCRIPT_DIR/.config-shared
    echo "$var=\"$def\"" > $SCRIPT_DIR/.config-shared/$var
    chmod 700 $SCRIPT_DIR/.config-shared/$var
    ConfigArr["${var}"]=${def}
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
	    #echo "${space:0:$padding}Backing up: $fullpath => $backup/$now$targetdir";
	    mkdir -p $backup/$now$targetdir | sed "s/^/${space:0:$padding}/";
	    mv $fullpath $backup/$now$fullpath | sed "s/^/${space:0:$padding}/";
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
        echo -e "${space:0:$padding}Linking: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"
        backup_file $target "" $newpadding
        ln -nfs "$source" "$target" | sed "s/^/${space:0:$newpadding}/"
    fi
}
link_all_files(){
    local source=$1
    local target=$2
    if [[ -d $source ]]; then
        echo -e "Linking files in directory: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"
        (cd $target; find -L $source -maxdepth 1 -type f -printf "%P\n" | while read file; do link "$source/$file" "$target/$file" 5; done)
    fi
}
link_all_files_recursive(){
    local source=$1
    local target=$2
    if [[ -d $source ]]; then
        echo -e "Linking files recursively in: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"
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
copy_all_files_recursive(){
    local source=$1
    local target=$2
    local padding=$3
    if [[ -d $source ]]; then
        cp -v -T -R $source $target | sed "s/^/${space:0:$padding}/"
    fi
}
fill_template(){
    local source=$1
    local target=$2
    local padding=$3
    local newpadding=$(( $padding + 5 ))

    if [[ ! $source == *.gitignore ]]; then
        echo -e "${space:0:$padding}Copying: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"
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
        echo -e "Copying & filling files recursively in: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"
        (mkdir -v -p $target | sed "s/^/${space:0:$newpadding}/"; cd $target; find -L ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
        (cd $target; find -L $source -type f -printf "%P\n" | while read file; do fill_template "$source/$file" "$target/$file" $padding; done)
    fi
}