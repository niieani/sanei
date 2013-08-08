#!/bin/bash
CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
#source $CURDIR/functions.sh

# locking example -- CORRECT
 # Bourne
 lockdir=/tmp/first-run.lock
 if mkdir "$lockdir"
 then    # directory did not exist, but was created successfully
     echo >&2 "successfully acquired lock: $lockdir"
     # continue script

     # delete this script from bash_profile
     #sed -ie '$d' ~/.bash_profile
     rm ~/.bash_profile
     apt-get -y install zsh htop mc software-properties-common ufw wget
     apt-get --purge -y remove openssh-server
     ufw allow lxc-net
     ufw enable
     chsh -s /bin/zsh
     rmdir /tmp/first-run.lock
     exit
 else
     #echo >&2 "cannot acquire lock, giving up on $lockdir"
     exit 0
 fi


