# :Subcommands: - list
#               - setshared [VAR] [VALUE]
#               - setlocal [VAR] [VALUE]
case "$1" in
    "list" )
        print_config | sort
        ;;
    "setshared" )
        if [[ ! -z "$2" ]]; then
            store_shared_config ${@:2:${#@}}
        fi
        ;;
    "setlocal" )
        if [[ ! -z "$2" ]]; then
            store_local_config ${@:2:${#@}}
        fi
        ;;
    * )
        echo "Available commands are:"
        echo "  config list"
        echo "  config setshared [VAR] [VALUE]"
        echo "  config setlocal [VAR] [VALUE]"
        ;;
esac