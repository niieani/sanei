for dir in $WEBSITES_DIR/* ; do
	if [ -d "$dir" ] ; then
		for file in $dir/* ; do
			if [ -f "$file" ] ; then
				info "Mounting $(cat "$file")..."
				mount_website $(basename "$file")
			fi
		done
	fi
done
