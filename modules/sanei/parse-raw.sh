source_file="$1"
output_prefix="${2:-VAR_}"

# load the lib
source "$SANEI_LIB/parse-rst.sh"
# start the parsing
declare -a parsed_name
declare -a parsed_text
declare -a parsed_type
declare -a parsed_list
# raw mode::
parse_rst "$1"

if [[ $VERBOSE -ge 1 && $INVOKED_COUNT -le 1 || $VERBOSE -ge 4 ]]; then
	# for each parsed part
	for key in ${!parsed_type[@]}; do
		echo "${GREEN}[${parsed_type[$key]},${parsed_list[$key]}] ${WHITE}${parsed_name[$key]}${RESET}"
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
	eval "$field_name=(\"\${$field_name[@]}\" \"${parsed_text[$key]}\")"
	# export "${output_prefix}${parsed_name[$key]}"="${parsed_text[$key]}"
done
# declare -p VAR_ENVVAR
# echo "$VAR_VARIABLES"