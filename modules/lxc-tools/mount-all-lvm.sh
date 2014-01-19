local containers=($(/usr/bin/lxc-ls -1))
for container in ${containers[@]}
do
	lvmvol=$(cat "/lxc/$container/config" | grep "lxc.rootfs" | cut -d "=" -f 2 | sed 's/[[:space:]]//g')
	mount "$lvmvol" "/lxc/$container/rootfs"
done