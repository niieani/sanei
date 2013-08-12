#!/bin/bash
# from cron you can call like this: silent=y ./update-container-links.sh

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Really?"

# for each container that wants to have auto-updated links
containers=($(/usr/bin/lxc-ls -1))

for container in ${containers[@]}
do
    TEMPLATE_ROOT=/lxc/$container/rootfs;
    if is_installed template-links
    then
        source $CURDIR/create-template-links.sh # | sed "s/^/${space:0:5}/
    fi;
done
