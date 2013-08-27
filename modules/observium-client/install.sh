if [[ $1 == "external" ]]; then
    echo "Using the external IP ($IP) instead of an AutoSSH tunnel."
    EXTERNAL=true
fi

mkdir -p /opt/observium-client/plugins
#link /shared/modules/observium-client/local-default /opt/observium-client/local

# fix hostname problem with rsyslog
apt-add-repository -y ppa:tmortensen/rsyslogv7
apt-get update
apt-get install -y rsyslog snmpd xinetd

SNMP_COMMUNITY=$(cat /proc/sys/kernel/random/uuid)
store_local_config "SNMP_COMMUNITY" $SNMP_COMMUNITY

if [[ -z $EXTERNAL ]]; then
	if [[ -z ${ConfigArr['SNMP_PORT_LAST']} ]]; then
	    SNMP_REMOTE_PORT=${ConfigArr['SNMP_PORT_START']}
	else
	    SNMP_REMOTE_PORT=$(( ${ConfigArr['SNMP_PORT_LAST']} + 1 ))
	fi
	store_shared_config "SNMP_PORT_LAST" $SNMP_REMOTE_PORT
	store_local_config "SNMP_REMOTE_PORT" $SNMP_REMOTE_PORT
	#remote_ufw_command="ufw allow from 127.0.0.1 app \"Observium Syslog\""
	remote_hosts_set="sudo $SCRIPT_DIR/modules/observium-server/add-host-via-ssh.sh $HOSTNAME $IP"
	set_installed observium-client-via-ssh norun
else
	SNMP_REMOTE_PORT=161
	remote_ufw_command="ufw allow from $IP app \"Observium Syslog\""
fi

set_installed observium-client

# TODO: BUG - won't work via SSH
if [[ -z $EXTERNAL ]]; then
	apt-get install -y autossh
	ufw allow from 127.0.0.1 app "Observium Agent"
	ufw allow from 127.0.0.1 to any port snmp
else
	ufw allow from $OBSERVIUM_SERVER app "Observium Agent"
	ufw allow from $OBSERVIUM_SERVER to any port snmp
fi

sanei_install_dependencies ssh-key

echo "Enter your Observium SSH password:"
ssh-copy-id "-p$SSH_PORT observium@$OBSERVIUM_SERVER"

service snmpd restart
service rsyslog restart

ssh observium@$OBSERVIUM_SERVER -p $SSH_PORT "${remote_hosts_set}; ${remote_ufw_command}; /opt/observium/addhost.php $HOSTNAME $SNMP_COMMUNITY v2c $SNMP_REMOTE_PORT tcp"

service autossh-snmp start