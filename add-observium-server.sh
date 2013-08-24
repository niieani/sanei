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

set_installed observium-server

# allow syslogging from localhost
ufw allow from 127.0.0.1 app "Observium Syslog"
#ufw allow 677 # change for observium-server and fixme not to allow everybody, just the right IPs

# add su access ONLY to the hosts file to the user without repeating the password
# /etc/hosts 
echo "observium ALL=(root)NOPASSWD:$DIR/root/observium/add-host-via-ssh.sh *" > /etc/sudoers.d/observium
