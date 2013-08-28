sanei_install_dependencies lxc-common

# LXC
add-apt-repository -y ppa:ubuntu-lxc/daily
apt-get install -y lxc

set_installed lxc-host