#!/bin/bash

CLFS_SCRIPTS=$PWD


#. ~/.bash_profile
. ~/.bashrc

. ${CLFS_SCRIPTS}/build-prepare

if [ -f ${1} ]; then
    . ${1}
else
    echo "[EE] ${1} does not exist"
    yexit find_build_script 41
fi

cat <<EOF
CLFS = $CLFS
CLFS_TARGET = $CLFS_TARGET
CLFS_HOST = $CLFS_HOST

CLFS_SCRIPTS = $CLFS_SCRIPTS
YC = $1
EOF



# 有错误即终止
set -e

TIME_TOTAL_START=$(date +%s)

clean

log prepare
prepare

log build
build

log clean
clean

set +e

TIME_TOTAL_END=$(date +%s)
TIME_TOTAL=$((TIME_TOTAL_END - TIME_TOTAL_START))

SAVE_SUCCESS="$(dirname $1)/.success"

echo "[II] 编绎 $1 成动，加入 $SAVE_SUCCESS"
echo "$(basename $1) $TIME_TOTAL" >> $SAVE_SUCCESS

