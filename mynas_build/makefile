
MIRROR=https://mirrors.ustc.edu.cn/debian/
CODENAME=bookworm
#KERNEL_VER=$(cat $CURDIR/.kernel_version)
BOOT="boot=live components persistence persistence-label=mynas quiet splash pci=noaer pcie_aspm=off"
include ./kernel/bcachefs/debian/rules.vars

#KERNEL_VER=6.15.0-rc5
ifeq ($(origin KERNELRELEASE),undefined)
KERNEL_VER := 6.15.0-rc6
else
KERNEL_VER := $(patsubst %-rix,%,$(KERNELRELEASE))
endif

default: build

clean:
	lb clean

build:
	@echo "--linux-flavour rix"
	lb clean
	lb config --linux-packages linux-image-$(KERNEL_VER) --linux-flavour "rix" \
       -d $(CODENAME) \
       --apt-options "--yes"\
       --distribution-chroot $(CODENAME) \
       --distribution-binary $(CODENAME) \
       --bootappend-live "$(BOOT)" \
       --mirror-bootstrap "$(MIRROR)" \
       --mirror-binary "$(MIRROR)" \
       --mirror-chroot "$(MIRROR)" \
       --debootstrap-options "--variant=minbase --include=apt-utils,ca-certificates,gnupg2" \
       --apt-indices false --apt-recommends false --firmware-chroot false \
       --debug
	lb build --debug > a.log
	sync
