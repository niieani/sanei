if is_installed php; then
    link $SCRIPT_DIR/modules/observium-client/local-php $TEMPLATE_ROOT$SANEI_DIR/observium-client/local
elif is_installed mysql; then
    link $SCRIPT_DIR/modules/observium-client/local-mysql $TEMPLATE_ROOT$SANEI_DIR/observium-client/local
else
    link $SCRIPT_DIR/modules/observium-client/local-default $TEMPLATE_ROOT$SANEI_DIR/observium-client/local
fi