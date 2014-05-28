mkdir /etc/danted
touch /etc/danted/socks.passwd
printf "${DANTE_SERVER_LOGIN}:$(openssl passwd -apr1 ${DANTE_SERVER_PASSWORD})\n" >> /etc/danted/socks.passwd
#service danted start