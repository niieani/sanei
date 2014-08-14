#!/bin/sh

# TODO: perhaps this isn't he most fortunate place for parsing the arguments
#parse_arguments "-v|--verbose)VERBOSE;I" "-r|--reinstall)REINSTALL;B" "--skip-apt)SKIPAPT;B" "-s|--silent)SILENT;B" -- "${@:+$@}"
parse_arguments "-v|--verbose)VERBOSE;I" "-*)UNSUPPORTED;B" -- "${@:+$@}"

# load configuration and save to a variable
if [[ -z $CONFIG ]]; then
    ( set -o posix ; set ) >/tmp/variables.before
    for file in $SCRIPT_DIR/config/* ; do
        if [ -f "$file" ] ; then
            if [[ $VERBOSE -gt 4 ]]; then info "Loading config: $file"; fi
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
            if [[ $VERBOSE -gt 4 ]]; then info "Loading local config: $file"; fi
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
