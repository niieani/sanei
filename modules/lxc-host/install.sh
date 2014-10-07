sanei_resolve_dependencies lxc-common dotfiles

# LXC
#apt_install "lxc" "ppa:ubuntu-lxc/daily"

ln -s /var/lib/lxc /lxc

# byobu & tmux # TODO: move
apt_install "byobu" "ppa:byobu/ppa"
#apt_install "tmux" "ppa:chris-reeves/tmux"

set_installed lxc-host

service apparmor restart