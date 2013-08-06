#!/bin/bash

source config.sh

echo loading functions...

backup_file(){
    local file=$1
    local backup=$2
    if [[ -z $backup ]]; then backup=$BACKUP_DIR; fi

    sourcedir=$(dirname `pwd`/$file)
    fullpath=$(echo $sourcedir/$(basename $file))
    now=`date +'%Y_%m_%d_(%H_%M)'`

    #if [[ -h $backup/$fullpath ]]; then rm -v $backup/$fullpath; fi
    if [[ -e $fullpath || -d $fullpath || -h $fullpath ]]; 
	then echo "Backing up!"; 
	mkdir -p $backup/$now$sourcedir;
	mv -v $file $backup/$now$fullpath;
    fi
}
link(){
    local source=$1
    local target=$2

    backup_file $target $backup
    #if [[ -h $target ]]; then rm -v $target; fi
    ln -v -nfs "${source}" "$target"
}
link_all_files(){
    local source=$1
    local target=$2
    (cd ${target}; find ${source} -maxdepth 1 -type f -printf "%P\n" | while read file; do link "$source/$file" "$file"; done)
}
link_all_files_recursive(){
    local source=$1
    local target=$2
#    local backup=$3
#    if [[ -z $backup ]]; then backup=$BACKUP_DIR; fi
    (cd ${target}; find ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -v -p "$dir"; done)
    (cd ${target}; find ${source} -type f -printf "%P\n" | while read file; do link "$source/$file" "$file"; done)
}
