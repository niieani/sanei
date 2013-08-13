#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Create common links for: $TEMPLATE_ROOT ?"

# /etc
declare -a link_dir_files=(init default ufw update-manager)

# /etc whole folders
declare -a link_dirs=(apt mysql snmp)

if is_installed www; then
    link_dir_files+=('nginx')
    link_dir_files+=('php5')
fi

if is_installed observium-client; then
    link_dir_files+=('rsyslog.d')
    link_dirs+=('snmp')
fi

if is_installed observium-server; then
    link_dir_files+=('xinetd.d')
fi

# dotfiles
link_all_files ${DIR}/root ${TEMPLATE_ROOT}/root

# /etc
for i in ${link_dir_files[@]}
do
    if [[ -e ${DIR}/etc/$i ]]; then
	link_all_files_recursive ${DIR}/etc/$i ${TEMPLATE_ROOT}/etc/$i
    fi;
done

# /etc whole folders
for i in ${link_dirs[@]}
do
    if [[ -e ${DIR}/etc/$i ]]; then
	link ${DIR}/etc/$i ${TEMPLATE_ROOT}/etc/$i
    fi;
done

# custom links
if is_installed observium-client
then
    if is_installed www; then
        link $DIR/root/observium-client/local-www $TEMPLATE_ROOT/opt/observium-client/local
    elif is_installed mysql; then
        link $DIR/root/observium-client/local-mysql $TEMPLATE_ROOT/opt/observium-client/local
    else
        link $DIR/root/observium-client/local-default $TEMPLATE_ROOT/opt/observium-client/local
    fi
fi

if is_installed observium-server
then
    fill_template_recursive $DIR/root/observium/etc-template $TEMPLATE_ROOT/etc
    link_all_files_recursive $DIR/root/observium/etc $TEMPLATE_ROOT/etc
fi
