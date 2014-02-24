# Modify the following to match your system
NGINX_CONFIG='/etc/nginx/sites-available'
NGINX_SITES_ENABLED='/etc/nginx/sites-enabled'
PHP_INI_DIR='/etc/php5/fpm/pool.d'
WEB_SERVER_GROUP='www-data'
NGINX_INIT='/etc/init.d/nginx'
PHP_FPM_INIT='/etc/init.d/php5-fpm'
WEBSITES_DIR="$LOCAL_MODULE_DIR/websites"
SRV_DIR="/srv"
SED=$(which sed)

save_website(){
	user_prefix=$1
	username=$2
	domain=$3

	mkdir -p "$WEBSITES_DIR/$user_prefix"
	echo "$domain" > "$WEBSITES_DIR/$user_prefix/$username"
}
rm_website(){
	username=$1
	for website in $(list_files_recursive "$WEBSITES_DIR" | grep "$username")
	do
		rm -f $WEBSITES_DIR/$website
	done
}
mount_website(){
	username=$1
	if ! mount --bind /bin $SRV_DIR/$username/bin; then
		error "Please add 'lxc.aa_profile = lxc-container-chrooting' to the configuration file of this container."
		exit 1
	else
		mount --bind /lib $SRV_DIR/$username/lib
		mount --bind /lib64 $SRV_DIR/$username/lib64
		mount --bind /usr $SRV_DIR/$username/usr
		mount --bind $RUN_DIR $SRV_DIR/$username/run
	fi
}
unmount_website(){
	username=$1
	umount $SRV_DIR/$username/bin
	umount $SRV_DIR/$username/lib
	umount $SRV_DIR/$username/lib64
	umount $SRV_DIR/$username/usr
	umount $SRV_DIR/$username/run
}
correct_permissions_website(){
	username=$1
	chown -R "$username:$username" "$SRV_DIR/$username/srv"
	chown root:root "$SRV_DIR/$username"
	chmod 0755 "$SRV_DIR/$username"
	chown root:$username "$SRV_DIR/$username/srv"
}
generate_punycode(){
	domain=$1
	python -c "print unicode('$domain', 'utf8').encode('idna')"
}