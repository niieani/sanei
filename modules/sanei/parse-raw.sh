source_file="$1"
output_prefix="${2:-VAR_}"

if [[ -f "$source_file" ]]; then

	# load the lib
	source "$SANEI_LIB/parse-rst.sh"
	# start the parsing
	declare -a parsed_name
	declare -a parsed_text
	declare -a parsed_type
	declare -a parsed_list
	declare -a parsed_parent
	# raw mode::
	parse_rst "$1"
	debug "INVOKED_COUNT $INVOKED_COUNT"
	if [[ $VERBOSE -ge 1 && $INVOKED_COUNT -le 2 || $VERBOSE -ge 4 ]]; then
		# for each parsed part
		for key in ${!parsed_type[@]}; do
			echo "[${RED}$key,${GREEN}${parsed_type[$key]}${RESET},${parsed_list[$key]},${parsed_parent[$key]}] ${WHITE}${parsed_name[$key]}${RESET}"
			if [[ "${parsed_type[$key]}" == "source" ]] && hash pygmentize 2>/dev/null; then
				echo "${parsed_text[$key]}" > "/tmp/source"
		        pygmentize -l bash "/tmp/source"
		        rm "/tmp/source"
			# elif [[ -z "${parsed_text[$key]}" ]]; then
			else
				echo "${parsed_text[$key]}"
			fi
		done
	fi

	# for each parsed part that has a name (fields, directives, sections), export it into a variable
	for key in ${!parsed_name[@]}; do
		field_name="${output_prefix}$(sanitize "${parsed_name[$key]}")"
		#echo "${parsed_text[$key]}"
		# for elem in "${field_name[@]}"; do
		# 	glued = glued + "'$elem'"
		# done
		eval "$field_name=(\"\${$field_name[@]}\" \"\${parsed_text[$key]}\")"

		#eval "$field_name=($glued \"\${parsed_text[$key]}\")"
		# export "${output_prefix}${parsed_name[$key]}"="${parsed_text[$key]}"
	done
	# declare -p VAR_ENVVAR
	# declare -p parsed_parent
	# echo "$VAR_VARIABLES"
	echo ${VAR_ENVVAR[0]} | sed -n 1p
else
	error "Source file $source_file doesn't exist."
fi