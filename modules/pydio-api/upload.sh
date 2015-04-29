file="$1";
#optional:
PYDIO_REPOSITORY="my-files";
PYDIO_TARGET_DIR="/";
PYDIO_AUTORENAME="false";

curl \
    -u "$PYDIO_LOGIN:$PYDIO_PASSWORD" \
    --upload-file "$file" \
    --header "X-File-Name:$(basename '$file')" \
    "$PYDIO_HOST/api/${PYDIO_REPOSITORY}/upload/input_stream${PYDIO_TARGET_DIR}?auto_rename=${PYDIO_AUTORENAME}" \
    > /dev/null # redirect required to show a progress bar
