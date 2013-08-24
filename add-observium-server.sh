#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Really?"

#apt-get -y install openssh-server
echo "TODO: Actual installation."

# TODO (in home?):
#useradd -d /opt/observium -g www-data -M -s /bin/sh observium
echo "Password for the remote access user: "
passwd observium
ufw allow 677 #change for observium-server and fixme not to allow everybody, just the right IPs

set_installed observium-server
