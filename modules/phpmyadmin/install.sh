
askbreak "Really?"

add-apt-repository -y ppa:nijel/phpmyadmin
#apt-get update
apt-get install -y mariadb-client
source $CURDIR/add-www+mysql.sh
apt-get install -y phpmyadmin

#apt-get install -y nginx-light php5-fpm phpmyadmin php-apc lsof
chown -R www-data.www-data /usr/share/phpmyadmin

#apt-get install -y nginx-light php5-fpm php5-gd php5-curl php-pear php-apc lsof
#ufw allow "nginx full"

set_installed phpmyadmin
