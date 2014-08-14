#!/bin/bash
# dialog:
dialog_setup_vars(){
    : ${DIALOG=dialog}
    : ${DIALOG_OK=0}
    : ${DIALOG_CANCEL=1}
    : ${DIALOG_HELP=2}
    : ${DIALOG_EXTRA=3}
    : ${DIALOG_ITEM_HELP=4}
    : ${DIALOG_ESC=255}
}
dialog_setup_tempfile(){
    tempfile=$(tempfile 2>/dev/null) || tempfile=/tmp/test$$
    trap "rm -f $tempfile" 0 1 2 5 15
}
dialog_selector_generate(){
    dialog_setup_vars
    dialog_setup_tempfile
    local title=$1
    local text=$2
    local values=$3

    DIALOG_CMD="$DIALOG --backtitle "SANEi" --title '"$(echo $title)"' --checklist '"$(echo "$text \n\nPress SPACE to toggle a value on/off.")"' 20 50 10 $values 2> $tempfile"
    eval $DIALOG_CMD
    return $?
}
