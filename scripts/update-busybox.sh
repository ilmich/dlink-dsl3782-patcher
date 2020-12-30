#!/bin/bash -e

BUSYBOX_VERSION=1.25.0
BUSYBOX_URL="https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2"
BUSYBOX_TAR=busybox-$BUSYBOX_VERSION.tar.bz2

if [ $UID != "0" ]; then
    echo "You must be logged as root!!!"
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "usage: $0 path_to_romfs"
    exit 1
fi

ROMFS=$1

if [ ! -x $ROMFS ]; then
    echo "Path $ROMFS not found"
    exit 1
fi

#echo "Try dhcpc old"
#(

#cd $ROMFS/sbin

#cp ../bin/busybox busybox.orig
#rm udhcpc
#ln -s busybox.orig udhcpc

#)

echo "Build busybox"
(

#cp $ROMFS/bin/busybox $ROMFS/bin/busybox.orig
#rm $ROMFS/sbin/udhcpc


cd src/

if [ ! -e $BUSYBOX_TAR ]; then
	wget $BUSYBOX_URL -O $BUSYBOX_TAR
fi

rm -rf busybox-$BUSYBOX_VERSION
tar xvf $BUSYBOX_TAR
cd busybox-$BUSYBOX_VERSION

cp ../../scripts/busybox-$BUSYBOX_VERSION-dlink .config

sed -i 's/config %/%/g' Makefile
sed -i 's/\/ %/%/g' Makefile
sed -i 's/\/etc\/inittab/\/usr\/etc\/inittab/g' init/init.c
sed -i 's/\/etc\/fstab/\/usr\/etc\/fstab/g' util-linux/mount.c

#patch -p1 < ../../scripts/ip-neigh-patch.diff

make install V=1 CFLAGS=" --sysroot=$TOOLCHAIN_PATH " \
		LDFLAGS=" --sysroot=$TOOLCHAIN_PATH " \
		CONFIG_EXTRA_CFLAGS=" --sysroot=$TOOLCHAIN_PATH " \
		CROSS_COMPILE=mips-linux-uclibc- \
		CONFIG_PREFIX=$ROMFS
#make install -j2 V=1 CONFIG_EXTRA_CFLAGS="-s --sysroot=$TOOLCHAIN_PATH" CROSS_COMPILE=mips-linux-uclibc- CONFIG_PREFIX=$ROMFS
read

)

echo "Installing busybox"
cp src/busybox-$BUSYBOX_VERSION/busybox $ROMFS/bin/busybox