#!/bin/bash
# TODO: static folder path

find /opt/sanei/obnam -type f -name '*.conf' | parallel --gnu $MODULE_DIR/backup.sh
if [[ $? -gt 0 ]]; then
	echo "$? jobs are still running or failed."
fi

# lockdir=/tmp/obnam-backup.lock
# if mkdir "$lockdir"
# then    # directory did not exist, but was created successfully
# 	backup_list=($(find /opt/sanei/obnam -type f -name '*.conf'))
# 	obnam=/usr/bin/obnam
# 	for backup_job in ${backup_list[@]}
# 	do
# 		echo "$backup_job"
# 	    if $obnam --config="$backup_job" backup; then
# 	    	$obnam --config="$backup_job" forget
# 	    fi
# 	done
# 	rmdir "$lockdir"
# else
# 	echo "Another backup in progress."
# 	exit 1
# fi