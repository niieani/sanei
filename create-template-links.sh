#!/bin/bash
CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"

if [ ! -f $CURDIR/config.sh ]; then
        echo "No config file"
        exit 1
fi

if [ ! -z $1 ]; then
        #echo "Using template"
        #exit 1
	TEMPLATE_ROOT=$1
fi

source $CURDIR/functions.sh

echo "Create template links for: $TEMPLATE_ROOT ?"
if ! asksure; then
    exit 1
fi

# apt first time
if [[ ! -e ${DIR}/etc-containeronly/apt-raring ]]; then mv -v $TEMPLATE_ROOT/etc/apt ${DIR}/etc-containeronly/apt-raring; fi # else rm -vrf $TEMPLATE_ROOT/etc/apt; fi
if [[ ! -e ${DIR}/etc-containeronly/apt ]]; then link ${DIR}/etc-containeronly/apt-raring ${DIR}/etc/apt; fi

source $CURDIR/create-common-links.sh

# /etc
for i in ${link_dir_files[@]}
do
    if [[ -e ${DIR}/etc-containeronly/$i ]]
    then
	link_all_files_recursive ${DIR}/etc-containeronly/$i ${TEMPLATE_ROOT}/etc/$i
    fi;
done

# /etc whole folders
for i in ${link_dirs[@]}
do
    if [[ -e ${DIR}/etc-containeronly/$i ]]
    then
	link ${DIR}/etc-containeronly/$i ${TEMPLATE_ROOT}/etc/$i
    fi;
done
