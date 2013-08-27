askbreak "Really?"

ssh-keygen -t rsa -C "$(whoami)@$(hostname)-$(date -I)" -N ""

set_installed ssh-key norun
