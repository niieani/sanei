#!/bin/bash
# to start the installation do this:
# wget -O - https://raw.github.com/niieani/lxc-shared/master/install-lxc-host.sh | bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"

read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

if [[ -z $DIR ]]; then
    DIR=/shared
fi

# start
apt-get update
apt-get -y install software-properties-common byobu zsh git htop mc ufw

# LXC
add-apt-repository ppa:ubuntu-lxc/daily
apt-get install lxc

mkdir -p $DIR

git clone https://github.com/niieani/lxc-shared.git $DIR
cd $DIR
(git submodule init && git submodule update && git submodule status)

echo "$TIMEZONE" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

set_installed lxc-host #should create the links

chsh -s /bin/zsh
