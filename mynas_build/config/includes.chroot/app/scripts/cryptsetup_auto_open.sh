#!/bin/bash

#set -x
# 解析JSON配置文件
config=$(cat /app/config/cryptsetup.config)
auto_open_true_items=$(echo "$config" | jq -c '.children[] | select(.auto_open== true)')

# 循环处理每个auto_mount为true的配置项
echo "$auto_open_true_items" | while read -r pool; do
    by=$(echo "$pool" | jq -r '.by')
    auto_open=$(echo "$pool" | jq -r '.auto_open')
    by_value=$(echo "$pool" | jq -r '. | .[ .by ]')
    keyfile=$(echo "$pool" | jq -r '.keyfile')
    map_name=$(echo "$pool" | jq -r '.map_name')
    key_offset=$(echo "$pool" | jq -r '.key_offset')
    uuid=$(echo "$pool" | jq -r '.uuid')

    if [ "$auto_open" = "true" ]; then
        /app/scripts/cryptsetup_help.sh open -d /dev/disk/$by/$by_value -k $keyfile -s $key_offset -m $map_name
    else
        echo "Auto mount is disabled for $name"
    fi
done
