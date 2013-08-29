apt-get $(add_silent_opt) install openssh-server

set_installed ssh

service ssh restart