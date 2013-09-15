# $1 container name

# schedule
if [[ -z $1 ]]; then
	error "You need to provide a container name."
	exit 1
fi

non_default_setting_needed OBNAM_REPOSITORY
store_memory_config CONTAINER_NAME "$1"
if ! sanei_invoke_module_script gpg-key generate obnam_$CONTAINER_NAME; then
	error "Cannot continue."
	exit 1;
fi

store_memory_config GPG_KEY_ID $(cat "$GPG_KEY_ID_PATH/obnam_$CONTAINER_NAME")
fill_template $MODULE_DIR/templates/lxc-container.conf $LOCAL_MODULE_DIR/$CONTAINER_NAME.conf

info "Ready. If needed, make changes to $LOCAL_MODULE_DIR/$CONTAINER_NAME.conf and run: ${WHITE}sanei module obnam run-backup${RESET} to execute the backup."