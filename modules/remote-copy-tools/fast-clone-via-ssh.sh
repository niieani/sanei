# Fast Clone via SSH
# =================
# .. module:: remove-copy-tools.fast-clone-via-ssh
#    :synopsis: Clones local directories to a remote host via SSH.
# .. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>
#
# Module
# ++++++
#
# :Description: TODO. Great for millions of files. 
#               Needs to be installed on both ends (or at least the dependencies).
#
#               Reference:
#               http://superuser.com/questions/291803/best-way-to-copy-millions-of-files-between-2-servers
#
# :Dependencies: - apt:liblz4-tool
#                - apt:openssh-client
#
# Arguments
# +++++++++
#
# .. cmdoption:: source
#
#    Source dir
#
# .. cmdoption:: destination
#
#    Destination path
#
# .. cmdoption:: server
#
#    Destination SSH server (with opt. username)
#
# .. cmdoption:: port
#
#    Destination's SSH port
#

local src="$1"
local srcpathbase=$(dirname "$1")
local srcpathtarget=$(basename "$1")

local destpath="$2"
local destpathbase=$(dirname "$2")
local destpathtarget=$(basename "$2")

local destserver="$3"
local destport="$4"

eval "sleep 20; while killall -USR1 tar >/dev/null; do sleep 1; done" &
cd "$srcpathbase"; tar --numeric-owner -p -c --totals --totals=USR1 "$srcpathtarget" | lz4c -c stdin stdout | ssh -carcfour128 "$destserver" "-p$destport" "lz4c -d | tar -pxf - -C \"$destpathbase\""


# local src="$1"
# local destpath="$2"
# local destserver="$3"
# local destport="$4"

# eval "sleep 20; while killall -USR1 tar >/dev/null; do sleep 1; done" &
# tar --numeric-owner -p -c --totals --totals=USR1 "$src" | lz4c -c stdin stdout | ssh -carcfour128 "$destserver" "-p$destport" "lz4c -d | tar -pxf - -C $destpath"

# TODO: option with rsync
# preserves symlinks, archive mode (for copying system), verbose, compressed 
#rsync -Havz --ignore-existing --progress --exclude=cache/* --exclude=tmp/* --exclude=*backup* --rsh="ssh -p$port" ${server}:/lxc/$container "/lxc/$container"
# tar --use-compress-program=pigz --numeric-owner -cvf