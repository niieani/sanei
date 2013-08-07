#!/bin/bash
read -p "Are you sure? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

source functions.sh

mkdir -p /opt/observium-client/plugins
link /shared/root/observium-client/local-default /opt/observium-client/local

apt-get install -y snmpd xinetd

ufw allow from 127.0.0.1 app "Observium Agent"
ufw allow from $OBSERVIUM_SERVER app "Observium Agent"

echo "*.* @@$OBSERVIUM_SERVER:$RSYSLOG_PORT" > $DIR/etc/rsyslog.d/97-send-to-observium.conf

link_all_files ${DIR}/etc/rsyslog.d /etc/rsyslog.d

touch /opt/.install.observium-client
