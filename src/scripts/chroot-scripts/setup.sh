#!/bin/bash

. /build/prepare.sh

CLFS_SOURCES=/sources

function log () {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1 ..."
}

function yexit () {
    echo "[EE] 在 $1 时返回 $2"
    return $2 # TODO
}


function prepare() {

    cd $CLFS_SOURCES

    if [ -z "$DECOMPRESS_NAME" ]; then
        DECOMPRESS_NAME="$NAME-$VERSION"
    fi

    if [ -z "$PACKAGE" ]; then
        for suffix in .tar.bz2 .tar.gz .tgz; do
            N="${NAME}-${VERSION}${suffix}"
            if [ -f $N ]; then
                PACKAGE=$N
                break
            fi
        done
    fi

    if [ -f "$PACKAGE" ]; then
        # TODO
        [ -d "$DECOMPRESS_NAME" ] || tar xf $PACKAGE
        # 进入目录
        cd $DECOMPRESS_NAME
    else
        echo "=> $PACKAGE 不存在！"
        yexit prepare 21
    fi

}


function build () {
    ./configure --prefix=/ || yexit build 31
    make || yexit build 32
    make install || yexit build 33
}


function clean () {
    cd $CLFS_SOURCES
    [ -d "$NAME-build" ] && rm -rf $NAME-build
    [ -d "$NAME-$VERSION" ] && rm -rf "$NAME-$VERSION"
    true # TODO
}


function ypm_build () {

    echo "=> Build $1"

    YC_FILE=${YC_DIR}/${1}.yc

    if [ ! -f $YC_FILE ]; then
        echo "[EE] 没有找到 $YC_FILE"
        break
    fi

    . $YC_FILE

    check_macro CLFS_SOURCES NAME VERSION SIZE HOME URL MD5

    TIME_TOTAL_START=$(date +%s)

    clean

    log prepare
    prepare || return 41

    log build
    build || return 42

    log clean
    clean || return 43

    TIME_TOTAL_END=$(date +%s)
    TIME_TOTAL=$((TIME_TOTAL_END - TIME_TOTAL_START))

    echo "[II] 编绎 $1 成动，加入 $CLFS_SUCCESS"
    echo "$(basename $1) $TIME_TOTAL" >> $CLFS_SUCCESS

}

# Main

CLFS_LOG=/build/logs/
CLFS_SUCCESS=/.success
YC_DIR=/build/YC/

mkdir -pv $CLFS_LOG
touch $CLFS_SUCCESS


while read x; do

    [ -z "$x" ] && continue

    if grep "^$x" $CLFS_SUCCESS > /dev/null 2>&1; then
        echo "=> [OK] $x"
        continue
    fi

    ypm_build $x | tee ${CLFS_LOG}/$x.log

    if [ $? -ne 0 ]; then
        echo "[EE] 编绎 $x 失败"
        break
    fi

done <<EOF
tcl
expect
dejagnu
perl
linux-headers
man-pages
eglibc
gmp
mpfr
mpc
ppl
cloog-ppl
zlib
binutils
gcc
sed
ncurses
glib
pkg-config
util-linux
e2fsprogs
coreutils
iana-etc
m4
bison
procps
libtool
flex
iproute2
perl-final
readline
autoconf
automake
bash
bzip2
diffutils
file
findutils
gawk
gettext
grep
groff
gzip
EOF


# 非常重要，安装完 eglic 后执行
#gcc -dumpspecs | \
#perl -p -e 's@/tools/lib/ld@/lib/ld@g;' \
#     -e 's@\*startfile_prefix_spec:\n@$_/usr/lib/ @g;' > \
#     $(dirname $(gcc --print-libgcc-file-name))/specs

#echo 'main(){}' > dummy.c
#gcc dummy.c
#readelf -l a.out | grep ': /lib'

# 上相面的输出应该是:
#      [Requesting program interpreter: /lib/ld-linux.so.2]


#rm -v dummy.c a.out


# 编绎 binutils 前
# 运行 expect -c "spawn ls"
# 如果结果为 spawn ls 说明配置OK


# 安装完 bash 后运行
# exec /bin/bash --login +h