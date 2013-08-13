#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Really? Make sure your hostname is correct!"

mkdir -p /opt/observium-client/plugins
#link /shared/root/observium-client/local-default /opt/observium-client/local

# fix hostname problem with rsyslog
apt-add-repository -y ppa:tmortensen/rsyslogv7
apt-get update
apt-get install -y rsyslog snmpd xinetd

ufw allow from 127.0.0.1 app "Observium Agent"
ufw allow from $OBSERVIUM_SERVER app "Observium Agent"
ufw allow from 127.0.0.1 to any port snmp
ufw allow from $OBSERVIUM_SERVER to any port snmp
ufw allow from 127.0.0.1 to any port snmp-trap
ufw allow from $OBSERVIUM_SERVER to any port snmp-trap

echo "*.* @@$OBSERVIUM_SERVER:$RSYSLOG_PORT" > $DIR/etc/rsyslog.d/97-send-to-observium.conf

#link_all_files ${DIR}/etc/rsyslog.d /etc/rsyslog.d

HOSTNAME=$(hostname --fqdn)
SNMP_COMMUNITY=$(cat /proc/sys/kernel/random/uuid)
store_local_config "SNMP_COMMUNITY" $SNMP_COMMUNITY

set_installed observium-client

service snmpd restart
service rsyslog restart

echo "Enter your Observium SSH password:"
ssh observium@$OBSERVIUM_SERVER -p $SSH_PORT "/opt/observium/addhost.php $HOSTNAME $SNMP_COMMUNITY v2c"
