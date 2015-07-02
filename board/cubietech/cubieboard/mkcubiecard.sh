#!/bin/sh
### BEGIN INTRO
# mkcubiecard.sh v0.2:
# 2015, Scott Fan <fancp2007@gmail.com>
# rewrite this script more clear;
# add the 'netboot' argument, to make a network-bootable card.
# mkCubieCard.sh v0.1:
# 2013, Carlo Caione <carlo.caione@gmail.com>
# heavely based on :
# mkA10card.sh v0.1
# 2012, Jason Plum <jplum@archlinuxarm.org>
# loosely based on :
# mkcard.sh v0.5
# (c) Copyright 2009 Graeme Gregory <dp@xora.org.uk>
# Licensed under terms of GPLv2
#
# Bootable SD card
# http://linux-sunxi.org/Bootable_SD_card
#
# Parts of the procudure base on the work of Denys Dmytriyenko
# http://wiki.omap.com/index.php/MMC_Boot_Format
### END INTRO

IMAGES_DIR=$1
DRIVE=$2
NETBOOT=$3

SPL_IMG=$IMAGES_DIR/sunxi-spl.bin
SPL_UBOOT=$IMAGES_DIR/u-boot-sunxi-with-spl.bin
UBOOT_IMG=$IMAGES_DIR/u-boot.bin
UBOOT_ENV=$IMAGES_DIR/u-boot-env.bin
UIMAGE=$IMAGES_DIR/uImage
BIN_BOARD_FILE=$IMAGES_DIR/script.bin
ROOTFS=$IMAGES_DIR/rootfs.tar
BOOT_CMD_H=$IMAGES_DIR/boot.scr

export LC_ALL=C

if [ $# -lt 2 ]; then
	echo "Usage: $0 <images_dir> <drive> [netboot: yes|no]"
	exit 1;
fi

if [ `id -u` -ne 0 ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

if [ ! -f $SPL_IMG  -a ! -f $SPL_UBOOT ] ||
   [ ! -f $UBOOT_IMG ] ||
   [ ! -f $UBOOT_ENV ] ||
   [ ! -f $UIMAGE ] ||
   [ ! -f $BIN_BOARD_FILE ] ||
   [ ! -f $ROOTFS ] ||
   [ ! -f $BOOT_CMD_H ]; then
	echo "File(s) missing."
	exit 1
fi


####################
# Preparing
####################
echo `fdisk -l $DRIVE | grep Disk | grep bytes`

# erase the first part of your card except the partition table
echo "\n>>>> Erasing the first part of $DRIVE ..."
dd if=/dev/zero of=$DRIVE bs=1024 count=1023 seek=1

####################
# Bootloader
####################
if [ -e $SPL_UBOOT ]; then
	echo "\n>>>> Writing $SPL_UBOOT ..."
	dd if=$SPL_UBOOT of=$DRIVE bs=1024 seek=8
else
	# write SPL
	echo "\n>>>> Writing $SPL_IMG ..."
	dd if=$SPL_IMG of=$DRIVE bs=1024 seek=8
	# write u-boot
	echo "\n>>>> Writing $UBOOT_IMG ..."
	dd if=$UBOOT_IMG of=$DRIVE bs=1024 seek=32
fi

if [ "xyes" = "x$NETBOOT" ]; then
	# write environment for netboot
	echo "\n>>>> Writing $UBOOT_ENV ..."
	dd if=$UBOOT_ENV of=$DRIVE bs=1024 seek=544
	exit 0
fi

####################
# Partitioning
####################
# a 16MB boot partition starting at 1MB,
# and the rest as rootfs partition
echo "\n>>>> Partitioning ..."
sfdisk -R $DRIVE
cat <<EOT | sfdisk --in-order -L -uM $DRIVE
1,16,c
,,L
EOT

sleep 1

# format the first partition
[ -b ${DRIVE}1 ] && D1=${DRIVE}1
[ -b ${DRIVE}p1 ] && D1=${DRIVE}p1

if [ -n $D1 ]; then
	echo "\n>>>> Formatting boot partition $D1 ..."
	mkfs.vfat -v -n "BOOT" $D1
else
	echo "Cannot find boot partition in /dev"
	exit 1
fi

# format the second partition
[ -b ${DRIVE}2 ] && D2=${DRIVE}2
[ -b ${DRIVE}p2 ] && D2=${DRIVE}p2

if [ -n $D2 ]; then
	echo "\n>>>> Formatting rootfs partition $D2 ..."
	mkfs.ext4 -v -L "Cubie" $D2
else
	echo "Cannot find rootfs partition in /dev"
	exit 1
fi

echo ">>>> Writing boot files and rootfs files ..."

P1=`mktemp -d`
P2=`mktemp -d`

mount $D1 $P1
mount $D2 $P2

# write uImage
cp $UIMAGE $P1
# write board file
cp $BIN_BOARD_FILE $P1
# write u-boot script
cp $BOOT_CMD_H $P1
# write rootfs
tar -C $P2 -xvf $ROOTFS

sync

umount $D1
umount $D2

rm -fr $P1
rm -fr $P2

echo "All completed."
