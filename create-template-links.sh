#!/bin/bash

if [ ! -z $1 ]; then
	TEMPLATE_ROOT=$1
fi

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh

if is_installed template-links; then

askbreak "Create template links for: $TEMPLATE_ROOT ?"

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

set_installed template-links norun

fi
