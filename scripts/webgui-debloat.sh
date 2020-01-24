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

echo "Removing mobile site (useless)"
rm -r $ROMFS/boaroot/html/mobile
rm -r $ROMFS/boaroot/cgi-bin/mobile

echo "Removing css source code (useless)"
rm -r $ROMFS/boaroot/html/scss

echo "Removing fonts"
rm -r $ROMFS/boaroot/html/layout/fonts
rm -r $ROMFS/boaroot/html/layout/New_GUI/fonts
rm $ROMFS/boaroot/html/layout/*.eot
rm $ROMFS/boaroot/html/layout/*.ttf

echo "Removing unused css"
rm $ROMFS/boaroot/html/layout/core-talktalk*.css

