#!/bin/bash
set -ex
cmd=${1:-mount_p}
outfile=${2:-mynas_persistentce.dat}

function create()
{
    unmount_p
    tools/CreatePersistentImg.sh -s 10240 -t ext4 -l mynas -c persistence.conf -o $outfile
}

function mount_p()
{
    freeloop=$(losetup -f)
    filename=${outfile%.*}
    unmount_p
    losetup $freeloop "$outfile"
    mkdir -p $filename
    if mount $freeloop ./$filename; then
        echo "mount ok"
    fi
}

function unmount_p()
{
    echo "umount"
    filename=${outfile%.*}
    umount ./$filename || echo "umount done"
    for i in `losetup -l| grep "$outfile" | awk '{print $1}'`; do
        losetup -d $i
    done

}

$cmd
