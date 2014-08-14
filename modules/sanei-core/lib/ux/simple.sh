#!/bin/bash

asksure(){
    local text=$1
    echo -n "$text (Y/N)? "
    while read -r -n 1 answer; do
      if [[ $answer = [YyNn] ]]; then
        [[ $answer = [Yy] ]] && retval=0
        [[ $answer = [Nn] ]] && retval=1
        break
      fi
    done
    echo # just a final linefeed, optics...
    return $retval
}
askbreak(){
    if [[ $SILENT -eq true ]]; then
        local text=$1
        if ! asksure "$text"; then
            exit 1
        fi
    else
        echo "$text (Y)."
    fi
}