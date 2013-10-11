apt-get $(add_silent_opt) install openssh-server

set_installed ssh

ufw allow OpenSSH

service ssh restart