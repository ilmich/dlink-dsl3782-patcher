#!/bin/bash -e

PWD=`pwd`

TOOLCHAIN_PATH=$PWD/toolchain/mips-linux-uclibc/
KERNEL_STARTADDR='\x80\x00\x20\x00'

if [ $UID != "0" ]; then
    echo "You must be logged as root!!!"
    exit 1
fi

for i in binwalk tcrevenge unsquashfs mksquashfs; do
	if [ -z $(command -v $i) ]; then
		echo "$i not found!"
		exit 1
	fi
done

KERNEL_OFFSET=256
TMPDIR=tmp
OUTDIR=out

if [ ! -x $TMPDIR ]; then
	mkdir $TMPDIR
fi

if [ ! -x $OUTDIR ]; then
	mkdir $OUTDIR
fi

# find squashfs offset
dd if=tclinux.bin of=$TMPDIR/squash_offset skip=$((0x50)) bs=1 count=4
SQUASHFS_OFFSET=$((0x`cat $TMPDIR/squash_offset | xxd -p `))
SQUASHFS_OFFSET=$(($SQUASHFS_OFFSET + 256 ))

echo "Extracting kernel at offset $KERNEL_OFFSET with size $(($SQUASHFS_OFFSET - 256)) "
dd if=tclinux.bin skip=$KERNEL_OFFSET of=$OUTDIR/kernel bs=1 count=$(($SQUASHFS_OFFSET - 256))  status=progress

echo "Extracting squashfs at offset $SQUASHFS_OFFSET  "
dd if=tclinux.bin skip=$SQUASHFS_OFFSET of=$TMPDIR/squashfs bs=1 status=progress

echo "Decompressing squashfs"
rm -rf $TMPDIR/romfs
unsquashfs -d $TMPDIR/romfs $TMPDIR/squashfs 

for i in `ls scripts/*.sh`; do
	if [ -x $i ]; then
		PATH=$TOOLCHAIN_PATH/usr/bin:$PATH TOOLCHAIN_PATH=$TOOLCHAIN_PATH $i $TMPDIR/romfs
	fi
done

mksquashfs $TMPDIR/romfs $OUTDIR/squashfs.out -comp lzma -nopad -noappend
tcrevenge -k $OUTDIR/kernel -s $OUTDIR/squashfs.out -o $OUTDIR/header.bin -p $OUTDIR/padding.bin -m "3 6035 122 0" -b "\"v1.04\""
cat $OUTDIR/header.bin $OUTDIR/kernel $OUTDIR/squashfs.out $OUTDIR/padding.bin > $OUTDIR/tclinux.bin

# put kernel base address
printf $KERNEL_STARTADDR | dd of=$OUTDIR/tclinux.bin bs=1 seek=124 conv=notrunc

echo "Cleanup"
rm $OUTDIR/header.bin $OUTDIR/kernel $OUTDIR/squashfs.out $OUTDIR/padding.bin
rm -r $TMPDIR

echo "Done.. your new firmware is $OUTDIR/tclinux.bin"
