#!/bin/bash

# to start the installation do this:
# wget -O - https://raw.github.com/niieani/lxc-shared/master/install-host.sh | bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}` && pwd )"
source $CURDIR/functions.sh

# start
apt-get update
apt-get -y install software-properties-common byobu zsh git htop mc ufw

# LXC
add-apt-repository ppa:ubuntu-lxc/daily
apt-get -y install lxc

# dotfiles & others
mkdir -p $DIR
git clone https://github.com/niieani/lxc-shared.git ${DIR}
(cd /shared; git submodule init && git submodule update && git submodule status)

link_all_files_recursive ${DIR}/etc-hostonly /etc /root/.backups

link_all_files ${DIR}/root ~/
ln -s ${DIR}/root/.byobu ~/.byobu
chsh -s /bin/zsh
