#!/bin/bash

DIR=/shared

link_all_files(){
    local source=$1
    local target=$2
    (cd ${target}; find ${source} -maxdepth 1 -type f -printf "%P\n" | while read file; do ln -v -s "${source}/$file" "$file"; done)
}
link_all_files_recursive(){
    local source=$1
    local target=$2
    local backup=$3
    (cd ${target}; find ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -v -p "$dir"; done)
    (cd ${target}; find ${source} -type f -printf "%P\n" | while read file; do if [[ -e $file ]]; then mkdir -p $backup/`dirname $file`; mv -v $file $backup/$file; fi; ln -v -s "${source}/$file" "$file"; done)
}
