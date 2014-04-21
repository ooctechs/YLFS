#!/bin/bash

# TODO: 是否是 root 用户 ?

if [ $UID -ne 0 ]; then
    echo "只有 root　才有权限"
    exit 11
fi

# 全局变量

CLFS=/mnt/clfs
CLFS_SOURCES=${CLFS}/sources
CLFS_TOOLS=${CLFS}/tools
CLFS_CROSS_TOOLS=${CLFS}/cross-tools

CLFS_USER=clfs
CLFS_GROUP=clfs
CLFS_USER_HOME=/home/$CLFS_USER

export CLFS CLFS_SOURCES

cat <<EOF
=> 当前全局变量
   CLFS = $CLFS
   CLFS_SOURCES = $CLFS_SOURCES
   CLFS_TOOLS = $CLFS_TOOLS
   CLFS_CROSS_TOOLS = $CLFS_CROSS_TOOLS
   CLFS_USER = $CLFS_USER
   CLFS_GROUP = $CLFS_GROUP
   CLFS_USER_HOME = $CLFS_USER_HOME
EOF


# 准备目录

if [ -d $CLFS ]; then
    echo "=> $CLFS 目录己经存在"
else
    echo "=> $CLFS 不存在，创建之"
    mkdir -pv $CLFS || exit 11
fi


if [ ! -d $CLFS_SOURCES ]; then
    mkdir -pv $CLFS_SOURCES
    chmod -v a+wt $CLFS_SOURCES
fi


if [ ! -d $CLFS_TOOLS ]; then
    install -dv $CLFS_TOOLS
    ln -sv $CLFS_TOOLS /
fi

if [ ! -d $CLFS_CROSS_TOOLS ]; then
    install -dv $CLFS_CROSS_TOOLS
    ln -sv $CLFS_CROSS_TOOLS /
fi


# 创建一个 clfs 用户和组

if ! id $CLFS_USER > /dev/null 2>&1 ; then
    groupadd $CLFS_GROUP
    useradd -s /bin/bash -g $CLFS_GROUP -d $CLFS_USER_HOME $CLFS_USER
    mkdir -pv $CLFS_USER_HOME
    chown -v $CLFS_USER:$CLFS_GROUP $CLFS_USER_HOME
    chown -v $CLFS_USER $CLFS_TOOLS
    chown -v $CLFS_USER $CLFS_CROSS_TOOLS
    chown -v $CLFS_USER $CLFS_SOURCES
fi


# 也许还要设置密码
#passwd $CLFS_USER

# 创建 .bash_profile
cat > $CLFS_USER_HOME/.bash_profile << "EOF"
exec env -i HOME=${HOME} TERM=${TERM} PS1='\u:\w\$ ' /bin/bash
EOF

# TODO: 创建 .bashrc
# TODO: 确认 "set +h" 关闭 shell 的 hash 记忆功能的必要性
cat > $CLFS_USER_HOME/.bashrc << "EOF"
set +h
umask 022
CLFS=/mnt/clfs
LC_ALL=POSIX
PATH=/cross-tools/bin:/bin:/usr/bin
export CLFS LC_ALL PATH
unset CFLAGS
unset CXXFLAGS
export CLFS_HOST=$(echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/')
export CLFS_TARGET="i686-pc-linux-gnu"
EOF

# 注意 "EOF" 用引号就关闭了变量替换功能！
cat >> $CLFS_USER_HOME/.bashrc <<EOF
CLFS_SOURCES=$CLFS_SOURCES
CLFS_TOOLS=$CLFS_TOOLS
CLFS_CROSS_TOOLS=$CLFS_CROSS_TOOLS
export CLFS_SOURCES CLFS_TOOLS CLFS_CROSS_TOOLS
EOF


# 可能的 target triplet 是
# 386 Compatibles	             | Not Supported By Glibc
# 486 Compatibles	             | i486-pc-linux-gnu
# Pentium, K6, 586 Compatibles	     | i586-pc-linux-gnu
# Pentium II, Pentium III, Pentium 4 | i686-pc-linux-gnu
# Athlon, Duron	                     | i686-pc-linux-gnu

### 切换用户
##CLFS_SCRIPTS=/opt/CLFS/scripts/
##CLFS_SUCCESS=$CLFS/.success
##CLFS_LOG=/opt/CLFS/logs/
##
##[ -d $CLFS_LOG ] || mkdir -pv $CLFS_LOG
##
##[ -f $CLFS_SUCCESS ] || touch $CLFS_SUCCESS
##
##while read x; do
##
##    [ -z "$x" ] && continue
##
##    if grep "$x" $CLFS_SUCCESS > /dev/null 2>&1; then
##        echo "=> [OK] $x"
##        continue
##    fi
##
##    echo "=> Build $x"
##    su $CLFS_USER -c "$CLFS_SCRIPTS/wrap-command.sh $x" | tee ${CLFS_LOG}/$x.log
##
##    if [ $? -ne 0 ]; then
##        echo "[EE] build $x failed"
##        break
##    fi
##
##done <<EOF
##linux-headers
##file
##m4
##ncurses
##gmp
##mpfr
##mpc
##ppl
##cloog-ppl
##binutils
##gcc
##eglibc
##gcc-final
##EOF
##
##
##echo "现在用户是: $USER"
##
