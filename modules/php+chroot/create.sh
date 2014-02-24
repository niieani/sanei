#!/bin/bash
# @author: Seb Dangerfield
# @author: Bazyli Brzoska
# http://www.sebdangerfield.me.uk/?p=513 
# Created:   11/08/2011
# Modified:   07/01/2012
# Modified:   27/11/2012
# Modified:   12/07/2013

sanei_resolve_dependencies php+chroot apt:python

if [ -z $1 ]; then
	error "No domain name given"
	exit 1
fi
DOMAIN=$1
 
# check the domain is valid!
PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
	DOMAIN=$(echo $DOMAIN | tr '[A-Z]' '[a-z]')
	info "Creating hosting for: $DOMAIN"
else
	error "Invalid domain name"
	exit 1
fi

# Create a new user!
echo "Please specify the username prefix for this site:"
# TODO: Selector
read USERNAME_PREFIX
DOMAIN_SAFE="$(echo "${DOMAIN//./_}" | sed 's/\xd1\x8f/ya/;s/\xd1\x81/s/;s/\xd0\xbd/n/;s/\xd0\xbe/o/' | sed -e 's/[àâą]/a/g;s/[ęêệ]/e/g;s/[ć]/c/g;s/[ł]/l/g;s/[ń]/n/g;s/[ś]/s/g;s/[źż]/z/g;s/[ọõó]/o/g;s/[í,ì]/i/g' | tr -cd '\11\12\40-\176')"
USERNAME="${USERNAME_PREFIX}_${DOMAIN_SAFE}"
PUNY_DOMAIN=$(generate_punycode "$DOMAIN")

adduser "$USERNAME" --conf="$MODULE_DIR/config/adduser.chroot.conf"

save_website "$USERNAME_PREFIX" "$USERNAME" "$DOMAIN"

# Now we need to copy the virtual host template
CONFIG="$NGINX_CONFIG/$USERNAME.conf"
cp "$MODULE_DIR/templates/nginx.vhost.conf.template" "$CONFIG"
$SED -i "s/@@HOSTNAME@@/$DOMAIN/g" "$CONFIG"
$SED -i "s/@@USERNAME@@/$USERNAME/g" "$CONFIG"

FPMCONF="$PHP_INI_DIR/$USERNAME.conf"
cp "$MODULE_DIR/templates/pool.conf.template" "$FPMCONF"
$SED -i "s/@@USER@@/$USERNAME/g" "$FPMCONF"

#usermod -aG $USERNAME $WEB_SERVER_GROUP
#chmod g+rx $SRV_DIR/$HOME_DIR
chmod 600 "$CONFIG"

ln -s "$CONFIG" "$NGINX_SITES_ENABLED/$USERNAME.conf"

/bin/mknod -m 0666 $SRV_DIR/$USERNAME/dev/zero c 1 5
/bin/mknod -m 0666 $SRV_DIR/$USERNAME/dev/null c 1 3
/bin/mknod -m 0666 $SRV_DIR/$USERNAME/dev/random c 1 8
/bin/mknod -m 0444 $SRV_DIR/$USERNAME/dev/urandom c 1 9

# add /etc
cp -fv /etc/{host.conf,hostname,localtime,networks,nsswitch.conf,protocols,resolv.conf,services,sudoers} "$SRV_DIR/$USERNAME/etc"
# copy dereferrencing links
cp -Lr /etc/{pam.d,php5} "$SRV_DIR/$USERNAME/etc"
# copy with links
cp -r /etc/{alternatives} "$SRV_DIR/$USERNAME/etc"

# copy and fill
cp $MODULE_DIR/templates/{passwd,group,hosts} $SRV_DIR/$USERNAME/etc
echo "$USERNAME:x:$(id -u $USERNAME):$(id -g $USERNAME):$DOMAIN,,,:$SRV_DIR/$USERNAME:/bin/false" >> "$SRV_DIR/$USERNAME/etc/passwd"
echo "$USERNAME:x:$(id -g $USERNAME):www-data,sftp" >> "$SRV_DIR/$USERNAME/etc/group"

echo $PUNY_DOMAIN > "$SRV_DIR/$USERNAME/etc/hostname"
$SED -i "s/@@PUNY_DOMAIN@@/$PUNY_DOMAIN/g" "$SRV_DIR/$USERNAME/etc/hosts"

chown $USERNAME:$USERNAME "$SRV_DIR/$USERNAME" -R

ln -s /usr/local/sbin "$SRV_DIR/$USERNAME/sbin"
ln -s /usr/local/etc/ssmtp "$SRV_DIR/$USERNAME/etc/ssmtp"

# TODO: make sftp optional
usermod -G sftp "$USERNAME"
# this already happens via adduser
# usermod -s /bin/false "$USERNAME"

# adding permissions for nginx to be able to read files
adduser www-data "$USERNAME"

# extra security
chown root:root "$SRV_DIR/$USERNAME"
chmod 0755 "$SRV_DIR/$USERNAME"
mkdir -p "$SRV_DIR/$USERNAME/srv/$USERNAME"
chown root:$USERNAME "$SRV_DIR/$USERNAME/srv"
chown $USERNAME:$USERNAME "$SRV_DIR/$USERNAME/srv/$USERNAME"

# mount all the binds now
mount_website "$USERNAME"

# for sftp
# http://www.techrepublic.com/blog/opensource/chroot-users-with-openssh-an-easier-way-to-confine-users-to-their-home-directories/229
$NGINX_INIT reload
$PHP_FPM_INIT restart
 
info "Site created for $DOMAIN with PHP support."
