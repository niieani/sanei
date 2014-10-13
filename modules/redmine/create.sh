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
echo "Please specify the USER_NAME prefix for this site:"
# TODO: Selector
read USER_NAME_PREFIX
DOMAIN_SAFE="$(echo "${DOMAIN//./_}" | sed 's/\xd1\x8f/ya/;s/\xd1\x81/s/;s/\xd0\xbd/n/;s/\xd0\xbe/o/' | sed -e 's/[àâą]/a/g;s/[ęêệ]/e/g;s/[ć]/c/g;s/[ł]/l/g;s/[ń]/n/g;s/[ś]/s/g;s/[źż]/z/g;s/[ọõó]/o/g;s/[í,ì]/i/g' | tr -cd '\11\12\40-\176')"
USER_NAME="${USER_NAME_PREFIX}_${DOMAIN_SAFE}"
PUNY_DOMAIN=$(generate_punycode "$DOMAIN")

mkdir -p "$LOCAL_MODULE_DIR/skel"
adduser "$USER_NAME" --conf="$MODULE_DIR/config/adduser.chroot.conf"

save_website "$USER_NAME_PREFIX" "$USER_NAME" "$DOMAIN"

# Now we need to copy the virtual host template
CONFIG="$NGINX_CONFIG/$USER_NAME.conf"
cp "$MODULE_DIR/templates/nginx.vhost.conf.template" "$CONFIG"
$SED -i "s/@@HOSTNAME@@/$PUNY_DOMAIN/g" "$CONFIG"
$SED -i "s/@@USER_NAME@@/$USER_NAME/g" "$CONFIG"

chmod 600 "$CONFIG"
ln -s "$CONFIG" "$NGINX_SITES_ENABLED/$USER_NAME.conf"

# adding permissions for nginx to be able to read files
adduser www-data "$USER_NAME"
adduser "$USER_NAME" rvm

# extra security
chown root:root "$SRV_DIR/$USER_NAME"
chmod 0755 "$SRV_DIR/$USER_NAME"
#mkdir -p "$SRV_DIR/$USER_NAME/srv/$USER_NAME"
#chown root:$USER_NAME "$SRV_DIR/$USER_NAME/srv"
#chown $USER_NAME:$USER_NAME "$SRV_DIR/$USER_NAME/srv/$USER_NAME"

# Now the actual installation
cd "/srv/$USER_NAME"
#su "$USER_NAME" -c "svn co http://svn.redmine.org/redmine/branches/2.5-stable srv"
sudo -H -u "$USER_NAME" svn co http://svn.redmine.org/redmine/branches/2.5-stable srv

cd "/srv/$USER_NAME/srv"

info "Proceed to configure your database at: /srv/$USER_NAME/srv/config/database.yml"
info "You may install additional plugins if you like at this time."
info "Press RETURN when ready to import the database"

read

sudo -H -u "$USER_NAME" mkdir public/plugin_assets
sudo -H -u "$USER_NAME" bundle install
sudo -H -u "$USER_NAME" bundle exec rake db:migrate RAILS_ENV="production"
sudo -H -u "$USER_NAME" bundle exec rake redmine:plugins RAILS_ENV="production"
sudo -H -u "$USER_NAME" bundle exec rake generate_secret_token RAILS_ENV="production"

sudo -H -u "$USER_NAME" touch /srv/$USER_NAME/srv/tmp/restart.txt

$NGINX_INIT reload

info "Redmine site created for $DOMAIN."
