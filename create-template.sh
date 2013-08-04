#!/bin/bash
CURDIR="$( cd `dirname "${BASH_SOURCE[0]}` && pwd )"
source CURDIR/functions.sh

if [[ ! -e /lxc ]]; then ln -s /var/lib/lxc /lxc; fi
lxc-create -t ubuntu -n template
echo "/shared shared none defaults,bind 0 0" >> /lxc/template/fstab

TEMPLATE_ROOT=/lxc/template/rootfs

# /shared in containers
mkdir ${TEMPLATE_ROOT}${DIR}
chmod 777 ${TEMPLATE_ROOT}${DIR}

# /etc
declare -a link_dir_files=(init default rsyslog.d)

for i in ${arr[@]}
do
    link_all_files_recursive ${DIR}/etc/$i ${TEMPLATE_ROOT}/etc/$i ${TEMPLATE_ROOT}/root/.backups/etc/$i
done

# dotfiles
link_all_files ${DIR}/root ${TEMPLATE_ROOT}/root

mv $TEMPLATE_ROOT/etc/apt ${DIR}/etc/apt-raring
ln -s ${DIR}/etc/apt-raring ${DIR}/etc/apt
ln -s ${DIR}/etc/apt $TEMPLATE_ROOT/etc/apt

#mkdir -p ${DIR}/etc/mysql
ln -s ${DIR}/etc/mysql ${TEMPLATE_ROOT}/etc/mysql

# remove default user
chroot ${TEMPLATE_ROOT} deluser ubuntu --remove-home


#link_all_files_recursive ${DIR}/etc/init ${TEMPLATE_ROOT}/etc/init ${TEMPLATE_ROOT}/root/.backups/etc/init
#link_all_files_recursive ${DIR}/etc/default ${TEMPLATE_ROOT}/etc/default ${TEMPLATE_ROOT}/root/.backups/etc/default
#link_all_files_recursive ${DIR}/etc/rsyslog.d ${TEMPLATE_ROOT}/etc/rsyslog.d ${TEMPLATE_ROOT}/root/.backups/etc/rsyslog.d

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#ln -s ${DIR}/root/.zshrc ~/.zshrc
#chsh -s /bin/zsh

#(cd /etc; find ${DIR}/etc-hostonly -mindepth 1 -depth -type d -printf "%P\n" | while read dir; do mkdir -p "$dir"; done)
#(cd /etc; find ${DIR}/etc-hostonly -type f -printf "%P\n" | while read file; do ln -s "${DIR}/etc-hostonly/$file" "$file"; done)

#ln -s ${DIR}/etc-hostonly/apparmor.d/lxc/* /etc/apparmor.d/lxc/
#ln -s ${DIR}/etc-hostonly/sysctl.d/* /etc/sysctl.d/
