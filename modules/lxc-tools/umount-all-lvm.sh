local containers=($(/usr/bin/lxc-ls -1))
for container in ${containers[@]}
do
	umount "/lxc/$container/rootfs"
done