#!/bin/bash
CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"

if [ -z $1 ]; then
        echo "No name given"
        exit 1
fi

if [ ! -f $CURDIR/config.sh ]; then
        echo "No config file"
        exit 1
fi

read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

source $CURDIR/functions.sh

TEMPLATE_NAME=$1

if [[ ! -e /lxc ]]; then ln -v -s /var/lib/lxc /lxc; fi
lxc-create -t ubuntu -n $TEMPLATE_NAME
echo "/shared shared none defaults,bind 0 0" >> /lxc/$TEMPLATE_NAME/fstab

TEMPLATE_ROOT=/lxc/$TEMPLATE_NAME/rootfs
BACKUP_DIR=${TEMPLATE_ROOT}/root/.backups

# /shared in containers
mkdir -v ${TEMPLATE_ROOT}${DIR}
chmod 777 ${TEMPLATE_ROOT}${DIR}

source $CURDIR/create-template-links.sh

# remove default user
chroot ${TEMPLATE_ROOT} deluser ubuntu
# --remove-home
rm -rf ${TEMPLATE_ROOT}/home/ubuntu

echo "bash ${DIR}/create-template-firstlogin.sh" >> ${TEMPLATE_ROOT}/root/.bash_profile
