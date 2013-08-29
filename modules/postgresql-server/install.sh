apt-get $(add_silent_opt) install libpq-dev libpq5
echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get $(add_silent_opt) upgrade
apt-get $(add_silent_opt) -t $DISTRO install postgresql-common
apt-get install postgresql-9.2
apt-get $(add_silent_opt) autoremove
mkdir -p $SCRIPT_DIR/run/postgresql
chmod 42775 $SCRIPT_DIR/run/postgresql
chown postgres.postgres $SCRIPT_DIR/run/postgres
info "add password with \password root, exit with \quit"
sudo -u postgres createuser --superuser root
sudo -u postgres psql

set_installed postgresql-server