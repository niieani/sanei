#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Create common links for: $TEMPLATE_ROOT ?"

# /etc
declare -a link_dir_files=(init default rsyslog.d nginx php5 ufw xinetd.d)
# /etc whole folders
declare -a link_dirs=(apt mysql snmp)

# dotfiles
link_all_files ${DIR}/root ${TEMPLATE_ROOT}/root

# /etc
for i in ${link_dir_files[@]}
do
    if [[ -e ${DIR}/etc/$i ]]
    then
	link_all_files_recursive ${DIR}/etc/$i ${TEMPLATE_ROOT}/etc/$i
    fi;
done

# /etc whole folders
for i in ${link_dirs[@]}
do
    if [[ -e ${DIR}/etc/$i ]]
    then
	link ${DIR}/etc/$i ${TEMPLATE_ROOT}/etc/$i
    fi;
done
