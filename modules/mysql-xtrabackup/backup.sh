# to be used in combination with obnam

resolve_settings "MYSQL_BACKUP_DIR"
sanei_resolve_dependencies "apt:rsync" # "mysql-server" "apt:dbconfig-common" 
read_ini '/etc/mysql/debian.cnf' 'client'
# echo $INI__client__user

rm -rf "$MYSQL_BACKUP_DIR"
innobackupex --defaults-file=/etc/mysql/my.cnf --socket="$INI__client__socket" --user="$INI__client__user" --password="$INI__client__password" --no-timestamp --rsync $MYSQL_BACKUP_DIR

#client

#user
#password
#socket