# TODO: convert the lock into a pidfile so we can actually check if it's still running or only a stale lock
backup_job=$1
lockdir=/tmp/obnam.$(basename $backup_job).lock
if mkdir "$lockdir"
then # directory did not exist and was created successfully
	echo "$backup_job"
    if /usr/bin/obnam --config="$backup_job" backup; then
    	/usr/bin/obnam --config="$backup_job" forget
    else
    	rmdir "$lockdir"
    	# failed, TODO: should report/mail this somewhere
    	exit 1 # return for a function
    fi
	rmdir "$lockdir"
	exit 0 # return for a function
else
	# TODO: if older than 2 days - stale lock - delete and continue
	echo "Another backup of $(basename $backup_job) is in progress."
	exit 1 # return for a function
fi