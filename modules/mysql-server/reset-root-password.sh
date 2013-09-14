dpkg-reconfigure mariadb-server-5.5
# service mysql stop
# echo "Please provide your new root password:"
# read NewPassword
# echo "UPDATE mysql.user SET Password=PASSWORD('$NewPassword') WHERE User='root';
# FLUSH PRIVILEGES;" > /root/mysqlreset
# mysqld_safe --init-file=/root/mysqlreset &
# sleep 10
# rm -f /root/mysqlreset
# kill $(cat /run/mysqld/mysqld.pid)