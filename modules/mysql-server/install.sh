askbreak "Really?"

apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
add-apt-repository 'deb http://mirror.netcologne.de/mariadb/repo/5.5/ubuntu raring main'
apt-get update
rm /run/mysqld
apt-get install mariadb-server
service mysql stop
rmdir /run/mysqld
ln -s /shared/run/mysqld /run/mysqld
chown mysql.root /shared/run/mysqld
service mysql start

set_installed mysql-server norun
