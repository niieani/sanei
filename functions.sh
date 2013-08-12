#!/bin/bash

if [ ! -f $CURDIR/config.sh ]; then
    echo "No config file"
    exit 1
fi

source $CURDIR/config.sh

#echo loading functions...
now=`date +'%Y_%m_%d_(%H_%M)'`
space="|    |    |    |    |    |"
LIGHTGREEN="\033[1;32m"
LIGHTRED="\033[1;31m"
WHITE="\033[0;37m"
RESET="\033[0;00m"

asksure() {
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

askbreak() {
    if [[ -z $silent ]]; then
        local text=$1
        if ! asksure "$text"; then
            exit 1
        fi
    fi
}

is_installed() {
    local what=$1
    if [[ -e $TEMPLATE_ROOT/opt/.install.$what ]]; then
	return 0
    fi
    return 1
}

set_installed() {
    local what=$1
    local norun=$2
    touch $TEMPLATE_ROOT/opt/.install.$what
    if [[ -z $norun ]]; then source $CURDIR/create-template-links.sh; fi
    echo "Set as installed: $what"
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
    echo -e "Linking files in directory: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"
    (cd $target; find -L $source -maxdepth 1 -type f -printf "%P\n" | while read file; do link "$source/$file" "$target/$file" 5; done)
}
link_all_files_recursive(){
    local source=$1
    local target=$2
    echo -e "Linking files recursively in: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"
    (mkdir -v -p $target | sed "s/^/${space:0:5}/"; cd $target; find -L ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
    (cd $target; find -L $source -type f -printf "%P\n" | while read file; do link "$source/$file" "$target/$file" 5; done)
}
