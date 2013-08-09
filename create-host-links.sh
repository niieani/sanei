#!/bin/bash
CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"

if [ ! -f $CURDIR/config.sh ]; then
        echo "No config file"
        exit 1
fi

echo "Create host links?"
if ! asksure; then
    exit 1
fi

source $CURDIR/functions.sh

# dotfiles & others
link_all_files_recursive ${DIR}/etc-hostonly /etc

source $CURDIR/create-common-links.sh

#link_all_files ${DIR}/root ~/
link ${DIR}/root/.byobu ~/.byobu
