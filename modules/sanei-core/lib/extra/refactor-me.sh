#!/bin/bash

# FIX THIS
is_special_module_runtime(){
    if [ -z $__SPECIAL ]; then
        error "You can't install this module this way. "
        return 1
    fi
}

is_empty_config(){
    # http://stackoverflow.com/questions/228544/how-to-tell-if-a-string-is-not-defined-in-a-bash-shell-script

    local varname_to_test="$1"
    # echo "testing for empty: $varname_to_test (${!varname_to_test})"
    # if [ -z "${!varname_to_test}" ] && [ "${!varname_to_test+test}" = "test" ]; then
    if [ -z "${!varname_to_test}" ]; then
        # echo "empty"
        return 0
    else
        # echo "not empty"
        return 1
    fi
}

sanei_automatic_selfupgrade(){
    if [[ -n $SANEI_AUTOMATIC_SELFPUSH ]]; then
        if [[ -n $(git status -s) ]]; then
            sanei_invoke_module_script sanei-selfupdate updateremote
        fi
    fi
    if [[ -n $SANEI_AUTOMATIC_SELFUPGRADE ]]; then
        sanei_invoke_module_script sanei-selfupdate updatelocal
    fi
}