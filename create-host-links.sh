#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh

if is_installed host-links; then

askbreak "Create host links?"

link_all_files_recursive ${DIR}/etc-hostonly /etc

# dotfiles & others
link ${DIR}/root/.byobu ~/.byobu

source $CURDIR/create-common-links.sh

set_installed host-links norun

fi