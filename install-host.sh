#!/bin/bash
git pull && git submodule init && git submodule update && git submodule status

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -s ${DIR}/root/.zshrc ~/.zshrc
ln -s ${DIR}/etc-hostonly/apparmor.d/lxc/lxc-chrooting /etc/apparmor.d/lxc/lxc-chrooting
