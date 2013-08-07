#!/bin/bash

read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh

# dotfiles & others
link_all_files_recursive ${DIR}/etc-hostonly /etc

source $CURDIR/create-common-links.sh

#link_all_files ${DIR}/root ~/
link ${DIR}/root/.byobu ~/.byobu
