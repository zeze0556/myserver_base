#!/bin/bash

set -x
export DEBIAN_FRONTEND=noninteractive
export TZ="Asia/Shanghai"

sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

# debian needs a newer version of liburcu from source

function install() {
    apt-get update -y
    #dpkg -i /data/kernel/tools/liburcu-dev_*.deb
    apt-get install -y --fix-missing pkg-config libaio-dev libblkid-dev libkeyutils-dev bc cpio zstd grub2 initramfs-tools clang librust-clang-sys-dev\
            liblz4-dev libsodium-dev libzstd-dev vim file wget unzip rsync \
            uuid-dev zlib1g-dev valgrind libudev-dev git build-essential rust-all \
            debhelper \
            devscripts \
            python3 \
            mkisofs \
            libfuse3-dev \
            libxml2-utils \
            cron \
            libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf llvm debhelper-compat dh-python systemd rustc curl libscrypt-dev libsystemd-dev systemd-dev \
            live-build \
            libdw-dev  libunwind-dev  libslang2-dev libperl-dev systemtap-sdt-dev \
            python3-dev libpfm4-dev libtraceevent-dev

            echo "over install"
}

function install_rustup() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -y
}

function clean() {
    apt clean
    rm -rf /var/lib/apt/lists/*
}

install
install_rustup
clean
