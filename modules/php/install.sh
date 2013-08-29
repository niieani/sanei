mkdir -p /var/log/php

add-apt-repository $(add_silent_opt) ppa:nginx/development
apt-get update
apt-get $(add_silent_opt) install nginx-light php5-fpm php5-gd php5-curl php-pear php-apc lsof
ufw allow "nginx full"

# observium support TODO: if
apt-get $(add_silent_opt) install libwww-perl python
#link /shared/modules/observium-client/local-www /opt/observium-client/local

set_installed nginx
set_installed php