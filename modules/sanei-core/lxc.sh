case "$1" in
    "create" )
        #REINSTALL=true
        #__SPECIAL=true
        sanei_invoke_module_script lxc-template create ${@:2:${#@}}
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