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
     sed -ie '$d' ~/.bash_profile
     apt-get -y install zsh htop mc software-properties-common ufw
     ufw enable
     chsh -s /bin/zsh
     exit
 else
     #echo >&2 "cannot acquire lock, giving up on $lockdir"
     exit 0
 fi


