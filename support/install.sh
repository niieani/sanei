#!/bin/bash
# to start the installation do this:
# wget -O - https://raw.github.com/niieani/sanei/edge/support/install.sh | bash

if [[ ! $(whoami) == "root" ]]; then
    echo "You need to be root in order to install SANEi."
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
apt-get install software-properties-common git ufw dialog

mkdir -p $SCRIPT_DIR

git clone https://github.com/niieani/sanei.git $SCRIPT_DIR
cd $SCRIPT_DIR
git submodule init && git submodule update && git submodule status

ln -s $SCRIPT_DIR/sanei /usr/bin/sanei
ln -s $SCRIPT_DIR/sanei /usr/bin/sanmod