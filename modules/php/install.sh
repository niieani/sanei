mkdir -p /var/log/php

sanei_resolve_dependencies nginx

apt_install "php5-fpm php5-gd php5-curl php-pear php-apc lsof"

# observium support TODO: if
apt_install "libwww-perl python"
#link /shared/modules/observium-client/local-www /opt/observium-client/local