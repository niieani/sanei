sanei_resolve_dependencies lxc-common

# LXC
apt_install lxc ppa:ubuntu-lxc/daily

set_installed lxc-host

service apparmor restart