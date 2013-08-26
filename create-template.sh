#!/bin/bash

if [ -z $1 ]; then
        echo "No name given"
        exit 1
fi

TEMPLATE_NAME=$1

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Really create $TEMPLATE_NAME?"

if [[ ! -e /lxc ]]; then ln -v -s /var/lib/lxc /lxc; fi
lxc-create -t ubuntu -n $TEMPLATE_NAME
echo "/shared shared none defaults,bind 0 0" >> /lxc/$TEMPLATE_NAME/fstab

TEMPLATE_ROOT=/lxc/$TEMPLATE_NAME/rootfs
BACKUP_DIR=${TEMPLATE_ROOT}/root/.backups

# /shared in containers
mkdir -v ${TEMPLATE_ROOT}${SCRIPT_DIR}
chmod 777 ${TEMPLATE_ROOT}${SCRIPT_DIR}

# remove default user
chroot ${TEMPLATE_ROOT} deluser ubuntu
# --remove-home
rm -rf ${TEMPLATE_ROOT}/home/ubuntu

echo "bash $SCRIPT_DIR/create-template-firstlogin.sh" >> $TEMPLATE_ROOT/root/.bash_profile

# apt first time
if [[ ! -e $SCRIPT_DIR/etc-containeronly/apt-$DISTRO ]]; then mv -v $TEMPLATE_ROOT/etc/apt ${SCRIPT_DIR}/etc-containeronly/apt-$DISTRO; fi # else rm -vrf $TEMPLATE_ROOT/etc/apt; fi
if [[ ! -e $SCRIPT_DIR/etc-containeronly/apt ]]; then link $SCRIPT_DIR/etc-containeronly/apt-$DISTRO ${SCRIPT_DIR}/etc/apt; fi

set_installed template-links # should run the link creator
#source $CURDIR/create-template-links.sh
