#!/bin/bash
read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then

#CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh

if [[ ! -e /lxc ]]; then ln -v -s /var/lib/lxc /lxc; fi
lxc-create -t ubuntu -n template
echo "/shared shared none defaults,bind 0 0" >> /lxc/template/fstab

TEMPLATE_ROOT=/lxc/template/rootfs
BACKUP_DIR=${TEMPLATE_ROOT}/root/.backups

# /shared in containers
mkdir -v ${TEMPLATE_ROOT}${DIR}
chmod 777 ${TEMPLATE_ROOT}${DIR}

$CURDIR/create-template-links.sh

# remove default user
chroot ${TEMPLATE_ROOT} deluser ubuntu
# --remove-home
rm -rf ${TEMPLATE_ROOT}/home/ubuntu

echo "bash ${DIR}/create-template-firstlogin.sh" >> ${TEMPLATE_ROOT}/root/.bash_profile

    exit 1
fi