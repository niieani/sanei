#!/bin/bash
# (c) Bazyli Brzoska GNU license

# sanitize variable and uppercase
function sanitize(){
	local clean
	clean="${1//[^a-zA-Z0-9]/_}"
	echo "${clean^^}"
}
function tabs_to_spaces(){
	# 1 tab = 4 spaces
	echo "${1//[	]/    }"
}
function rematch(){
	local text="$1"
	local regex="$2"
	local param="$3"
	if [[ "$text" =~ $regex ]]; then
		if [[ ! -z $param ]]; then
			echo "${BASH_REMATCH[${param}]}"
		fi
		return 0
	else
		return 1
		# no match
	fi
}
function count_spacing(){
	local text="$1"
	local spaces
	# TODO: doesn't need tabs
	TAB_COUNTS_AS="4"
	# you shouldn't mix tabs and spaces
	spaces="$(rematch "$text" "^[	]*([ ]*)[.]*" 1)"
	tabs="$(rematch "$text" "^[ ]*([	]*)[.]*" 1)"
	echo $(( ${#spaces} + ${#tabs} * TAB_COUNTS_AS ))
}
function trim_spacing(){
	local text="$1"
	echo "$(rematch "$text" "^[ 	]*(.*)" 1)"
}
function space_x_times(){
	# local string="$1"
	local x="$1"
	[[ $x -gt 0 ]] && ( printf "%*s" "$x" ) # "$string"
	# [[ $x -gt 0 ]] && ( IFS='%' printf "$string%.0s" {1.."$x"} )
	# 
}
function parse_rst(){

	# first stage:
	declare -A lines
	local file="$1"
	local line_number=0
	local prev_line_number=0

	# second stage:
	# declare -a parsed_text
	# declare -a parsed_name
	# declare -a parsed_type
	# declare -a parsed_list
	local parsed_segment=0

	# required parsing styles

	# TODO: better lexers /usr/share/pyshared/pygments/lexers/text.py

	# directive
	# .. module:: parrot
	directive_regex='^.. ([a-zA-Z0-9]+)::[ ]*(.*)'

	# field / option
	# :platform: Unix, Windows
	field_regex='^:([a-zA-Z0-9 ]+):[ ]+(.*)'

	# section
	# :mod:`parrot` -- Dead parrot access
	section_regex='^:(.+):(.+)'

	source_start_regex='(.*)::$'
	comment_start_regex='^.. (.*)'

	# after trimming whitespace
	list_bulleted='^\* (.+)$'
	list_numbered='^[0-9]+. (.+)$'
	list_numbered_alt='^#. (.+)$'
	list_params='^- (.+)$'

	# heading
	#heading_regex="^(=+|-+|`+|:+|\.+|\'+|"+|~+|\^+|_+|\*+|\++|#+)"

	# the great parsing looper:
	# http://stackoverflow.com/questions/4165135/how-to-use-while-read-bash-to-read-the-last-line-in-a-file-if-theres-no-new
	while IFS= read -r line || [[ -n "$line" ]]; do

		prev_line_number=$line_number
		while [[ ${lines["$prev_line_number,type"]} == empty ]]; do
			# ignoring empty lines for reference/start lines
			((prev_line_number--))
		done

		((line_number++))

		line=$(tabs_to_spaces "$line")

		# lines["$line_number,spacing"]
		# prev: lines["$((line_number - 1)),spacing"]

		lines["$line_number,spacing"]=$(count_spacing "$line")
		lines["$line_number,value"]=$(trim_spacing "$line")
		lines["$line_number,count"]=${#lines["$line_number,value"]}

		# echo "${lines["$line_number,value"]}"
		if [[ "${lines["$line_number,value"]}" == "" ]]; then
			lines["$line_number,type"]=empty
			# we have to simulate spacing is the same in order to keep continuing if more paragraphs are there
			# lines["$line_number,spacing"]=${lines["$prev_line_number,spacing"]}
		elif rematch "${lines["$line_number,value"]}" "$directive_regex"; then
			# directives["$(rematch "${lines["$line_number,value"]}" "$directive_regex" 1)"]="$(rematch "${lines["$line_number,value"]}" "$directive_regex" 2)"
			lines["$line_number,type"]=directive
			lines["$line_number,name"]="$(rematch "${lines["$line_number,value"]}" "$directive_regex" 1)"
			lines["$line_number,value"]="$(rematch "${lines["$line_number,value"]}" "$directive_regex" 2)"
		elif rematch "${lines["$line_number,value"]}" "$field_regex"; then
			lines["$line_number,type"]=field
			# TODO: sanitize doesn't need to be here, but in the next step of parsing
			# lines["$line_number,name"]="$(sanitize "$(rematch "${lines["$line_number,value"]}" "$field_regex" 1)")"
			lines["$line_number,name"]="$(rematch "${lines["$line_number,value"]}" "$field_regex" 1)"
			lines["$line_number,value"]="$(rematch "${lines["$line_number,value"]}" "$field_regex" 2)"
			# support for lists
			# eval "__FIELD_${lines["$line_number,name"]}=\"${lines["$line_number,value"]}\""
		elif rematch "${lines["$line_number,value"]}" "$section_regex"; then
			# sections["$(rematch "${lines["$line_number,value"]}" "$section_regex" 1)"]="$(rematch "${lines["$line_number,value"]}" "$section_regex" 2)"
			lines["$line_number,type"]=section
			lines["$line_number,name"]="$(rematch "${lines["$line_number,value"]}" "$section_regex" 1)"
			lines["$line_number,value"]="$(rematch "${lines["$line_number,value"]}" "$section_regex" 2)"
		elif rematch "${lines["$line_number,value"]}" "$source_start_regex"; then
			lines["$line_number,type"]=source
			# text["$line_number"]=
			lines["$line_number,value"]="$(rematch "${lines["$line_number,value"]}" "$source_start_regex" 1)"
		fi

		# TODO: should recognize "source"
		lines["$line_number,length"]=$(( ${#line} - ${#lines["$line_number,value"]} ))

		# support for lists
		if rematch "${lines["$line_number,value"]}" "$list_bulleted"; then
			lines["$line_number,list"]=bulleted
			lines["$line_number,value"]="$(rematch "${lines["$line_number,value"]}" "$list_bulleted" 1)"
		elif rematch "${lines["$line_number,value"]}" "$list_numbered"; then
			lines["$line_number,list"]=numbered
			lines["$line_number,value"]="$(rematch "${lines["$line_number,value"]}" "$list_numbered" 1)"
		elif rematch "${lines["$line_number,value"]}" "$list_numbered_alt"; then
			lines["$line_number,list"]=numbered_alt
			lines["$line_number,value"]="$(rematch "${lines["$line_number,value"]}" "$list_numbered_alt" 1)"
		elif rematch "${lines["$line_number,value"]}" "$list_params"; then
			lines["$line_number,list"]=params
			lines["$line_number,value"]="$(rematch "${lines["$line_number,value"]}" "$list_params" 1)"
		fi

		if [[ -z "${lines["$line_number,type"]}" ]]; then
			# if the spacing is the same as previous line
			# -ge ${prev_line_number,parentline}
			last_parent="${lines["$prev_line_number,parentline"]:-$prev_line_number}"
			# echo "${lines["$last_parent,length"]}"
			# "${lines["${lines["$prev_line_number,parentline"]",length"]}"
			#if [[ "${lines["$line_number,length"]}" -ge "${lines["$last_parent,length"]}" || "${lines["$line_number,length"]}" -ge "${lines["$prev_line_number,length"]}" ]]; then
			if [[ "${lines["$line_number,length"]}" -ge "${lines["$last_parent,length"]}" ]]; then
				# continuing the same thing
				# && [[ "${lines["$prev_line_number,type"]}" != empty ]]
				#lines["$line_number,parentline"]="${lines["$prev_line_number,parentline"]:-$prev_line_number}"
				lines["$line_number,parentline"]="$last_parent"
				if [[ "$last_parent" -gt 0 && $(( ${lines["$line_number,length"]} - ${lines["$last_parent,length"]} )) -gt 0 ]]; then
					lines["$line_number,indentation"]=$(( ${lines["$line_number,length"]} - ${lines["$last_parent,length"]} ))
				fi
				# lines["$line_number,type"]="${lines["$prev_line_number,type"]}"
			else
				lines["$line_number,type"]=text
			fi
		fi

		# second stage of parsing:

		if [[ "${lines["$line_number,type"]}" != empty ]]; then
			#statements

			if [[ -z "${lines["$line_number,parentline"]}" ]]; then
				# parent="${lines["$line_number,parentline"]}"
				((parsed_segment++))
			# elif [[ "${lines["$((line_number - 1)),type"]}" == empty ]]; then
				# echo "${lines["${lines["$line_number,parentline"]},type"]}"
			# if prev line is empty and this line has a parent and type = text or source then add enter
			elif [[ "${lines["$((line_number - 1)),type"]}" == empty ]]; then
				# && [[ "${lines["${lines["$line_number,parentline"]},type"]}" == source || "${lines["${lines["$line_number,parentline"]},type"]}" == text ]]; then
				parsed_text[$parsed_segment]+="
"
			fi

			if [[ "${lines["$prev_line_number,list"]}" ]] && [[ "${lines["$prev_line_number,list"]}" != "${lines["$line_number,list"]}" ]]; then
				((parsed_segment++))
				parsed_list[$parsed_segment]="${lines["$line_number,list"]}"
				parsed_type[$parsed_segment]="${lines["${lines["$line_number,parentline"]},type"]}" #"${lines["${lines["$line_number,parentline"]},type"]}"
			elif [[ -z "${parsed_list[$parsed_segment]}" ]]; then
				parsed_list[$parsed_segment]="${lines["$line_number,list"]}"
			fi

			if [[ "${lines["$line_number,name"]}" ]]; then
				parsed_name[$parsed_segment]="${lines["$line_number,name"]}"
			fi

			if [[ -z "${parsed_type[$parsed_segment]}" ]]; then
				parsed_type[$parsed_segment]="${lines["$line_number,type"]}"
			fi

			if [[ "${parsed_text[$parsed_segment]}" ]]; then
				parsed_text[$parsed_segment]+="
"
			fi
			parsed_text[$parsed_segment]+="$(space_x_times "${lines["$line_number,indentation"]}")${lines["$line_number,value"]}"

		# elif [[ "${lines["$((line_number - 1)),type"]}"==empty ]]; then
			# TODO: two consecutive empty lines break a segment
			# ((parsed_segment++))
			# parsed_type[$parsed_segment]="${lines["${lines["$prev_line_number,parentline"]},type"]}" #"${lines["${lines["$line_number,parentline"]},type"]}"
		fi
		[[ $VERBOSE -ge 2 ]] && ( echo -e "$line_number.\t(${lines["$line_number,length"]})\t<p:${lines["$line_number,parentline"]}>\t[${lines["$line_number,type"]}]\t\t${lines["$line_number,name"]}\t${lines["$line_number,value"]}" )
	done < "$file"

	total_lines=$line_number

}
