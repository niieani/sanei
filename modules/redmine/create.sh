echo "Please specify the domain name for Redmine:"
read DOMAIN

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
$SED -i "s/@@HOSTNAME@@/$PUNY_DOMAIN/g" "$CONFIG"
$SED -i "s/@@USERNAME@@/$USERNAME/g" "$CONFIG"

chmod 600 "$CONFIG"
ln -s "$CONFIG" "$NGINX_SITES_ENABLED/$USERNAME.conf"

# adding permissions for nginx to be able to read files
adduser www-data "$USERNAME"
adduser "$USERNAME" rvm

# extra security
chown root:root "$SRV_DIR/$USERNAME"
chmod 0755 "$SRV_DIR/$USERNAME"
mkdir -p "$SRV_DIR/$USERNAME/srv/$USERNAME"
chown root:$USERNAME "$SRV_DIR/$USERNAME/srv"
chown $USERNAME:$USERNAME "$SRV_DIR/$USERNAME/srv/$USERNAME"

# Now the actual installation
cd "/srv/$USERNAME"
su "$USERNAME" -c "svn co http://svn.redmine.org/redmine/branches/2.5-stable srv"

cd "/srv/$USERNAME/srv"

info "Proceed to configure your database at: /srv/$USERNAME/srv/config/database.yml"
info "You may install additional plugins if you like at this time."
info "Press RETURN when ready to import the database"

read

su "$USERNAME" -c "bundle exec rake db:migrate"
su "$USERNAME" -c "bundle exec rake redmine:plugins"
su "$USERNAME" -c "bundle exec rake generate_secret_token"

su "$USERNAME" -c "touch /srv/$USERNAME/srv/tmp/restart.txt"

$NGINX_INIT reload

info "Redmine site created for $DOMAIN."
