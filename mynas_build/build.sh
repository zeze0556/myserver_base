#!/bin/bash
set -e
#MIRROR=http://deb.debian.org/debian/
MIRROR=https://mirrors.ustc.edu.cn/debian/
CODENAME=bookworm
cmd=${1:-"build"}
#ip=frommedia
BOOT="boot=live components persistence persistence-label=mynas quiet splash pci=noaer pcie_aspm=off"
CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_VER="6.15.0-rc5"
function clean() {
    cd $CURDIR
    lb clean
}

function build() {
    cd $CURDIR
    lb clean
    lb config --linux-packages linux-image-$KERNEL_VER --linux-flavour rix \
       -d $CODENAME \
       --apt-options "--yes"\
       --distribution-chroot $CODENAME \
       --distribution-binary $CODENAME \
       --bootappend-live "$BOOT" \
       --mirror-bootstrap "$MIRROR" \
       --mirror-binary "$MIRROR" \
       --mirror-chroot "$MIRROR" \
       --debootstrap-options "--variant=minbase --include=apt-utils,ca-certificates,gnupg2" \
       --apt-indices false --apt-recommends false --firmware-chroot false \
       --debug

    #   --parent-distribution $CODENAME \
        #   --parent-distribution-chroot $CODENAME \
        #   --parent-distribution-binary $CODENAME \
        #   -m $MIRROR \
        #   --parent-mirror-chroot $MIRROR \
        #   --parent-mirror-binary $MIRROR \
        #   --mirror-bootstrap $MIRROR \
        #	 --mirror-binary $MIRROR \
        #   --mirror-chroot $MIRROR
    #lb config
    lb build --debug > a.log
    sync
}

$cmd
