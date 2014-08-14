#!/bin/bash
enter_container(){
    local container=$1

    REAL_TEMPLATE_ROOT=$TEMPLATE_ROOT
    REAL_BACKUP_DIR=$BACKUP_DIR
    REAL_HOME_DIR=$HOME_DIR
    TEMPLATE_ROOT=/lxc/$container/rootfs
    BACKUP_DIR=$TEMPLATE_ROOT/root/.backups
    # we always want $HOME of containers to be /root
    HOME_DIR=/root
    CONTAINER_NAME=$container
    info "Entered container ${LIGHTBLUE}$CONTAINER_NAME${RESET}, with root: ${WHITE}$TEMPLATE_ROOT${RESET}."
}
exit_container(){
    TEMPLATE_ROOT=$REAL_TEMPLATE_ROOT
    BACKUP_DIR=$REAL_BACKUP_DIR
    HOME_DIR=$REAL_HOME_DIR
    info "Exited container ${LIGHTBLUE}$CONTAINER_NAME${RESET}."
    unset CONTAINER_NAME
}
sanei_updateall_containers(){
    # for each container that wants to have auto-updated links
    local containers=($(/usr/bin/lxc-ls -1))

    for container in ${containers[@]}
    do
        enter_container $container
            #TEMPLATE_ROOT=/lxc/$container/rootfs
            sanei_updateall
        exit_container
    done
}
sanei_all_containers_setinstalled(){
    sanei_override true true
}