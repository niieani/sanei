#!/bin/bash

# to start the installation do this:
# wget -O - https://raw.github.com/niieani/lxc-shared/master/install-host.sh | bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}` && pwd )"
source $CURDIR/functions.sh

# start
apt-get update
apt-get -y install software-properties-common byobu zsh git htop mc

# dotfiles & others
mkdir -p $DIR
git clone https://github.com/niieani/lxc-shared.git ${DIR}
(cd /shared; git submodule init && git submodule update && git submodule status)

link_all_files_recursive ${DIR}/etc-hostonly /etc /root/.backups

link_all_files ${DIR}/root ~/
chsh -s /bin/zsh




# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#ln -s ${DIR}/root/.zshrc ~/.zshrc
#chsh -s /bin/zsh

#(cd /etc; find ${DIR}/etc-hostonly -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
#(cd /etc; find ${DIR}/etc-hostonly -type f -printf "%P\n" | while read file; do ln -s "${DIR}/etc-hostonly/$file" "$file"; done)

#ln -s ${DIR}/etc-hostonly/apparmor.d/lxc/* /etc/apparmor.d/lxc/
#ln -s ${DIR}/etc-hostonly/sysctl.d/* /etc/sysctl.d/
