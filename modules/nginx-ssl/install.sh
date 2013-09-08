sanei_resolve_dependencies "nginx"

cd /etc/nginx
openssl genrsa -des3 -out default_ssl.key 1024
openssl req -new -key default_ssl.key -out default_ssl.csr
cp default_ssl.key default_ssl.key.org
openssl rsa -in default_ssl.key.org -out default_ssl.key
openssl x509 -req -days 1095 -in default_ssl.csr -signkey default_ssl.key -out default_ssl.crt

service nginx reload