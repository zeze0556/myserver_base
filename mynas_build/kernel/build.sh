#!/bin/bash

cmd=${1:-"build"}
bcachefs_dir="./bcachefs"
bcachefs_tools="./bcachefs-tools"

KERNEL_VERSION=""
TOOLS_VERSION="-b v1.13.0"
LOCALVERSION="-rix"
KERNEL_SOURCE="https://evilpiepirate.org/git/bcachefs.git"
CONFIG_FILE="../config"

function get_args() {
    while getopts "kernel_source:kernel_version:tools_versions:local_version:config" arg
    do
        case $arg in
            kernel_source)
                KERNEL_SOURCE=$OPTARG
                ;;
            kernel_version)
                KERNEL_VERSION=$OPTARG
                ;;
            tools_version)
                TOOLS_VERSION=$OPTARG
                ;;
            local_version)
                LOCALVERSION=$OPTARG
                ;;
            config)
                CONFIG_FILE=$OPTARG
                ;;
            ?)
            echo "unknow argument"
            exit 1
            ;;
        esac
    done
}

function init_source() {
    if [ ! -d "$bcachefs_dir" ]; then
        git clone $KERNEL_SOURCE "$bcachefs_dir" $KERNEL_VERSION
    fi
    cd "$bcachefs_dir" || exit 1
    git pull
    cp ../config ./.config
    cd ..
    if [ ! -d "$bcachefs_tools" ]; then
        git clone https://evilpiepirate.org/git/bcachefs-tools.git "$bcachefs_tools" $TOOLS_VERSION
    fi
    cd "$bcachefs_tools" || exit 1
    git pull
    cd ..
}

function build_kernel() {
    cd $bcachefs_dir
    #fakeroot debian/rules binary
    make -j 4 deb-pkg LOCALVERSION=$LOCALVERSION
}

function build_tools() {
    cd $bcachefs_tools
    make deb
}

function build() {
    build_kernel
    build_tools
}

function copy_deb() {
    #rm -rf *.deb
    #build
    rm -rf ../config/packages.chroot/linux-image-*.deb
    rm -rf ../config/packages.chroot/bcachefs-tools-*.deb
    cp -rf linux-image-*-rix_*-13_amd64.deb ../config/packages.chroot/
    cp -rf linux-headers-*-rix_*-13_amd64.deb ../config/packages.chroot/
    cp -rf linux-libc-dev_*-13_amd64.deb ../config/packages.chroot/
    cp -rf bcachefs-tools_*_amd64.deb ../config/packages.chroot/
}

$cmd
