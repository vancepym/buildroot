#!/bin/sh
# post-image.sh for CubieBoard
# 2015, Scott Fan <fancp2007@gmail.com>
# 2013, Carlo Caione <carlo.caione@gmail.com>

BOARD_DIR="$(dirname $0)"
MKIMAGE=$HOST_DIR/usr/bin/mkimage
BOOT_CMD=$BOARD_DIR/boot.cmd
BOOT_CMD_H=$BINARIES_DIR/boot.scr

MKENVIMAGE=$HOST_DIR/usr/bin/mkenvimage
BOOT_ENV_SIZE=0x20000
BOOT_ENV_SRC=$BOARD_DIR/boot.env
BOOT_ENV_BIN=$BINARIES_DIR/u-boot-env.bin

# U-Boot script
if [ -e $MKIMAGE -a -e $BOOT_CMD ];
then
	$MKIMAGE -C none -A arm -T script -d $BOOT_CMD $BOOT_CMD_H
fi

# U-Boot environment
if [ -e $MKENVIMAGE -a -e $BOOT_ENV_SRC ];
then
	$MKENVIMAGE -s $BOOT_ENV_SIZE -o $BOOT_ENV_BIN $BOOT_ENV_SRC
fi
