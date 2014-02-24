#!/bin/bash
# @author: Seb Dangerfield
# http://www.sebdangerfield.me.uk/ 
# Created:   02/12/2012
 
if [ -z $1 ]; then
    echo "No username given"
    exit 1
fi
USERNAME=$1
 
# todo: support inputing domain name
# check the domain is valid!
# PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
# if [[ "$DOMAIN" =~ $PATTERN ]]; then
#     DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
#     info "Removing vhost for:" $DOMAIN
# else
#     error "invalid domain name"
#     exit 1 
# fi
 
# echo "What is the username for this site?"
# read USERNAME

unmount_website $USERNAME

deluser $USERNAME www-data
# Remove the user and their home directory
userdel -rf $USERNAME
# Delete the users group from the system
groupdel $USERNAME
 
# Delete the virtual host config
rm -f $NGINX_CONFIG/$DOMAIN.conf
rm -f $NGINX_SITES_ENABLED/$DOMAIN.conf
 
# Delete the php-fpm config
FPMCONF="$PHP_INI_DIR/$DOMAIN.conf"
rm -f $FPMCONF

rm_website $USERNAME
 
$NGINX_INIT reload
$PHP_FPM_INIT restart
 
info "Site removed for $DOMAIN."