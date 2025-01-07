#!/bin/bash
set -e
lb clean
#MIRROR=http://deb.debian.org/debian/
MIRROR=https://mirrors.ustc.edu.cn/debian/
CODENAME=bookworm
#ip=frommedia
BOOT="boot=live components persistence persistence-label=mynas quiet splash pci=noaer pcie_aspm=off"
lb config --linux-packages linux-image-6.12.0 --linux-flavour rix \
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
