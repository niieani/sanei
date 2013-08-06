#!/bin/bash

read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then

source $CURDIR/functions.sh

# dotfiles & others
link_all_files_recursive ${DIR}/etc-hostonly /etc
link_all_files ${DIR}/root ~/
link ${DIR}/root/.byobu ~/.byobu

    exit 1
fi