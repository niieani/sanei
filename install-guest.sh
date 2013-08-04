#!/bin/bash

DIR=/shared

link_all_files(){
    local source=$1
    local target=$2
    (cd ${target}; find ${source} -maxdepth 1 -type f -printf "%P\n" | while read file; do ln -s "${source}/$file" "$file"; done)
}
link_all_files_recursive(){
    local source=$1
    local target=$2
    local backup=$3
    (cd ${target}; find ${source} -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
    (cd ${target}; find ${source} -type f -printf "%P\n" | while read file; do if [[ -e $file ]]; then mkdir -p $backup/`dirname $file`; mv $file $backup/$file; fi; ln -s "${source}/$file" "$file"; done)
}

# start
apt-get update
apt-get -y install software-properties-common zsh git htop mc

# LXC
add-apt-repository ppa:ubuntu-lxc/daily
apt-get install lxc
if [[ ! -e /lxc ]]; then ln -s /var/lib/lxc /lxc; fi

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
