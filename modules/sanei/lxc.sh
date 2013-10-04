case "$1" in
    "create" )
        REINSTALL=true
        __SPECIAL=true
        sanei_install lxc-template ${@:2:${#@}}
        ;;
    "updateall" )
        sanei_updateall_containers
        ;;
    * )
        echo "Available commands are:"
        echo "  lxc updateall"
        echo "  lxc create TEMPLATE_NAME"
        ;;
esac