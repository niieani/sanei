#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh

# /etc
declare -a link_dir_files=(init default ufw update-manager)

# /etc whole folders
declare -a link_dirs=(apt mysql)

if is_installed www; then
    link_dir_files+=('nginx')
    link_dir_files+=('php5')
fi

if is_installed observium-client; then
    link_dir_files+=('rsyslog.d')
    #link_dirs+=('snmp')
fi

if is_installed observium-server; then
    link_dir_files+=('xinetd.d')
fi

# common links
create_common_links(){
    INSTALLING="common-links"
    REINSTALL=true
    askbreak "Create common links for: $TEMPLATE_ROOT ?"
    
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

    set_installed common-links norun
}

# template-links
if is_installed template-links; then
    INSTALLING="template-links"
    REINSTALL=true
    askbreak "Create template links for: $TEMPLATE_ROOT ?"
    
    #source $CURDIR/create-common-links.sh
    create_common_links
    
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

# host-links
if is_installed host-links; then
    INSTALLING="host-links"
    REINSTALL=true
    askbreak "Create host links?"
    
    link_all_files_recursive ${DIR}/etc-hostonly /etc
    
    # dotfiles & others
    link ${DIR}/root/.byobu ~/.byobu
    
    #source $CURDIR/create-common-links.sh
    create_common_links
    
    set_installed host-links norun
fi

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
    fill_template_recursive $DIR/root/observium-client/etc-template $TEMPLATE_ROOT/etc

    if is_installed observium-client-via-ssh; then
        fill_template_recursive $DIR/root/observium-client-via-ssh/etc-template $TEMPLATE_ROOT/etc
    fi
fi

if is_installed observium-server
then
    fill_template_recursive $DIR/root/observium/etc-template $TEMPLATE_ROOT/etc
    link_all_files_recursive $DIR/root/observium/etc $TEMPLATE_ROOT/etc
fi

if is_installed ssh
then
    fill_template_recursive $DIR/root/ssh/etc-template $TEMPLATE_ROOT/etc
fi
