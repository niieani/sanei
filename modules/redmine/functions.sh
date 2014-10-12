# Modify the following to match your system
NGINX_CONFIG='/etc/nginx/sites-available'
NGINX_SITES_ENABLED='/etc/nginx/sites-enabled'
WEB_SERVER_GROUP='www-data'
NGINX_INIT='/etc/init.d/nginx'
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