#!/bin/bash
# TODO: static folder path

# TODO: convert the lock into a pidfile so we can actually check if it's still running or only a stale lock

function run_obnam_backup(){
	local backup_job=$1
	local lockdir=/tmp/obnam.$(basename $backup_job).lock
	if mkdir "$lockdir"
	then # directory did not exist and was created successfully
		echo "$backup_job"
	    if /usr/bin/obnam --config="$backup_job" backup; then
	    	/usr/bin/obnam --config="$backup_job" forget
	    else
	    	rmdir "$lockdir"
	    	# failed, TODO: should report/mail this somewhere
	    	exit 1
	    fi
		rmdir "$lockdir"
	else
		# TODO: if older than 2 days - stale lock - delete and continue
		echo "Another backup of $(basename $backup_job) is in progress."
		exit 1
	done
}

find /opt/sanei/obnam -type f -name '*.conf' | parallel --gnu run_obnam_backup
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