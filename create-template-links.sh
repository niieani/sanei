#!/bin/bash

if [ ! -z $1 ]; then
        #echo "Using template"
        #exit 1
	TEMPLATE_ROOT=$1
fi

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
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

# custom links
if is_installed observium-client
then
    if is_installed www
    then
	link $DIR/root/observium-client/local-www $TEMPLATE_ROOT/opt/observium-client/local
    else
	link $DIR/root/observium-client/local-default $TEMPLATE_ROOT/opt/observium-client/local
    fi
fi

set_installed template-links norun
