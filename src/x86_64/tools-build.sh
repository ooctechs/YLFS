#!/bin/bash

# TODO: 是否是 root 用户 ?

if [ $UID -ne 0 ]; then
    echo "只有 root　才有权限"
    exit 11
fi

. prepare.sh

# 确保 CLFS 变量设置正确
if [ -z "$CLFS" ]; then
    echo "[EE] CLFS　未设置"
    exit 1
else
    if [ ! -d $CLFS ]; then
        echo "[EE] $CLFS 目录不存在"
        exit 2
    fi
fi


# 全局编绎设置
. $CLFS_USER_HOME/.bashrc # TODO
cat >> $CLFS_USER_HOME/.bashrc <<EOF
CC="${CLFS_TARGET}-gcc"
CXX="${CLFS_TARGET}-g++"
AR="${CLFS_TARGET}-ar"
AS="${CLFS_TARGET}-as"
RANLIB="${CLFS_TARGET}-ranlib"
LD="${CLFS_TARGET}-ld"
STRIP="${CLFS_TARGET}-strip"

export CC CXX AR AS RANLIB LD STRIP
EOF


CLFS_SCRIPTS=/mnt/a/CLFS/x86_64/
CLFS_SUCCESS=$CLFS_SCRIPTS/tools/.success
CLFS_LOG=$CLFS_SCRIPTS/tools/logs

[ -d $CLFS_LOG ] || mkdir -pv $CLFS_LOG

[ -f $CLFS_SUCCESS ] || touch $CLFS_SUCCESS
chmod 777 $CLFS_SUCCESS

CLFS_TOOLS_SCRIPTS=${CLFS_SCRIPTS}/tools/

while read x; do

    [ -z "$x" ] && continue

    if grep "$x" $CLFS_SUCCESS > /dev/null 2>&1; then
        echo "=> [OK] $x"
        continue
    fi

    echo "=> Build $x"
    YC=${CLFS_TOOLS_SCRIPTS}/${x}.yc

    if [ ! -f $YC ]; then
        echo "[EE] 没有找到 $YC"
        break
    fi

    su $CLFS_USER -c "$CLFS_SCRIPTS/wrap-command.sh $YC" | tee ${CLFS_LOG}/$x.log

    if [ $? -ne 0 ]; then
        echo "[EE] 编绎 $x 失败"
        break
    fi

done <<EOF
gmp
mpfr
mpc
ppl
cloog
zlib
binutils
gcc
ncurses
bash
bison
bzip2
coreutils
diffutils
findutils
file
flex
gawk
gettext
grep
gzip
m4
make
patch
sed
tar
texinfo
vim
xz
wget
EOF


echo "现在用户是: $USER"

