local container=$1
lvmvol=$(cat "/lxc/$container/config" | grep "lxc.rootfs" | cut -d "=" -f 2 | sed 's/[[:space:]]//g')
mount "$lvmvol" "/lxc/$container/rootfs"