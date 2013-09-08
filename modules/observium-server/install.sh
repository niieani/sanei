#apt-get $(add_silent_opt) install 12345
# todo "Actual installation."

sanei_resolve_dependencies php+mysql
apt_install "php5-cli php5-mcrypt php5-snmp snmp graphviz subversion mariadb-client rrdtool fping imagemagick whois mtr-tiny nmap ipmitool python-mysqldb"
mkdir -p /opt/observium && cd /opt

svn co http://www.observium.org/svn/observer/trunk observium
ln -s /opt/observium /usr/share/observium

# TODO (in home?):
#useradd -d /opt/observium -g www-data -M -s /bin/sh observium
#echo "Password for the remote access user: "
#passwd observium

#set_installed observium-server

# allow syslogging from localhost
#ufw allow from 127.0.0.1 app "Observium Syslog"
#ufw allow 677 # change for observium-server and fixme not to allow everybody, just the right IPs

# add su access ONLY to the hosts file to the user without repeating the password
# /etc/hosts 
#echo "observium ALL=(root)NOPASSWD:$SCRIPT_DIR/modules/observium-server/add-host-via-ssh.sh *" > /etc/sudoers.d/observium
