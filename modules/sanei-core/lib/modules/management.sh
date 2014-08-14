#!/bin/bash

is_installed(){
    local what=$1
    if [[ -e "$TEMPLATE_ROOT$SANEI_DIR/.install.$what" ]]; then
	    return 0
    fi
    return 1
}

set_installed(){
    local what=$1
    local norun=$2
    local noinfo=$3
    mkdir -p "$TEMPLATE_ROOT$SANEI_DIR"
    touch "$TEMPLATE_ROOT$SANEI_DIR/.install.$what"
    if [[ -z $norun ]]; then
        sanei_update "$what"
    fi
    if [[ -z $noinfo ]]; then
        info "Set as installed: $what"
    fi
}

rm_installed(){
    local what=$1
    if [[ -f $TEMPLATE_ROOT$SANEI_DIR/.install.$what ]]; then
        rm $TEMPLATE_ROOT$SANEI_DIR/.install.$what
    fi
}

apt_install(){
    if [[ -z $SKIPAPT || $SKIPAPT -ne true ]]; then
        local packages="$1"
        local ppa="$2"
        local norecommends="$3"
        if [[ ! -z $ppa ]]; then
            add-apt-repository $(add_silent_opt) $ppa
            apt-get update
        fi
        if $norecommends; then
            norecommends="--no-install-recommends"
        fi
        if ! apt-get $(add_silent_opt) "$norecommends" install $packages; then
            return 1
        fi
    fi
}

is_apt_installed(){
    local package="$1"
    if $(dpkg -s "$package" 2&>/dev/null); then
        return 0
    else
        return 1
    fi
}

list_installed(){
    local dir=$1
    list_files $TEMPLATE_ROOT$SANEI_DIR | grep ".install." | sed s/.install.//
}

add_verbosity_opt(){
    local at_level=$1
    local param=$2
    if [[ -z $param ]]; then param="-v"; fi
    if [[ $VERBOSE -ge $at_level ]]; then
        echo $param
    fi
}
add_silent_opt(){
    local param=$1
    if [[ -z $param ]]; then param="-y"; fi
    if [[ $SILENT -ne true ]]; then
        echo $param
    fi
}
sanei_install_select(){
    local module
    dialog_selector_generate 'SELECT MODULES TO INSTALL' "Use this to mass install \n\
modules on the local system" "$(sanei_list_modules_with_status true)"
    retval=$?
    case $retval in
      $DIALOG_OK)
        for module in $(cat $tempfile); do
            if ! is_installed $(eval echo "$module"); then
                sanei_install $(eval echo "$module")
            fi
        done
        ;;
      $DIALOG_CANCEL)
        info "Cancelled."
        ;;
      $DIALOG_ESC)
        if test -s $tempfile ; then
          # cat $tempfile
          error "This shouldn't happen."
        else
          info "ESC pressed."
        fi
        ;;
    esac
}
sanei_install(){
    local module=$1

    if [[ ! -z $module ]]; then
        if [[ -d $SCRIPT_DIR/modules/$module ]]; then
            if is_installed "$module"; then
                if [[ ! $REINSTALL ]]; then
                    info "You already installed: $module. Skipping..."
                    return 1
                else
                    local re="RE"
                    rm_installed "$module"
                fi
            fi
            # (
            # )

            local module_for_export="${module//[+.-]/}" # interesting quirk - doesn't work with: +-.
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

            info "${LIGHTBLUE}WILL ${re}INSTALL: ${WHITE}$module${RESET}."

            if [[ -f $SCRIPT_DIR/modules/$module/question.sh ]]; then
                askbreak "$( $SCRIPT_DIR/modules/$module/question.sh ${@:2:${#@}} )"
            else
                askbreak "Are you sure this is what you want?"
            fi

            if [[ -f $SCRIPT_DIR/modules/$module/install.sh ]]; then
                sanei_invoke_module_script "$module" install ${@:2:${#@}}
                if ! is_installed $module; then
                    set_installed $module
                fi
            else
                set_installed $module
            fi
        else
            error "Module $module does not exist."
        fi
    else
        sanei_install_select
        #error "No module provided."
    fi
}
sanei_create_module_dir(){
    subpath=$1 # optional
    if [[ ! -z $LOCAL_MODULE_DIR ]]; then
        mkdir -p "$LOCAL_MODULE_DIR$subpath"
    else
        error "Local module directory not defined."
        return 1
    fi
}
sanei_create_shared_module_dir(){
    subpath=$1 # optional
    if [[ ! -z $SHARED_MODULE_DIR ]]; then
        mkdir -p "$SHARED_MODULE_DIR$subpath"
    else
        error "Local module directory not defined."
        return 1
    fi
}
sanei_resolve_dependencies(){
    REAL_LOCAL_MODULE_DIR=$LOCAL_MODULE_DIR
    local module
    for module in "$@"
    do
        if ! is_installed "$module"; then
            if [[ $module == apt\:* ]]; then
                apt_package=$(echo "$module" | cut -c "5-")
                if ! is_apt_installed "$apt_package"; then
                    askbreak "In order to continue, apt package $apt_package needs to be installed."
                    if ! apt_install "$apt_package"; then
                        exit 1
                    fi
                fi
                # set_installed "$module"
            else
                info "In order to continue, $module needs to be installed."
                sanei_install "$module"
            fi
        fi
    done
    LOCAL_MODULE_DIR=$REAL_LOCAL_MODULE_DIR
}
sanei_update(){
    # TODO: change $TEMPLATE_ROOT for a local variable passed to the function
    # TODO: support multiple modules passed
    local module=$1

    if [[ ! -z $module && -d $SCRIPT_DIR/modules/$module ]]; then
        info "${LIGHTRED}UPDATING${RESET}: ${WHITE}${module}${RESET}."

        # TODO: add a function to do this also before invoking a module script
        store_memory_config MODULE "$module"
        store_memory_config MODULE_DIR "$SCRIPT_DIR/modules/$module"

        # /etc #
        # recursive linking #
        link_all_files_recursive $SCRIPT_DIR/modules/$module/etc $TEMPLATE_ROOT/etc $PADDING_SIZE

        # recursive copying and filling #
        fill_template_recursive $SCRIPT_DIR/modules/$module/etc-template $TEMPLATE_ROOT/etc $PADDING_SIZE

        # recursive copying #
        copy_all_files_recursive $SCRIPT_DIR/modules/$module/etc-copy $TEMPLATE_ROOT/etc $PADDING_SIZE

        # non-recursive linking of folders #
        link_all_dirs $SCRIPT_DIR/modules/$module/etc-link $TEMPLATE_ROOT/etc $PADDING_SIZE

        # others #
        # copy /usr if exists #
        copy_all_files_recursive $SCRIPT_DIR/modules/$module/usr $TEMPLATE_ROOT/usr $PADDING_SIZE

        # dotfiles
        fill_template_recursive $SCRIPT_DIR/modules/$module/root-template $TEMPLATE_ROOT$HOME_DIR $PADDING_SIZE

        if [[ -d $SCRIPT_DIR/modules/$module/root ]]; then
            if [[ "$HOME_DIR" == "/root" ]]; then
                link_all_files $SCRIPT_DIR/modules/$module/root $TEMPLATE_ROOT$HOME_DIR $PADDING_SIZE
                # link also folders #
                link_all_dirs $SCRIPT_DIR/modules/$module/root $TEMPLATE_ROOT$HOME_DIR $PADDING_SIZE
            else # if we're not using root - we don't want permissions problems
                copy_all_files_recursive $SCRIPT_DIR/modules/$module/root $TEMPLATE_ROOT$HOME_DIR $PADDING_SIZE
            fi
        fi

        if [[ -f $SCRIPT_DIR/modules/$module/post-update.sh ]]; then
            source $SCRIPT_DIR/modules/$module/post-update.sh
        fi

        if [ "$HOME_DIR" != "/root" ]; then
            if [[ "$PARENT_USERNAME" != "root" ]]; then
                chown -R "$PARENT_USERNAME:$PARENT_USERNAME" "$TEMPLATE_ROOT$HOME_DIR"
            # if logname 2&> /dev/null; then
            #     user=$(logname)
            #     # TODO: do this at the copying/linking level
            #     chown -R "$user:$user" "$TEMPLATE_ROOT$HOME_DIR"
            # elif [[ "$SUDO_USER" ]]; then
            #     user="$SUDO_USER"
            #     chown -R "$user:$user" "$TEMPLATE_ROOT$HOME_DIR"
            else
                error "Cannot find the real username (you didn't use sudo -s ?)."
            fi
        fi
    else
        error "No module provided or module ${WHITE}$module${RESET} doesn't exist."
    fi
}
sanei_updateall(){
    # TODO: change $TEMPLATE_ROOT for a local variable passed to the function
    local module
    for module in $(list_installed)
    do
        sanei_update $module
    done
}
sanei_override(){
    local setinstalled="$1"
    local process_all_containers="$2"
    local removeunselected="$3"
    local module

    if [[ ! -z process_all_containers ]]; then
        local containers=($(/usr/bin/lxc-ls -1))
    fi

    dialog_selector_generate 'MODULE OVERRIDE LIST' "Use this to override the installed \n\
modules on the local system" "$(sanei_list_modules_with_status true)"
    # dialog_selector_generate testa testa 'test test on'
    retval=$?
    case $retval in
      $DIALOG_OK)
        if [[ -z process_all_containers ]]; then
            if [[ -n removeunselected ]]; then
                sanei_clean_installed_modules
            fi
            for module in $(cat $tempfile); do
                    if [[ -z setinstalled ]]; then
                        set_installed $(eval echo "$module") norun noinfo # TODO FIX
                    else
                        set_installed $(eval echo "$module")
                    fi
            done
        else
            for container in ${containers[@]}
            do
                enter_container "$container"
                    if [[ -n removeunselected ]]; then
                        sanei_clean_installed_modules
                    fi
                    for module in $(cat $tempfile); do
                            if [[ -z setinstalled ]]; then
                                set_installed $(eval echo "$module") norun noinfo # TODO FIX
                            else
                                set_installed $(eval echo "$module")
                            fi
                    done
                exit_container
            done
        fi
        ;;
      $DIALOG_CANCEL)
        info "Cancelled."
        ;;
      $DIALOG_ESC)
        if test -s $tempfile ; then
          # cat $tempfile
          error "This shouldn't happen."
        else
          info "ESC pressed."
        fi
        ;;
    esac
}
sanei_list_modules(){
    list_dirs $SCRIPT_DIR/modules
}
sanei_list_modules_with_status(){
    local dialog_mode="$1"
    local module
    for module in $(sanei_list_modules); do
        if [[ $dialog_mode ]]; then
            printf "$module $(sanei_get_module_description $module) $(if is_installed $module; then printf on; else printf off; fi) "
        else
            echo $(if is_installed $module; then echo -e ${LIGHTBLUE}; else echo -e ${LIGHTRED}; fi) "$module" "${RESET}"
        fi
    done
}
sanei_clean_installed_modules(){
    local module
    for module in $(sanei_list_modules); do
        rm_installed $module
    done
}
sanei_get_module_description(){
    local module="$1"
    # TODO:
    printf "\"\""
}