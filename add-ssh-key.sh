#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Really?"

ssh-keygen -t rsa -C "$(whoami)@$(hostname)-$(date -I)" -N ""
ssh-copy-id "-p$SSH_PORT observium@$OBSERVIUM_SERVER"

set_installed ssh-key norun
