#!/bin/bash
#CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"

source functions.sh

read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

mkdir -p /var/log/php

add-apt-repository -y ppa:nginx/development
apt-get update
apt-get install -y nginx-light php5-fpm php5-mysqlnd php5-gd php5-curl php-pear php-apc lsof
ufw allow "nginx full"

# observium support
apt-get install -y libwww-perl python
link /shared/root/observium-client/local-www /opt/observium-client/local

touch /opt/.install.www
