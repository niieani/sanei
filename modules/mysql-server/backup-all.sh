resolve_settings "MYSQL_BACKUP_DIR"

TIMESTAMP=$(date +"%F")
BACKUP_DIR="$MYSQL_BACKUP_DIR/$TIMESTAMP"

read_ini '/etc/mysql/debian.cnf' 'client'

MYSQL_USER="backup"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump

mkdir -p "$BACKUP_DIR"

databases=`$MYSQL --socket=$INI__client__socket --user=$INI__client__user -p$INI__client__password -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

for db in $databases; do
  $MYSQLDUMP --force --opt --socket=$INI__client__socket --user=$INI__client__user -p$INI__client__password --databases $db | gzip > "$BACKUP_DIR/$db.gz"
done
