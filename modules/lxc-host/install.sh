sanei_install_dependencies lxc-common

# LXC
add-apt-repository $(add_silent_opt) ppa:ubuntu-lxc/daily
apt-get $(add_silent_opt) install lxc

set_installed lxc-host