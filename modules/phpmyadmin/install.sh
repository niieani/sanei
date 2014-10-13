apt_install "phpmyadmin" "ppa:nijel/phpmyadmin"
chown -R www-data.www-data /usr/share/phpmyadmin

#set_installed phpmyadmin

ufw allow phpmyadmin

service nginx reload