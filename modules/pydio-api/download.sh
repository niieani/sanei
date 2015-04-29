remoteFile="$1";

#optional:
PYDIO_REPOSITORY="my-files";

curl \
    -u "$PYDIO_LOGIN:$PYDIO_PASSWORD" \
    --remote-name \
    "$PYDIO_HOST/api/${PYDIO_REPOSITORY}/download/${remoteFile}"