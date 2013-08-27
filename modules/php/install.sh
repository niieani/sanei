mkdir -p /var/log/php

add-apt-repository -y ppa:nginx/development
apt-get update
apt-get install -y nginx-light php5-fpm php5-gd php5-curl php-pear php-apc lsof
ufw allow "nginx full"

# observium support TODO: if
apt-get install -y libwww-perl python
#link /shared/modules/observium-client/local-www /opt/observium-client/local

set_installed nginx
set_installed php