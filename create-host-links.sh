#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Create host links?"

# dotfiles & others
link_all_files_recursive ${DIR}/etc-hostonly /etc

source $CURDIR/create-common-links.sh

#link_all_files ${DIR}/root ~/
link ${DIR}/root/.byobu ~/.byobu
