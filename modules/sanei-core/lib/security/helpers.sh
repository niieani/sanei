#!/bin/bash
generate_passphrase() {
    # http://cl4ssic4l.wordpress.com/2011/05/12/generate-strong-password-inside-bash-shell/
    local l=$1
    [ "$l" == "" ] && l=20
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}
