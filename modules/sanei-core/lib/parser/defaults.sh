#!/bin/bash
# TODO: belongs to parser
source_parsed_fields(){
    local all_vars="$1"
    local output_prefix="${2:-VAR_}"
    local output_temp_path="${3:-/tmp}"

    for key in ${all_vars}; do
        field_name="${output_prefix}$(sanitize "$key")"

        # field_name="$(sanitize "$key")"
        if [[ $VERBOSE -gt 4 ]]; then
            echo Exporting field "$field_name", with the value "$(cat "$output_temp_path/$field_name")"
        fi
        export "$field_name"="$(cat "$output_temp_path/$field_name")"
        # export "$field_name"="$(cat "$output_temp_path/$key")"
        rm "$output_temp_path/$field_name"
        # rm "$output_temp_path/$key"
    done
    # echo OPICA $PARSED_relaymail_MODULE
}
sanei_parsing_info(){
    local module="$1"
    local operation="$2"
    local var_prefix="${3:-PARSED_${module}_}"
    #echo parsing "$MODULES_DIR/$module/README.rst"
    if [[ -f "$MODULES_DIR/$module/README.rst" ]]; then
        NO_SUBSHELL=true sanei_invoke_module_script sanei parse-raw "$MODULES_DIR/$module/README.rst" "$var_prefix"
        # source_parsed_fields "${var_prefix}FIELDS_LIST" "$var_prefix"
        source_parsed_fields "$PARSED_FIELDS_LIST" "$var_prefix"

        # declare -p PARSED_FIELDS_LIST
        # echo "$var_prefix"
    fi
    if [[ -f "$MODULES_DIR/$module/$operation.sh" ]]; then
        NO_SUBSHELL=true sanei_invoke_module_script sanei parse-sh "$MODULES_DIR/$module/$operation.sh" "$var_prefix"
        source_parsed_fields "$PARSED_FIELDS_LIST" "$var_prefix"

        # declare -p PARSED_FIELDS_LIST
        # echo "$var_prefix"
    fi
    # echo OPICA $PARSED_relaymail_MODULE
}