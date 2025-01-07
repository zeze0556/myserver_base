#!/bin/bash
set -x
# 获取当前运行的虚拟机列表
running_vms=$(virsh list --name --state-running)

# 检查是否有运行的虚拟机
if [ -z "$running_vms" ]; then
    echo "No running virtual machines found."
    exit 0
fi

# 遍历每个运行的虚拟机
for vm in $running_vms; do
    # 获取虚拟机的 VNC 端口
    vnc_port=$(virsh domdisplay "$vm" | grep -oP 'vnc://\K.*')

    # 检查是否获取到 VNC 端口
    if [ -z "$vnc_port" ]; then
        echo "No VNC port found for virtual machine: $vm"
    else
        echo "Virtual machine: $vm, VNC port: $vnc_port"
    fi
done
