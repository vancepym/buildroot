Buildroot: making Embedded Linux easy
=========

Buildroot is a set of Makefiles and patches that makes it easy to generate a complete embedded Linux system. Buildroot can generate any or all of a cross-compilation toolchain, a root filesystem, a kernel image and a bootloader image. Buildroot is useful mainly for people working with small or embedded systems, using various CPU architectures (x86, ARM, MIPS, PowerPC, etc.) : it automates the building process of your embedded system and eases the cross-compilation process.

## Official Buildroot

### Buildroot official website

http://buildroot.net/

### Browse official source

http://git.buildroot.net/buildroot/

### Clone official repository

    $ git clone git://git.buildroot.net/buildroot

## Customizing for Cubieboard
    $ git clone https://github.com/vancepym/buildroot.git -b cubieboard/2013.02.x
    $ make cubieboard_defconfig
    $ make
