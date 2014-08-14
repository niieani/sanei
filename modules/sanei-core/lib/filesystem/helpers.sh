#!/bin/bash
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
recreate_dir_structure(){
    local source=$1
    local target=$2
    if [[ -d $source ]]; then
        (
            mkdir -v -p "$target" | sed "s/^/${space:0:5}/"
            cd "$target"
            list_dirs_recursive "$source" | while read dir; do mkdir -p "$dir"; done
        )
    else
        return 1
    fi
}
link(){
    local source=$1
    local target=$2
    local padding=$3
    local newpadding=$(( $padding + 5 ))

    if [[ ! $source == *.gitignore ]];
    then
        if [[ $VERBOSE -ge 1 ]]; then info "${space:0:$padding}Linking: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
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
        (cd $target; list_files "$source" | while read file; do link "$source/$file" "$target/$file" 5; done)
    fi
}
link_all_files_recursive(){
    local source=$1
    local target=$2
    if [[ -d $source ]]; then
        if [[ $VERBOSE -ge 1 ]]; then info "Linking files recursively in: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
        recreate_dir_structure "$source" "$target"
        # (mkdir -v -p $target | sed "s/^/${space:0:5}/"; cd $target; find -L ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
        (
            cd $target
            list_files_recursive "$source" | while read file; do link "$source/$file" "$target/$file" 5; done
        )
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
        backup_file "$target" "" $newpadding
        cp -a "$source" "$target"

	if [[ ! -h $source ]]; then
            for key in ${!ConfigArr[@]}; do
                # debug:
	        	# echo "s/@@${key}@@/${ConfigArr[$key]}/g"
			    # escape
			    newOutput=$(echo ${ConfigArr[$key]} | sed -e 's/[\/&]/\\&/g')
		        sed -i "s/@@${key}@@/${newOutput}/g" "$target"
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
        if [[ $VERBOSE -ge 1 ]]; then info "Copying & filling files recursively in: ${LIGHTGREEN}${source} ${LIGHTRED}=> ${WHITE}${target}${RESET}"; fi
        cleanup "$target"
        recreate_dir_structure "$source" "$target"
        # (mkdir -v -p $target | sed "s/^/${space:0:$newpadding}/"; cd $target; find -L ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
        #  find -L $source -type f -printf "%P\n"
        (
            cd $target
            # echo "$source/$file" => "$target/$file";
            list_files_recursive "$source" | while read file; do fill_template "$source/$file" "$target/$file" $padding; done
        )
    fi
}