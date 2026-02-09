#!/bin/bash
#set -x
cmd=${1:-"build"}
CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bcachefs_dir="./bcachefs"
bcachefs_tools="./bcachefs-tools"

KERNEL_VERSION="v6.18"
TOOLS_VERSION="v1.36.1"
LOCALVERSION="-rix"
#LOCALVERSION="-generic"
#KERNEL_SOURCE="https://evilpiepirate.org/git/bcachefs.git"
KERNEL_SOURCE="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"
CONFIG_FILE="../config"
MAX_RETRIES=5
export DEB_BUILD_OPTIONS=noautodbgsym
. "/root/.cargo/env"

function get_args() {
    for arg in "$@"; do
        case $arg in
            --kernel_source=*)
                KERNEL_SOURCE="${arg#*=}"
                ;;
            --kernel_version=*)
                KERNEL_VERSION="${arg#*=}"
                ;;
            --tools_version=*)
                TOOLS_VERSION="${arg#*=}"
                ;;
            --local_version=*)
                LOCALVERSION="${arg#*=}"
                ;;
            --config=*)
                CONFIG_FILE="${arg#*=}"
                ;;
            ?)
            echo "unknow argument"
            exit 1
            ;;
        esac
    done
}

function init_source() {
    try_init_kernel_source
    init_bcachefs_tools_source
    echo "last=$?"
}

function init_bcachefs_tools_source() {
    cd $CURDIR
    if [ ! -d "$bcachefs_tools" ]; then
        git clone https://evilpiepirate.org/git/bcachefs-tools.git "$bcachefs_tools" -b $TOOLS_VERSION
    fi
    cd "$bcachefs_tools" || exit 1
    rm -rf *
    git reset --hard
    git pull origin $TOOLS_VERSION
    cd ..
}

function init_kernel_source() {
    cd $CURDIR
    if [ ! -d "$bcachefs_dir" ]; then
        git clone $KERNEL_SOURCE "$bcachefs_dir" -b $KERNEL_VERSION
    fi
    cd "$bcachefs_dir" || return 1
    rm -rf *
    git reset --hard
    git pull origin $KERNEL_VERSION
}

function try_init_kernel_source()
{
    COUNT=0
    while [ $COUNT -lt $MAX_RETRIES ]; do
        if  init_kernel_source; then
            echo "git pull 成功 ✔️"
            break
        else
            echo "git pull 失败 ❌"
            COUNT=$((COUNT+1))
            if [ $COUNT -lt $MAX_RETRIES ]; then
                echo "等待 5 秒后重试..."
                sleep 5
            fi
        fi
    done
    cp ../config ./.config
    #make distclean
}

function build_kernel() {
    cd $CURDIR
    cd $bcachefs_dir
    rm -rf *
    git reset --hard
    cp ../config ./.config
    yes "" | make oldconfig
    cp -rf .config ../config_$KERNEL_VERSION
    #fakeroot debian/rules binary
    make -j 4 deb-pkg LOCALVERSION=$LOCALVERSION
    cd tools/perf && make && cp -rf perf $CURDIR/
}

function build_tools() {
    cd $CURDIR
    cd $bcachefs_tools
    #. "/root/.cargo/env"
    rm -rf *
    git reset --hard
    #rm -rf .cargo
    /usr/share/cargo/bin/cargo vendor
    make CARGO_BUILD_TARGET=x86_64-unknown-linux-gnu deb
    #debuild -us -uc -nc -b -i -I -d
}

function build() {
    build_kernel
    build_tools
}

function clean_kernel() {
    cd $CURDIR
    cd "$bcachefs_dir" && make distclean
}

function clean_tools() {
    cd $CURDIR
    cd "$bcachefs_tools"
    rm -rf .cargo
    make clean
}

function clean() {
    clean_kernel
    clean_tools
}

function copy_deb() {
    #rm -rf *.deb
    #build
    img=$(awk '{print $1}' $bcachefs_dir/debian/image.files)
    header=$(awk '{print $1}' $bcachefs_dir/debian/headers.files)
    libc=$(awk '{print $1}' $bcachefs_dir/debian/libc-dev.files)
    bcachefs_ver=$(grep '^VERSION=' $bcachefs_tools/Makefile | cut -d= -f2)
    rm -rf ../config/packages.chroot/*.deb ../config/includes.chroot/usr/src
    cp -rf $img ../config/packages.chroot/
    cp -rf $header ../config/packages.chroot/
    cp -rf $libc ../config/packages.chroot/
    cp -rf perf  ../config/includes.chroot/sbin/
    cp -rf bcachefs-tools_*_amd64.deb ../config/packages.chroot/
    mkdir -p ../config/includes.chroot/usr/src
    cp -rf bcachefs-tools/debian/bcachefs-kernel-dkms/usr/src ../config/includes.chroot/usr/
    #bcachefs-kernel-dkms_*_amd64.deb 
}

function clean_deb() {
    rm -rf *.deb *.build *.buildinfo *.changes *.tar.gz *.dsc perf
}

get_args $@

shift
$cmd
