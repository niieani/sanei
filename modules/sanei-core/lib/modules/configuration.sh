#!/bin/bash
store_memory_config(){
    local var=$1
    local def=$2
    export $var=$def
    ConfigArr["${var}"]="${def}"
}
store_config_file(){
    local var=$1
    local def=$2
    local path=$3
    mkdir -p $SCRIPT_DIR/config
    echo "$var=\"$def\"" > "${path}${var}"
    chmod 700 "${path}${var}"
    store_memory_config "$var" "$def"
}
store_local_config(){
    local var=$1
    local def=$2
    mkdir -p $TEMPLATE_ROOT$SANEI_DIR/.config
    store_config_file "$var" "$def" "$TEMPLATE_ROOT$SANEI_DIR/.config/"
}
store_shared_config(){
    local var=$1
    local def=$2
    mkdir -p $SCRIPT_DIR/config
    store_config_file "$var" "$def" "$SCRIPT_DIR/config/50-"
}
ask_for_config(){
    local var="$1"
    local input
    read input
    if [[ -z "$input" ]]; then
        return 1
    else
        store_shared_config "$var" "$input"
    fi
}
resolve_settings(){
    local error=false
    local var
    for var in "$@"
    do
        # echo "testing for resolve of $var"
        if is_empty_config "$var"; then
            info "You need to provide ${WHITE}${var}${RESET} first:"
            if ! ask_for_config "$var"; then
                error=true
            fi
        fi
    done
    if $error; then
        exit 1
    fi
}