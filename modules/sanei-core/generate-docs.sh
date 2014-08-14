# Example Operation
# =================
# .. module:: sanei.internal.generate-docs
#    :synopsis: Generates documentation for SANEi.
#    :platform: raring
# .. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>
#
# :Dependencies: - apt:python-sphinxcontrib.issuetracker
#
# Arguments
# +++++++++
#
# .. cmdoption:: $1
#
#    Output dir for docs.
#
# .. cmdoption:: $2
#
#    Source dir of the script.
#

output_dir="${1:-$DOCS_DIR}/source"
source_dir="${2:-$SCRIPT_DIR}"

# prepare the file
#recreate_dir_structure "$source_dir" "$output_dir"
(
	cd "$source_dir"
	file_list=$(find -L "$source_dir" -type f -name "*.sh" -path "$source_dir/modules/*" ! -path "$source_dir/modules/dotfiles/root/*" ! -path "$source_dir/modules/observium-client/available/*" -printf "%P\n")
	file_list+=("${IFS}sanei")
	for source_file in ${file_list[@]}; do
		target_dir="$output_dir/$(dirname "$source_file")"
		filename="$(basename "$source_file")"
		filename="${filename%.*}"
		info "Generating $target_dir/$filename.rst"
		mkdir -p "$target_dir"
		$VENDOR_DIR/bashdoc/bashdoc -o "$target_dir/$filename.rst" -H better.basic raw "$source_file"
	done
	unset file_list target_dir filename
	# copy .rst files
	file_list=$(find -L "$source_dir" -type f -name "*.rst" ! -path "$output_dir/*" ! -path "$source_dir/vendor/*" ! -path "$source_dir/tmp/*" ! -path "$source_dir/modules/dotfiles/root/*" -printf "%P\n")
	for source_file in ${file_list[@]}; do
		target_dir="$output_dir/$(dirname "$source_file")"
		filename="$(basename "$source_file")"
		info "Copying $target_dir/$filename"
		mkdir -p "$target_dir"
		cp "$source_file" "$target_dir/$filename"
	done
)
(
	cd "$output_dir/.."
	make html
)