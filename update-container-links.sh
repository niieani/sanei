#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"

if [ ! -f $CURDIR/config.sh ]; then
    echo "No config file"
    exit 1
fi

source $CURDIR/functions.sh

echo "Really?"
if ! asksure; then
    exit 1
fi

# for each container that wants to have auto-updated links
containers=($(/usr/bin/lxc-ls -1))

for container in ${containers[@]}
do
    TEMPLATE_ROOT=/lxc/$container/rootfs;
    if [[ -e $TEMPLATE_ROOT/opt/.install.template-links ]]
    then
        #echo $TEMPLATE_ROOT/opt/.install.template-links;
        source $CURDIR/create-template-links.sh # | sed "s/^/${space:0:5}/
    fi;
done
