# if [[ ! is_special_module_runtime ]]; then
#     info "Try: sanei lxc create NAME"
#     exit 1
# fi

if [ -z $1 ]; then
    echo "No name given"
    exit 1
fi

askbreak "Really create $1?"

sanei_resolve_dependencies "lxc-host"

TEMPLATE_NAME=$1

if [[ ! -e /lxc ]]; then ln -v -s /var/lib/lxc /lxc; fi
lxc-create -t ubuntu -n $TEMPLATE_NAME --packages "software-properties-common,ufw,wget,dialog,zsh,htop,mc" --user root --password "" # -b "$PARENT_USERNAME" 
echo "/shared shared none defaults,bind 0 0" >> /lxc/$TEMPLATE_NAME/fstab

# on the host
set_installed lxc-template

# chroot to the container
enter_container $TEMPLATE_NAME

	# /shared in containers
	mkdir -v "${TEMPLATE_ROOT}${SCRIPT_DIR}"
	chmod 777 "${TEMPLATE_ROOT}${SCRIPT_DIR}"

	## remove default user (off for not created -- root only))
	# chroot $TEMPLATE_ROOT deluser ubuntu
	# --remove-home
	# rm -rf $TEMPLATE_ROOT/home/ubuntu

	chroot "$TEMPLATE_ROOT" apt-get --force-yes --purge -y remove openssh-server
	chroot "$TEMPLATE_ROOT" apt-get --force-yes -y install software-properties-common ufw wget dialog zsh htop mc
	chroot "$TEMPLATE_ROOT" ufw allow lxc-net
	chroot "$TEMPLATE_ROOT" ufw enable
    chroot "$TEMPLATE_ROOT" chsh root -s /bin/zsh

	# echo "bash $SCRIPT_DIR/modules/lxc-template/firstlogin.sh" >> $TEMPLATE_ROOT/root/.bash_profile

	# apt first time
	if [[ ! -d "$SHARED_MODULE_DIR/apt-$DISTRO" ]]; then  # TODO: ? && ! -h $TEMPLATE_ROOT/etc/apt
		mv -v "$TEMPLATE_ROOT/etc/apt" "$SHARED_MODULE_DIR/apt-$DISTRO"; 
	fi # else rm -vrf $TEMPLATE_ROOT/etc/apt; fi
	if [[ ! -e "$TEMPLATE_ROOT/etc/apt" ]]; then 
		link "$SHARED_MODULE_DIR/apt-$DISTRO" "$TEMPLATE_ROOT/etc/apt"; 
	fi

	# old version
	# apt first time
	# if [[ ! -e $SCRIPT_DIR/modules/lxc-container/etc-link/apt-$DISTRO ]]; then  # TODO: ? && ! -h $TEMPLATE_ROOT/etc/apt
	# 	mv -v $TEMPLATE_ROOT/etc/apt $SCRIPT_DIR/modules/lxc-container/etc-link/apt-$DISTRO; 
	# fi # else rm -vrf $TEMPLATE_ROOT/etc/apt; fi
	# if [[ ! -e $SCRIPT_DIR/modules/lxc-container/etc-link/apt ]]; then 
	# 	link $SCRIPT_DIR/modules/lxc-container/etc-link/apt-$DISTRO $SCRIPT_DIR/modules/lxc-container/etc/apt; 
	# fi

	link $SCRIPT_DIR/sanei $TEMPLATE_ROOT/usr/bin/sanei
	link $SCRIPT_DIR/sanei $TEMPLATE_ROOT/usr/bin/sanmod
	
	# inside of the new template
	# set_installed lxc-common
	set_installed dotfiles # we don't want to run the install inside a container
	sanei_resolve_dependencies lxc-common lxc-container xterm-screen

exit_container