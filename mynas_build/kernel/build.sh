#!/bin/bash

cmd=${1:-"build"}
bcachefs_dir="./bcachefs"
bcachefs_tools="./bcachefs-tools"

function init_source() {
    if [ ! -d "$bcachefs_dir" ]; then
        git clone https://evilpiepirate.org/git/bcachefs.git "$bcachefs_dir"
    fi
    cd "$bcachefs_dir" || exit 1
    git pull
    cp ../config ./.config
    cd ..
    if [ ! -d "$bcachefs_tools" ]; then
        git clone https://evilpiepirate.org/git/bcachefs-tools.git "$bcachefs_tools"
    fi
    cd "$bcachefs_tools" || exit 1
    git pull
    cd ..
}

function build_kernel() {
    cd $bcachefs_dir
    make -j 4 deb-pkg LOCALVERSION=-rix
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
    rm -rf *.deb
    build
    cp -rf linux-image-*_amd64.deb ../config/packages.chroot/
    cp -rf bcachefs-tools-*_amd64.deb ../config/packages.chroot/
}

$cmd
