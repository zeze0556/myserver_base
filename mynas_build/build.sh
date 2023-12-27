#!/bin/bash
set -e
lb clean
MIRROR=http://deb.debian.org/debian/
CODENAME=bookworm
BOOT="boot=live components persistence persistence-encryption=luks persistence-label=mynas quiet splash"
lb config --linux-packages linux-image-6.7.0-rc5 --linux-flavour rix \
   -d $CODENAME \
   --apt-options "--yes"\
   --distribution-chroot $CODENAME \
   --distribution-binary $CODENAME \
   --bootappend-live "$BOOT" \
   --apt-indices false --apt-recommends false --debootstrap-options "--variant=minbase" --firmware-chroot false \
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
