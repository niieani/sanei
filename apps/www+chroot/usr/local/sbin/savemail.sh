#!/bin/bash
# for debugging sendmail
LOG="/tmp/mail.log"
while read -r -a array; do
    echo ${array[*]} >> ${LOG}
done
