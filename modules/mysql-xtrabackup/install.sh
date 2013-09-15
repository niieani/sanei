# for use with obnam as the dailies are overwritten
# http://www.mysqlperformanceblog.com/2013/07/16/an-ubuntu-ppa-of-daily-builds-of-percona-xtrabackup/
apt_install "percona-xtrabackup" "ppa:percona-daily/percona-xtrabackup"
touch /var/lib/mysql/CACHEDIR.TAG