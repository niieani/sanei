cd /tmp
wget -O openfire_3.8.2_all.deb http://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_3.8.2_all.deb
dpkg -i openfire_3.8.2_all.deb
sed -i "s/6-sun/7-oracle/g" "/etc/init.d/openfire"

ufw allow Openfire