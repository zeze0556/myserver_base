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
build.sh #构建iso
```
