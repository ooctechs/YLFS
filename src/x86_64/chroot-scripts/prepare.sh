#!/bin/bash

. /build/functions

function change_dir_owner () {
    chown -R 0:0 /tools
    chown -R 0:0 /cross-tools
}


function prepare_dir () {

    mkdir -pv /{bin,boot,dev,{etc/,}opt,home,lib,mnt}
    mkdir -pv /{proc,media/{floppy,cdrom},sbin,srv,sys}
    mkdir -pv /var/{lock,log,mail,run,spool}
    mkdir -pv /var/{opt,cache,lib/{misc,locate},local}
    install -dv -m 0750 /root
    install -dv -m 1777 {/var,}/tmp
    mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
    mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
    mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
    mkdir -pv /usr/{,local/}share/man/man{1..8}

    for dir in /usr{,/local}; do
        [ -d $dir/man ] || ln -sv share/{man,doc,info} $dir
    done

}


function create_essential_symlinks () {

    [ -f /bin/bash ] && return 0

    ln -sv /tools/bin/{bash,cat,echo,grep,pwd,stty} /bin
    ln -sv /tools/bin/file /usr/bin
    ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
    ln -sv /tools/lib/libstd* /usr/lib
    ln -sv bash /bin/sh
    ln -sv /run /var/run

    mkdir -pv /usr/lib64
    ln -sv /tools/lib/libstd*so* /usr/lib64
}


# Start Main

change_dir_owner
prepare_dir
create_essential_symlinks

[ -f /etc/passwd ] || cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/bin/false
daemon:x:2:6:daemon:/sbin:/bin/false
adm:x:3:16:adm:/var/adm:/bin/false
mail:x:30:30:mail:/var/mail:/bin/false
postmaster:x:51:30:postmaster:/var/spool/mail:/bin/false
nobody:x:65534:65534:nobody:/:/bin/false
EOF

[ -f /etc/group ] || cat > /etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
tape:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:root,adm,daemon
mail:x:30:mail
users:x:1000:
nogroup:x:65533:
nobody:x:65534:
EOF


[ -f /var/log/btmp ] || {
    touch /var/run/utmp /var/log/{btmp,lastlog,wtmp}
    chgrp -v utmp /var/run/utmp /var/log/lastlog
    chmod -v 664 /var/run/utmp /var/log/lastlog
    chmod -v 600 /var/log/btmp
}


check_mount /dev/pts || mount -vt devpts -o gid=4,mode=620 none /dev/pts
check_mount /dev/shm || mount -vt tmpfs none /dev/shm

