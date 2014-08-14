#!/bin/bash

generate_help(){
    # http://www.thelinuxdaily.com/2012/09/self-documenting-scripts/
    pfx="$1"
    file="$2"
    if [ "$pfx" = "" ]; then pfx='##' ; fi
    grep "^$pfx" "$file" | sed -e "s/^$pfx//" 1>&2 # -e "s/_FILE_/$me/"
}
print_config(){
    local index
    for index in ${!ConfigArr[*]}
    do
        echo "${LIGHTBLUE}$index${RESET}: ${WHITE}${ConfigArr["$index"]}${RESET}"
    done
}
is_special_module_runtime(){
    if [ -z $__SPECIAL ]; then
        error "You can't install this module this way. "
        return 1
    fi
}
