#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
INSTALLING="ssh-key"
askbreak "Really?"

ssh-keygen -t rsa -C "$(whoami)@$(hostname)-$(date -I)" -N ""

set_installed ssh-key norun
