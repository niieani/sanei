# $1 (required) is URL
# $2 (required) is the target filename without the file extension
# TODO: add youtube_dl
non_default_setting_needed WEBSITE_ARCHIVER_DIR
create_directory_structure "$WEBSITE_ARCHIVER_DIR/$2"
phantomjs $MODULE_DIR/phantomjs/rasterize.js "$1" "$WEBSITE_ARCHIVER_DIR/$2"