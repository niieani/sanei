apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
add-apt-repository "deb http://mirror.netcologne.de/mariadb/repo/10.0/ubuntu $DISTRO main"
apt-get update
apt-get install mariadb-client