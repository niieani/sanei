REMOTE_HOSTNAME=$1
IP=$2
sudo echo "# LOCAL FOR REAL IP: $IP #" >> /etc/hosts
sudo echo "127.0.0.1 $REMOTE_HOSTNAME" >> /etc/hosts