#!/bin/bash

config=$(cat /app/config/zram.config)
auto_start=$(echo "$config" | jq -r '.auto_start')
size=$(echo "$config" | jq -r '.size')
zramctl /dev/zram0 --algorithm lzo --size "${size}GiB"
mkswap -U clear /dev/zram0
swapon --discard --priority 100 /dev/zram0
