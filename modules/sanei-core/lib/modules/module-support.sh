#!/bin/bash
# sanei specific functions:
sanei_invoke_module_script(){
    # $1 module
    # $2 script
    # $@ arguments
    local MODULE_DIR
    local LOCAL_MODULE_DIR
    local SHARED_MODULE_DIR
    ((INVOKED_COUNT++))
    if [[ $1 && -d $SCRIPT_DIR/modules/$1 ]]; then
        if [[ -f $SCRIPT_DIR/modules/$1/$2.sh ]]; then
            if [[ -z $NO_SUBSHELL ]]; then
            ( # start a subshell
                # locally available variables
                MODULE="$1"
                OPERATION="$2"
                MODULE_DIR="$SCRIPT_DIR/modules/$MODULE"
                LOCAL_MODULE_DIR="$SANEI_DIR/$MODULE"
                SHARED_MODULE_DIR="$COMMON_DIR/$MODULE"
                if [[ -f $MODULE_DIR/functions.sh ]]; then
                    source $MODULE_DIR/functions.sh
                fi

                # TODO: deprecated:

                if [[ -f $MODULE_DIR/dependencies.sh ]]; then
                    source $MODULE_DIR/dependencies.sh
                fi
                # new system of dependencies:
                if [[ $OPERATION != "install" ]]; then
                    # (
                    # )
                    # TODO: this is duplicated code, fix me

                    local module_for_export="${MODULE//[+.-]/}"
                    local parsed_prefix="${module_for_export^^}_" # let's uppercase

                    eval export "${parsed_prefix}ENVVAR" "_"
                    eval export "${parsed_prefix}DEPENDENCIES" "_"

                    sanei_parsing_info $module "install" "${parsed_prefix}"

                    eval _settings="\${${parsed_prefix}ENVVAR[@]}_"
                    eval _dependencies="\${${parsed_prefix}DEPENDENCIES[@]}_"

                    if [[ $_settings != "_" ]]; then
                        eval resolve_settings "\${${parsed_prefix}ENVVAR[@]}" # ${VAR_ENVVAR[@]}
                    fi
                    if [[ $_dependencies != "_" ]]; then
                        eval sanei_resolve_dependencies "\${${parsed_prefix}DEPENDENCIES[@]}" #${VAR_DEPENDENCIES[@]}
                    fi
                    unset _settings
                    unset _dependencies
                    unset module_for_export
                    unset parsed_prefix

                    # eval resolve_settings "\${PARSED_${MODULE}_ENVVAR[@]}" # ${VAR_ENVVAR[@]}
                    # eval sanei_resolve_dependencies "\${PARSED_${MODULE}_DEPENDENCIES[@]}" #${VAR_DEPENDENCIES[@]}
                fi

                # "" at the end as we must pass a final empty argument not to break certain scripts
                source "$MODULE_DIR/$2.sh" "${@:3:${#@}}" "";
            )
            else
                source "$SCRIPT_DIR/modules/$1/$2.sh" "${@:3:${#@}}" "";
                unset NO_SUBSHELL
            fi
        else
            if [[ $2 ]]; then
                error "No operation $2 for module $1."
            fi
            echo "Available commands are:"
            list_files "$SCRIPT_DIR/modules/$1" | grep "\.sh$" | sed s/.sh$// | sed "s/^/  /"
        fi
    else
        return 1
    fi
}