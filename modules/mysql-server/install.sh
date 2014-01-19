apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
add-apt-repository "deb http://mirror.netcologne.de/mariadb/repo/10.0/ubuntu $DISTRO main"
mkdir /etc/mysql-local
apt-get update
rm /run/mysqld
apt-get install mariadb-server
service mysql stop
rmdir /run/mysqld
ln -s /shared/run/mysqld /run/mysqld
chown mysql.root /shared/run/mysqld
service mysql start