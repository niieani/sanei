#!/bin/bash
backup_list=($(find /opt/obnam -type f -name '*.conf'))
obnam=/usr/bin/obnam
for backup_job in ${backup_list[@]}
do
	echo "$backup_job"
    if $obnam --config="$backup_job" backup; then
    	$obnam --config="$backup_job" forget
    fi
done