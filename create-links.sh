#!/bin/bash

CURDIR="$( cd `dirname "${BASH_SOURCE[0]}"` && pwd )"
source $CURDIR/functions.sh

for module in list_installed
do
    # recursive linking #
    link_all_files_recursive $SCRIPT_DIR/modules/$module/etc $TEMPLATE_ROOT/etc

    # recursive copying and filling #
    fill_template_recursive $SCRIPT_DIR/modules/$module/etc-template $TEMPLATE_ROOT/etc

    # non-recursive linking of folders #
    link_all_dirs $SCRIPT_DIR/modules/$module/etc-link $TEMPLATE_ROOT/etc

    if [[ -d $SCRIPT_DIR/modules/$module/usr ]]; then
        copy_all_files_recursive $SCRIPT_DIR/modules/$module/usr $TEMPLATE_ROOT/usr
    fi

    # dotfiles
    if [[ -d $SCRIPT_DIR/modules/$module/root ]]; then
        link_all_files $SCRIPT_DIR/modules/$module/root $TEMPLATE_ROOT/root
        # link also folders #
        link_all_dirs $SCRIPT_DIR/modules/$module/root $TEMPLATE_ROOT/root
    fi

    if [[ -f $SCRIPT_DIR/modules/$module/post-update.sh ]]; then
        source $SCRIPT_DIR/modules/$module/post-update.sh
    fi
done
