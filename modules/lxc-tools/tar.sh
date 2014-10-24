local container="/lxc/$1"

eval "sleep 20; while killall -USR1 tar >/dev/null; do sleep 1; done" &
tar --numeric-owner -p -c -f $1.tar --totals --totals=USR1 "$container"
