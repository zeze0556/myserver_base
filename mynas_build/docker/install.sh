#!/bin/bash

set -x
export DEBIAN_FRONTEND=noninteractive
export TZ="Asia/Shanghai"

sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

function install() {
    apt-get update -y
    apt-get install -y --fix-missing pkg-config libaio-dev libblkid-dev libkeyutils-dev bc cpio zstd grub2 initramfs-tools clang librust-clang-sys-dev\
            liblz4-dev libsodium-dev liburcu-dev libzstd-dev vim file wget unzip rsync \
            uuid-dev zlib1g-dev valgrind libudev-dev git build-essential rust-all \
            debhelper \
            devscripts \
            python3-docsutils \
            python3 \
            mkisofs \
            libfuse3-dev \
            libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf llvm debhelper-compat dh-python python3-docutils systemd rustc
            echo "over install"
}

function clean() {
    apt clean
    rm -rf /var/lib/apt/lists/*
}

install
clean
