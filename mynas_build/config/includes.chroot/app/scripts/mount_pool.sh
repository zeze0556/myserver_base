#!/bin/bash
# 解析JSON配置文件
config=$(cat /app/config/pools.config)
auto_mount_true_items=$(echo "$config" | jq -c '.[] | select(.auto_mount == true)')

# 循环处理每个auto_mount为true的配置项
echo "$auto_mount_true_items" | while read -r pool; do
    name=$(echo "$pool" | jq -r '.name')
    auto_mount=$(echo "$pool" | jq -r '.auto_mount')
    mount_path=$(echo "$pool" | jq -r '.mount_path')
    mount_option=$(echo "$pool" | jq -r '.mount_option')
    type=$(echo "$pool" | jq -r '.type')
    uuid=$(echo "$pool" | jq -r '.uuid')

    if [ "$auto_mount" = "true" ]; then
        mkdir -p $mount_path
        if [ "$type" = "bcachefs" ]; then
            echo "Mounting Bcachefs filesystem $name with UUID=$uuid at $mount_path"
            echo bcachefs mount -o "$mount_option" UUID="$uuid" "$mount_path"
            bcachefs mount UUID="$uuid" "$mount_path"
        else
            echo "Mounting Btrfs filesystem $name with UUID=$uuid at $mount_path"
            #mount -o "$mount_option" UUID="$uuid" "$mount_path"
            mount UUID="$uuid" "$mount_path"
        fi
    else
        echo "Auto mount is disabled for $name"
    fi
done
