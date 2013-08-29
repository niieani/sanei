#!/bin/bash
# to start the installation do this:
# wget -O - https://raw.github.com/niieani/lxc-shared/master/support/install.sh | bash

if [[ ! $(whoami) == "root" ]]; then
    echo "You need to be root in order to install sanei."
    exit 1
fi

read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

if [[ -z $SCRIPT_DIR ]]; then
    SCRIPT_DIR=/shared
fi

# start
apt-get update
apt-get $(add_silent_opt) install software-properties-common byobu zsh git htop mc ufw dialog

mkdir -p $SCRIPT_DIR

git clone https://github.com/niieani/lxc-shared.git $SCRIPT_DIR
cd $SCRIPT_DIR
(git submodule init && git submodule update && git submodule status)

ln -s $SCRIPT_DIR/sanei /usr/bin/sanei

sanei install timezone

chsh -s /bin/zsh
