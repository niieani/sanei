sanei_install_dependencies "php+mysql" 

add-apt-repository $(add_silent_opt) ppa:nijel/phpmyadmin
apt-get $(add_silent_opt) install mariadb-client phpmyadmin

chown -R www-data.www-data /usr/share/phpmyadmin

set_installed phpmyadmin