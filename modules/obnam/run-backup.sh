#!/bin/bash
# TODO: static folder path

# TODO: convert the lock into a pidfile so we can actually check if it's still running or only a stale lock
lockdir=/tmp/obnam-backup.lock
if mkdir "$lockdir"
then    # directory did not exist, but was created successfully
	backup_list=($(find /opt/sanei/obnam -type f -name '*.conf'))
	obnam=/usr/bin/obnam
	for backup_job in ${backup_list[@]}
	do
		echo "$backup_job"
	    if $obnam --config="$backup_job" backup; then
	    	$obnam --config="$backup_job" forget
	    fi
	done
	rmdir "$lockdir"
else
	echo "Another backup in progress."
	exit 1
fi