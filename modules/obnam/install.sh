non_default_setting_needed OBNAM_REPOSITORY
# TODO (in case of sftp)
sanei_install_dependencies ssh-key

apt_install obnam "ppa:chris-bigballofwax/obnam-ppa"
mkdir -p /opt/obnam

get_obnam_repository_details

# TODO:
if [[ $OBNAM_REPOSITORY == sftp\:* ]]; then
	echo "Enter your Backup User SSH password:"
    # repository_server=$(echo "$OBNAM_REPOSITORY" | cut -c "8-")
	ssh-copy-id "-p$repository_server_port $repository_server"
	ssh $repository_server -p$repository_server_port "mkdir -p $repository_server_path/$LOCAL_HOSTNAME"
else # local backup
	mkdir -p $OBNAM_REPOSITORY/$LOCAL_HOSTNAME
fi

set_installed obnam