# myserver_base
myserver系统构建

基于debian的live-build构建分发的live iso

内核及工具构建:
```bash
cd mynas_build/kernel
./build.sh init_source #获取源代码
./build.sh copy_deb #构建deb并复制
```

iso构建:
```bash
cd mynas_build
make #构建iso
```

live iso并不保存数据，可以通过ventoy挂载启动，如果要保存数据可以通过persistence持久化的方式

持久化:
```bash
mkfs.ext4 -L mynas /dev/sdxx #某个磁盘分区
mount -t ext4 /dev/sdxx /mnt
echo "/ union" >> /mnt/persistence.conf
umount /mnt
```
也可以通过ventoy的脚本制作一个磁盘镜像，label为 mynas， 并且像上述一样写入一个persistence.conf文件到根目录即可

nvidia显卡驱动安装：
```bash
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist-nouveau.conf
echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf
```

下载支持的驱动（比如：NVIDIA-Linux-x86_64-550.142.run）
```bash
bash NVIDIA-Linux-x86_64-550.142.run --extract-only
cd NVIDIA-Linux-x86_64-550.142
./nvidia-installer
```
