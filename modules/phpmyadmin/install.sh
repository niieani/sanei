sanei_resolve_dependencies "php+mysql" "nginx-ssl" 

apt_install "mariadb-client phpmyadmin" "ppa:nijel/phpmyadmin"
chown -R www-data.www-data /usr/share/phpmyadmin

set_installed phpmyadmin

ufw allow phpmyadmin

service nginx reload