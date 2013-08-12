#!/bin/bash

if [ -z $1 ]; then
        echo "No name given"
        exit 1
fi

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Really?"

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
