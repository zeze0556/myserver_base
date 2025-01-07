#!/bin/bash

DISK=$1

mkfs.ext4 -L mynas $DISK
mount -t ext4 $DISK /tmp/mnt
echo "/ union" >> /tmp/mnt/persistence.conf
umount /tmp/mnt
