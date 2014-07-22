# Fast Clone via SSH
# =================
# .. module:: remove-copy-tools.fast-clone-via-rsync
#    :synopsis: Clones local lxc container to a remote host via rsync.
# .. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>
#
# Module
# ++++++
#
# :Description: TODO
#
# :Dependencies: - apt:rsync
#                - apt:openssh-client
#
# Arguments
# +++++++++
#
# .. cmdoption:: container
#
#    Container name
#
# .. cmdoption:: destination
#
#    Destination host (with opt. username)
#
# .. cmdoption:: destinationport
#
#    Destination's SSH port
#

local container="$1"
local desthost="$1"
local destport="$2"

# preserves symlinks, archive mode (for copying system), verbose, compressed 

rsync -Havz --ignore-existing --progress --rsh="ssh -p$destport" --rsync-path="sudo rsync" /lxc/$container ${desthost}:/lxc/$container
