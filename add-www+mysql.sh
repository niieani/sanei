#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh
askbreak "Really?"

source $CURDIR/add-www.sh
apt-get -y install php5-mysqlnd

set_installed www+mysql norun
