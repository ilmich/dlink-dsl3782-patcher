#!/bin/bash -e

DROPBEAR_VERSION=2018.76
DROPBEAR_URL="https://matt.ucc.asn.au/dropbear/releases/dropbear-$DROPBEAR_VERSION.tar.bz2"
DROPBEAR_TAR=dropbear-$DROPBEAR_VERSION.tar.bz2

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

echo "Build dropbear"
(

cd src/

if [ ! -e $DROPBEAR_TAR ]; then
	wget $DROPBEAR_URL -O $DROPBEAR_TAR
fi

rm -rf dropbear-$DROPBEAR_VERSION
tar xvf $DROPBEAR_TAR
cd dropbear-$DROPBEAR_VERSION

CFLAGS=" --sysroot=$TOOLCHAIN_PATH -s" \
CXXFLAGS=" --sysroot=$TOOLCHAIN_PATH -s " \
LDFLAGS=" --sysroot=$TOOLCHAIN_PATH -s" \
CPP="mips-linux-uclibc-cpp --sysroot=$TOOLCHAIN_PATH" \
./configure \
  --prefix=/usr \
  --libdir=/lib \
  --docdir=/usr/doc/$PRGNAM-$VERSION \
  --includedir=/usr/include \
  --disable-lastlog \
  --disable-utmp \
  --disable-utmpx \
  --disable-wtmp \
  --disable-wtmpx \
  --disable-harden \
  --disable-zlib \
  --disable-shadow \
  --host=mips-linux-uclibc

make V=1 PROGRAMS="dropbear"

)

echo "Installing dropbear"
cp src/dropbear-$DROPBEAR_VERSION/dropbear $ROMFS/userfs/bin/dropbear