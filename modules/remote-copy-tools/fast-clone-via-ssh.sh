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
# :Dependencies: - apt:liblz4-tool
#                - apt:liblz4
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
local destpath="$2"
local destserver="$3"
local destport="$4"

tar --numeric-owner -cvf "$src" | lz4c -c | ssh -carcfour128 "$destserver" "-p$destport" "lz4c -d | tar -x > $dest"

# TODO: option with rsync
# preserves symlinks, archive mode (for copying system), verbose, compressed 
#rsync -Havz --ignore-existing --progress --exclude=cache/* --exclude=tmp/* --exclude=*backup* --rsh="ssh -p$port" ${server}:/lxc/$container "/lxc/$container"
# tar --use-compress-program=pigz --numeric-owner -cvf