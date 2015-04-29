remotePath="$1";
customHandle="$2";

#optional:
PYDIO_REPOSITORY="my-files";

# TODO: extra options:
# password=abc
# expiration=4 (number of days

downloadUrl=$(curl \
    -u server:whJkmRs7G8aoVPyYuJVnvA \
     -X POST \
    "$PYDIO_HOST/api/${PYDIO_REPOSITORY}/share/public_link/${remotePath}?downloadlimit=1&custom_handle=${customHandle}");

echo Your file can be downloaded from: 
echo ${downloadUrl}?dl=true
