mkdir /etc/danted
touch /etc/danted/socks.passwd
chown root:root /etc/danted/socks.passwd
chmod 600 /etc/danted/socks.passwd
#mkpasswd -m sha-512
# printf "${DANTE_SERVER_LOGIN}:$(openssl passwd -apr1 ${DANTE_SERVER_PASSWORD})\n" >> /etc/danted/socks.passwd
printf "${DANTE_SERVER_LOGIN}:$(mkpasswd -m sha-512 ${DANTE_SERVER_PASSWORD})\n" >> /etc/danted/socks.passwd

ln -s libc.so.6 /lib/x86_64-linux-gnu/libc.so
#service danted start