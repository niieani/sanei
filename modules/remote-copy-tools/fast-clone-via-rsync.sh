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
local desthost="$2"
local destport="$3"

# preserves symlinks, archive mode (for copying system), verbose, compressed

# clean /var/cache/apt/archives/
enter_container "$container"
    apt-get autoclean
exit_container

rsync -Havz --ignore-existing --numeric-ids --progress --exclude='/rootfs/tmp/*' --exclude='/rootfs/srv/*/tmp/sessions/*' --rsh="ssh -p$destport" --rsync-path="sudo rsync" "/lxc/$container/" "${desthost}:/lxc/$container/"
