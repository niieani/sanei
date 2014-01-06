local container="$1"
local server="$2"
local port="$3"

if [[ ! $DONOTSTOP ]]; then
	ssh "${server}" -p$port "lxc-stop -n container"
fi

rsync -Havz --ignore-existing --progress --exclude=cache/* --exclude=tmp/* --exclude=*backup* --exclude=*web/htdocs* --rsh="ssh -p$port" ${server}:/lxc/$container "/lxc/$container"
# preserves symlinks, archive mode (for copying system), verbose, compressed 
