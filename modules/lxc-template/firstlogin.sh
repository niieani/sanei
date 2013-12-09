#!/bin/bash
# locking
 lockdir=/tmp/firstlogin.lock
 if mkdir "$lockdir"
 then    # directory did not exist, but was created successfully
     echo >&2 "successfully acquired lock: $lockdir"
     # continue script

     # delete this script from bash_profile
     #sed -ie '$d' ~/.bash_profile
     # TODO: move this to the lxc creation profile
     apt-get --purge -y remove openssh-server
     apt-get -y install software-properties-common ufw wget dialog zsh htop mc
     ufw allow lxc-net
     ufw enable
     chsh -s /bin/zsh
     rmdir "$lockdir"
     rm ~/.bash_profile
     exit
 else
     #echo >&2 "cannot acquire lock, giving up on $lockdir"
     exit 0
 fi


