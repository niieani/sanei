#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Really?"

mkdir -p /opt/observium-client/plugins
#link /shared/root/observium-client/local-default /opt/observium-client/local

# fix hostname problem with rsyslog
apt-add-repository -y ppa:tmortensen/rsyslogv7
apt-get update
apt-get install -y rsyslogd snmpd xinetd

ufw allow from 127.0.0.1 app "Observium Agent"
ufw allow from $OBSERVIUM_SERVER app "Observium Agent"

echo "*.* @@$OBSERVIUM_SERVER:$RSYSLOG_PORT" > $DIR/etc/rsyslog.d/97-send-to-observium.conf

link_all_files ${DIR}/etc/rsyslog.d /etc/rsyslog.d

set_installed observium-client
