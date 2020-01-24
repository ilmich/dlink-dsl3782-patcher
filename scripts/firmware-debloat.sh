#!/bin/bash 

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

echo "Remove useless software"
rm $ROMFS/userfs/bin/openssl
#rm $ROMFS/userfs/bin/bftpd
rm $ROMFS/bin/sqlite3
rm -r $ROMFS/usr/share/