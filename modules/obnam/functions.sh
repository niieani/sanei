get_obnam_repository_details(){
	[[ "$OBNAM_REPOSITORY" =~ sftp\:\/\/(.*)\:([0-9]*)(.*) ]]

	# TODO: doesn't work with default port (port must be explicit)
	if [[ ${BASH_REMATCH[1]} ]]; then
		repository_server=${BASH_REMATCH[1]}
		repository_server_port=${BASH_REMATCH[2]}
		repository_server_path=${BASH_REMATCH[3]}
	fi	
}