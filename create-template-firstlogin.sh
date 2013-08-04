#!/bin/bash
CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
#source $CURDIR/functions.sh

sed -ie '$d' ~/.bash_profile
apt-get -y install zsh htop mc software-properties-common
chsh -s /bin/zsh
logout
