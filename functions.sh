#!/bin/bash

source config.sh

echo loading functions...
now=`date +'%Y_%m_%d_(%H_%M)'`
space="|    |    |    |    |    |"

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
	echo "${space:0:$padding}Linking: $source => $target"
        backup_file $target "" $newpadding
	ln -nfs "$source" "$target" | sed "s/^/${space:0:$newpadding}/"
    fi
}
link_all_files(){
    local source=$1
    local target=$2
    echo "Linking files in directory: $source => $target"
    (cd $target; find -L $source -maxdepth 1 -type f -printf "%P\n" | while read file; do link "$source/$file" "$target/$file" 5; done)
}
link_all_files_recursive(){
    local source=$1
    local target=$2
    echo "Linking files recursively in: $source => $target"
    (mkdir -v -p $target | sed "s/^/${space:0:5}/"; cd $target; find -L ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
    (cd $target; find -L $source -type f -printf "%P\n" | while read file; do link "$source/$file" "$target/$file" 5; done)
}
