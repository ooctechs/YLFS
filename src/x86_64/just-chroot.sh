#!/bin/bash -e

DEBUG=1

if [ -f /etc/ylinux.conf ]; then
    . /etc/ylinux.conf
else
    if [ -f ylinux.conf ]; then
        . ylinux.conf
    else
        echo "[EE] 未找到 ylinux.conf"
        exit -1
    fi
fi

if [ -f ${Y_CONFIG_DIR}/functions ]; then
    . ${Y_CONFIG_DIR}/functions
else
    echo "[EE] 未找到 ${Y_CONFIG_DIR}/functions"
    exit -1
fi

CLFS=/mnt/clfs


# chroot 之前需要挂载一些目录

function mount_dir () {

    check_macro CLFS
    check_dir $CLFS

    check_dir_create ${CLFS}/{dev,proc,sys}

    check_mount ${CLFS}/proc || mount -vt proc proc ${CLFS}/proc
    check_mount ${CLFS}/sys || mount -vt sysfs sysfs ${CLFS}/sys

    [ -c ${CLFS}/dev/console ] || mknod -m 600 ${CLFS}/dev/console c 5 1
    [ -c ${CLFS}/dev/null ] || mknod -m 666 ${CLFS}/dev/null c 1 3

    check_mount ${CLFS}/dev || mount -v -o bind /dev ${CLFS}/dev

    check_mount ${CLFS}/dev/shm || mount -f -vt tmpfs tmpfs ${CLFS}/dev/shm
    check_mount ${CLFS}/dev/pts || mount -f -vt devpts -o gid=4,mode=620 devpts ${CLFS}/dev/pts

}

# 测试 arch 是否可以 chroot 编绎指定的 target
function check_chroot_arch () {
    # 解开 automake 包，进入目录,运行下面命令，看其结果是否等于 CLFS_TARGET
    setarch linux32 lib/config.guess
    # 如果等于 CLFS_TARGET , 则可 chroot
}


# Start Main()

mount_dir

check_macro CHROOT_SCRIPTS
check_dir $CHROOT_SCRIPTS
check_dir_create ${CLFS}/build

cp -rf $CHROOT_SCRIPTS/* ${CLFS}/build/
cp -v ${Y_CONFIG_DIR}/functions ${CLFS}/build/


# Just Chroot
chroot ${CLFS} /usr/bin/env -i \
    HOME=/root TERM=${TERM} PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login
