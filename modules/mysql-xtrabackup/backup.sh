# to be used in combination with obnam

non_default_setting_needed "MYSQL_BACKUP_DIR"
sanei_resolve_dependencies "mysql-server" "apt:dbconfig-common" "apt:rsync"
read_ini '/etc/mysql/debian.cnf' 'client'
# echo $INI__client__user

rm -rf "$MYSQL_BACKUP_DIR"
innobackupex --defaults-file=/etc/mysql/my.cnf --socket="$INI__client__socket" --user="$INI__client__user" --password="$INI__client__password" --no-timestamp --rsync $MYSQL_BACKUP_DIR

#client

#user
#password
#socket