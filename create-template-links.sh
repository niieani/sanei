#!/bin/bash
CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"

if [ ! -f $CURDIR/config.sh ]; then
        echo "No config file"
        exit 1
fi

read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

source $CURDIR/functions.sh

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
