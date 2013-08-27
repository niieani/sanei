sanei_install_dependencies "php+mysql" 

add-apt-repository -y ppa:nijel/phpmyadmin
apt-get install -y mariadb-client phpmyadmin

chown -R www-data.www-data /usr/share/phpmyadmin

set_installed phpmyadmin