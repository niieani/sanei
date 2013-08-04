#!/bin/bash
CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh

if [[ ! -e /lxc ]]; then ln -s /var/lib/lxc /lxc; fi
lxc-create -t ubuntu -n template
echo "/shared shared none defaults,bind 0 0" >> /lxc/template/fstab

TEMPLATE_ROOT=/lxc/template/rootfs

# /shared in containers
mkdir -v ${TEMPLATE_ROOT}${DIR}
chmod 777 ${TEMPLATE_ROOT}${DIR}

# /etc
declare -a link_dir_files=(init default rsyslog.d)

for i in ${link_dir_files[@]}
do
    link_all_files_recursive ${DIR}/etc/$i ${TEMPLATE_ROOT}/etc/$i ${TEMPLATE_ROOT}/root/.backups/etc/$i
done

# dotfiles
link_all_files ${DIR}/root ${TEMPLATE_ROOT}/root

if [[ ! -e ${DIR}/etc/apt-raring ]]; then mv -v $TEMPLATE_ROOT/etc/apt ${DIR}/etc/apt-raring; else rm -vrf $TEMPLATE_ROOT/etc/apt; fi
if [[ ! -e ${DIR}/etc/apt ]]; then ln -v -s ${DIR}/etc/apt-raring ${DIR}/etc/apt; fi
ln -v -s ${DIR}/etc/apt $TEMPLATE_ROOT/etc/apt

#mkdir -p ${DIR}/etc/mysql
ln -v -s ${DIR}/etc/mysql ${TEMPLATE_ROOT}/etc/mysql

# remove default user
chroot ${TEMPLATE_ROOT} deluser ubuntu
# --remove-home
rm -rf ${TEMPLATE_ROOT}/home/ubuntu

echo "bash ${DIR}/create-template-firstlogin.sh" >> ${TEMPLATE_ROOT}/root/.bash_profile

#chsh -s /bin/zsh
