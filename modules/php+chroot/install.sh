sanei_resolve_dependencies php
sanei_create_module_dir
mkdir -p "$LOCAL_MODULE_DIR/skel/bin" "$LOCAL_MODULE_DIR/skel/dev" "$LOCAL_MODULE_DIR/skel/etc" "$LOCAL_MODULE_DIR/skel/lib" "$LOCAL_MODULE_DIR/skel/lib64" "$LOCAL_MODULE_DIR/skel/run" "$LOCAL_MODULE_DIR/skel/srv/public" "$LOCAL_MODULE_DIR/skel/srv/log" "$LOCAL_MODULE_DIR/skel/tmp/sessions" "$LOCAL_MODULE_DIR/skel/usr"
chmod 777 "$LOCAL_MODULE_DIR/skel/tmp"
chmod 700 "$LOCAL_MODULE_DIR/skel/tmp/sessions"
# tar -xf "$MODULE_DIR/templates/skel.chroot.tar" -C "$LOCAL_MODULE_DIR"
addgroup sftp