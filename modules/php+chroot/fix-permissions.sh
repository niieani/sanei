for dir in $WEBSITES_DIR/* ; do
	if [ -d "$dir" ] ; then
		for file in $dir/* ; do
			if [ -f "$file" ] ; then
				info "Fixing permissions for $(cat "$file")..."
				correct_permissions_website $(basename "$file")
			fi
		done
	fi
done