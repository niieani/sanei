apt_install "nginx-light" "ppa:nginx/development"
ufw allow "nginx full"

service nginx start