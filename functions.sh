#!/bin/bash

source config.sh

echo loading functions...
now=`date +'%Y_%m_%d_(%H_%M)'`
space="                                  "

backup_file(){
    local file=$1
    local backup=$2
    local padding=$3
    if [[ -z $backup ]]; then backup=$BACKUP_DIR; fi

    sourcedir=$(dirname `pwd`/$file)
    fullpath=$(echo $sourcedir/$(basename $file))

    #if [[ -h $backup/$fullpath ]]; then rm -v $backup/$fullpath; fi
    if [[ -e $fullpath || -d $fullpath || -h $fullpath ]];
	then 
	    echo "${space:0:$padding}Backing up: $fullpath";
	    mkdir -p $backup/$now$sourcedir | sed "s/^/${space:0:$padding}/";
	    mv $fullpath $backup/$now$fullpath | sed "s/^/${space:0:$padding}/";
    fi
}
link(){
    local source=$1
    local target=$2
    local padding=$3
    local newpadding=$(( $padding + 5 ))

    echo "${space:0:$padding}Linking: $source"
        backup_file $target "" $newpadding
	#if [[ -h $target ]]; then rm -v $target; fi
	ln -nfs "${source}" "$target" | sed "s/^/${space:0:$newpadding}/"
}
link_all_files(){
    local source=$1
    local target=$2
    echo "Linking files in directory: $source => $target"
    (cd $target; find -L $source -maxdepth 1 -type f -printf "%P\n" | while read file; do link "$source/$file" "$file" 5; done)
}
link_all_files_recursive(){
    local source=$1
    local target=$2
    echo "Linking files recursively in: $source => $target"
    (mkdir -p $target; cd $target; find -L ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
    (cd $target; find -L $source -type f -printf "%P\n" | while read file; do link "$source/$file" "$file" 5; done)
}
