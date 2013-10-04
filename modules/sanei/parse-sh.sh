# :Author: Bazyli Brzoska
# :Variables: - SCRIPT_DIR
# :Modules: - sanei
# :Recommended modules: - apt:python-pygments
# :Description: something

# BASHDOC_LIB="$SCRIPT_DIR/vendor/bashdoc/lib"

source_file="$1"
output_prefix="${2:-VAR_}"
temp_file="/tmp/doc.rst"

# prepare the file
$VENDOR_DIR/bashdoc/bashdoc -o "$temp_file" -H better.basic raw "$source_file"

# invoke parsing
sanei_invoke_module_script sanei parse-raw "$temp_file" "$output_prefix"
rm "$temp_file"