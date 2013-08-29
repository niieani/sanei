# schedule
if [[ -z $1 ]]; then
	error "You need to provide a container name."
	exit 1
fi

non_default_setting_needed OBNAM_REPOSITORY
store_memory_config CONTAINER_NAME "$1"
sanei module gpg-key generate $CONTAINER_NAME

# store_memory_config CONTAINER_DIR "/var/lib/lxc/$CONTAINER_NAME"
fill_template $MODULE_DIR/templates/lxc-container.conf /opt/obnam/$CONTAINER_NAME.conf