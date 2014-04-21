#!/bin/bash

# TODO: 是否是 root 用户 ?

if [ $UID -ne 0 ]; then
    echo "只有 root　才有权限"
    exit 11
fi

. prepare.sh

CLFS_SCRIPTS=/opt/CLFS/scripts/
CLFS_SUCCESS=$CLFS_SCRIPTS/cross_tools/.success
CLFS_LOG=/opt/CLFS/logs/cross-tools/

[ -d $CLFS_LOG ] || mkdir -pv $CLFS_LOG

[ -f $CLFS_SUCCESS ] || touch $CLFS_SUCCESS

CLFS_CROSS_TOOLS_SCRIPTS=${CLFS_SCRIPTS}/cross-tools/

while read x; do

    [ -z "$x" ] && continue

    if grep "$x" $CLFS_SUCCESS > /dev/null 2>&1; then
        echo "=> [OK] $x"
        continue
    fi

    echo "=> Build $x"
    YC=${CLFS_CROSS_TOOLS_SCRIPTS}/${x}.yc

    su $CLFS_USER -c "$CLFS_SCRIPTS/wrap-command.sh $YC" | tee ${CLFS_LOG}/$x.log

done <<EOF
linux-headers
file
m4
ncurses
gmp
mpfr
mpc
ppl
cloog-ppl
binutils
gcc
eglibc
gcc-final
EOF


echo "现在用户是: $USER"

