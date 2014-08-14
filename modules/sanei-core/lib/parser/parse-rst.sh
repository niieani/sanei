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
	local line_number=1
	local prev_line_number

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

	started=0
	first_content_line=1

	length_addition=0

	# heading
	#heading_regex="^(=+|-+|`+|:+|\.+|\'+|"+|~+|\^+|_+|\*+|\++|#+)"

	# the great parsing looper:
	# http://stackoverflow.com/questions/4165135/how-to-use-while-read-bash-to-read-the-last-line-in-a-file-if-theres-no-new
	while IFS= read -r line || [[ -n "$line" ]]; do
		line=$(tabs_to_spaces "$line")

		if [[ $started -eq 0 && -z "$(trim_spacing "$line")" ]]; then

			lines["$line_number,type"]=empty
			((line_number++))
			((first_content_line++))

			continue
		fi

		started=1

		prev_line_number=$(( $line_number - 1 ))
		while [[ ${lines["$prev_line_number,type"]} == empty ]]; do
			# ignoring empty lines for reference/start lines
			((prev_line_number--))
		done
		if [[ $prev_line_number -lt $first_content_line ]]; then
			prev_line_number=$(($first_content_line - 1))
		fi

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
		case "${lines["$line_number,type"]}" in
			directive )
				lines["$line_number,length"]=$(( ${lines["$line_number,spacing"]} + 3 ))
				length_addition=1
				;;
			field )
				lines["$line_number,length"]=$(( ${lines["$line_number,spacing"]} + 2 ))
				# length_addition=0
				;;
			"" )
				lines["$line_number,length"]=$(( ${#line} - ${#lines["$line_number,value"]:-0} + $length_addition ))
				;;
			empty )
				lines["$line_number,length"]=$(( ${#line} - ${#lines["$line_number,value"]:-0} ))
				;;
            * )
				lines["$line_number,length"]=$(( ${#line} - ${#lines["$line_number,value"]:-0} ))
				length_addition=0
				;;
		esac
		
		# lines["$line_number,length"]=$(( ${#line} - ${#lines["$line_number,name"]:-0} - ${#lines["$line_number,value"]:-0} ))
		# lines["$line_number,length"]=$(( ${#line} - ${#lines["$line_number,value"]:-0} ))

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

		# if the spacing is the same as previous line
		# -ge ${prev_line_number,parentline}

		last_parent="${lines["$prev_line_number,parentline"]:-$prev_line_number}"
		# echo "${lines["$last_parent,length"]}"
		# "${lines["${lines["$prev_line_number,parentline"]",length"]}"
		#if [[ "${lines["$line_number,length"]}" -ge "${lines["$last_parent,length"]}" || "${lines["$line_number,length"]}" -ge "${lines["$prev_line_number,length"]}" ]]; then
		if [[ "${lines["$line_number,length"]}" -ge "${lines["$last_parent,length"]}" && "$prev_line_number" -ge "$first_content_line" ]]; then
			# continuing the same thing
			# && [[ "${lines["$prev_line_number,type"]}" != empty ]]
			#lines["$line_number,parentline"]="${lines["$prev_line_number,parentline"]:-$prev_line_number}"

			if [[ -z "${lines["$line_number,type"]}" ]]; then
				lines["$line_number,parentline"]="$last_parent"
				if [[ "$last_parent" -gt 0 && $(( ${lines["$line_number,length"]} - $length_addition - ${lines["$last_parent,length"]:-0} )) -gt 0 ]]; then
					indentation_based_upon=$(( $last_parent + 1 ))
					lines["$line_number,indentation"]=$(( ${lines["$line_number,length"]} - ${lines["$indentation_based_upon,length"]} ))
				fi
			fi
			# "${lines["$line_number,type"]}"==field && 


			# lines["$line_number,type"]="${lines["$prev_line_number,type"]}"
		elif [[ -z "${lines["$line_number,type"]}" ]]; then
			lines["$line_number,type"]=text
		fi

		parent_line_number=$line_number
				
		until [[ "${lines["$parent_line_number,type"]}" && "${lines["$parent_line_number,type"]}" != empty && "${lines["$parent_line_number,length"]}" -lt "${lines["$line_number,length"]}" ]] || [[ $parent_line_number -le "$first_content_line" ]]; do
			((parent_line_number--))
		done
		# if [[ "${lines["$line_number,type"]}" != "${lines["$parent_line_number,type"]}" ]]; then
			lines["$line_number,parentblock"]="$parent_line_number"
		# fi

		# second stage of parsing:

		# while [[ ${parsed_type[$last_defined_parsed_segment]} == empty ]]; do
		# 	# ignoring empty lines for reference/start lines
		# 	((prev_line_number--))
		# done

		if [[ "${lines["$line_number,type"]}" != empty ]]; then
			

			if [[ -z "${lines["$line_number,parentline"]}" ]]; then
				# parent="${lines["$line_number,parentline"]}"
				((parsed_segment++))
			# elif [[ "${lines["$((line_number - 1)),type"]}" == empty ]]; then
				# echo "${lines["${lines["$line_number,parentline"]},type"]}"
			# if prev line is empty and this line has a parent and type = text or source then add enter
			elif [[ "${lines["$((line_number - 1)),type"]}" == empty ]]; then
				if [[ "${lines["${lines["$line_number,parentline"]},type"]}" == source || "${lines["${lines["$line_number,parentline"]},type"]}" == text || "${lines["${lines["$line_number,parentline"]},type"]}" == field ]]; then  #"${lines["${lines["$line_number,parentline"]},type"]}"
				parsed_text[$parsed_segment]+="
"
				# if last one was empty and before that it was a directive, make a new segment too
				elif [[ "${lines["${lines["$line_number,parentline"]},type"]}" == directive ]]; then  #"${lines["${lines["$line_number,parentline"]},type"]}"
					((parsed_segment++))
					# also make this line relative to the directive, not to it's root
					parsed_parent[$parsed_segment]="${lines["${lines["$line_number,parentline"]},segment"]}";
				fi
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
				if [[ "${lines["$line_number,type"]}"  ]]; then
					parsed_type[$parsed_segment]="${lines["$line_number,type"]}"
				else
					parsed_type[$parsed_segment]=text
				fi
			fi

			if [[ "${parsed_text[$parsed_segment]}" ]]; then
				parsed_text[$parsed_segment]+="
"
			fi
			if [[ -z "${parsed_parent[$parsed_segment]}" && "${lines["$line_number,parentblock"]}" && "$parsed_segment" != "${lines["${lines["$line_number,parentblock"]},segment"]}" ]]; then
				parsed_parent[$parsed_segment]="${lines["${lines["$line_number,parentblock"]},segment"]}" #"${lines["${lines["$line_number,parentline"]},type"]}"
			fi
			
			lines["$line_number,segment"]=$parsed_segment
			parsed_text[$parsed_segment]+="$(space_x_times "${lines["$line_number,indentation"]}")${lines["$line_number,value"]}"

		# elif [[ "${lines["$((line_number - 1)),type"]}"==empty ]]; then
			# TODO: two consecutive empty lines break a segment
			# ((parsed_segment++))
			# parsed_type[$parsed_segment]="${lines["${lines["$prev_line_number,parentline"]},type"]}" #"${lines["${lines["$line_number,parentline"]},type"]}"
		fi

		# if [[ ${parsed_type[$parsed_segment]} ==  ]]; then
		# 	#statements
		# fi
		
		#[[ $VERBOSE -ge 2 && $INVOKED_COUNT -le 2 ]] && ( echo "$line" )
		[[ $VERBOSE -ge 2 && $INVOKED_COUNT -le 2 ]] && ( echo -e "$line_number.\t(${lines["$line_number,length"]})\t<p:${lines["$line_number,parentline"]}><b:${lines["$line_number,parentblock"]}><s:${lines["$line_number,segment"]}>\t[${lines["$line_number,type"]}]\t\t${lines["$line_number,name"]}\t${lines["$line_number,value"]}" )

		((line_number++))
	done < "$file"

	total_lines=$line_number

}

# todo:
#
# example_operation.module = example.operation
# example_operation.module.synopsis = An example operation.
# example_operation.module.platform = raring
#
# module.description = This is an example of a long description.
# 						It can span over multiple lines.
# 						And we can use **coloring** *like* that.
#
# 						More info on possibilities:
# 						http://sphinx-doc.org/domains.html
#
# variables.envvar.1 = HOSTNAME
# variables.envvar.2 = BLABLA
