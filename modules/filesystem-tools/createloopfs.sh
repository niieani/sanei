# Create multiple loopfs
# =================
# .. module:: filesystem-tools.createloopfs
#    :synopsis: Create multiple loopfs filesystem.
# .. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>
#
# Module
# ++++++
#
# :Description: TODO. Great for backing up millions of files.
#
# Arguments
# +++++++++
#
# .. cmdoption:: destinationdir
#
#    Destination dir
#
# .. cmdoption:: size
#
#    Size of one loopfs
#
# .. cmdoption:: mountpointdir
#
#    Mountpoint
#
# .. cmdoption:: howmany
#
#    How many loopfiles to create
#

createloopfs(){
	local fulldestpath="$(readlink -m $1)"
	local size="$2"
	local mountpoint="$3"
	local fstab="$4"

	local mountparams="loop,noatime"
	local fs="ext4"
	truncate --size "$size" "$fulldestpath"
	mkfs.ext4 -F "$fulldestpath"
	#mount -o "$mountparams" "$fulldestpath" "$mountpoint"
	echo "$fulldestpath $mountpoint $fs $mountparams 0 2" >> "$4"
}

local destdir="$1"
local size="$2"
local mountpointdir="$3"
local howmany="$4"
local fstab="$5"

while read i; do 
	echo "Generating: $destdir/$i.img" 
	mkdir -p "$destdir"
	mkdir -p "$mountpointdir/$i"
	createloopfs "$destdir/$i.img" "$size" "$mountpointdir/$i"
done < <(seq -w 0 $howmany)
