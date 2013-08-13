#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Really?"

apt-get -y install openssh-server

set_installed ssh
