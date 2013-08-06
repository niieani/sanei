#!/bin/bash
read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh

# /etc
declare -a link_dir_files=(init default rsyslog.d nginx php5 ufw xinetd.d)
# /etc whole folders
declare -a link_dirs=(apt mysql snmp)

# are we in a container or creating one?
if [[ -z $TEMPLATE_ROOT ]]
then
    TEMPLATE_ROOT="";
fi;

# dotfiles
link_all_files ${DIR}/root ${TEMPLATE_ROOT}/root

if [[ ! -e ${DIR}/etc/apt-raring ]]; then mv -v $TEMPLATE_ROOT/etc/apt ${DIR}/etc/apt-raring; else rm -vrf $TEMPLATE_ROOT/etc/apt; fi
if [[ ! -e ${DIR}/etc/apt ]]; then link ${DIR}/etc/apt-raring ${DIR}/etc/apt; fi

# /etc
for i in ${link_dir_files[@]}
do
    link_all_files_recursive ${DIR}/etc/$i ${TEMPLATE_ROOT}/etc/$i
done

# /etc whole folders
for i in ${link_dirs[@]}
do
    link ${DIR}/etc/$i ${TEMPLATE_ROOT}/etc/$i
done
