#!/bin/bash
#set -x
SUMMARY=""
SEND_NOTIFY=""
LOG=/tmp/smart_report.log
TODAY=$(date +"%Y-%m-%d")
CRON_TASK=${1:-false}

echo "" > $LOG
# Function to check if a disk is SSD
is_ssd() {
    local disk=$1
    local rotational=$(cat /sys/block/$(basename $disk)/queue/rotational)
    if [ "$rotational" -eq 0 ]; then
        echo "true"
    else
        echo "false"
    fi
}

output() {
    echo $* >> $LOG
    echo $*
}

# Function to get SSD remaining life
get_sata_ssd_life() {
    local disk=$1
    local life=$(smartctl -x $disk | grep -i 'Percentage Used Endurance Indicator' | awk '{print $4}')
    if [ -z "$life" ]; then
        output "Unable to determine SSD life for $disk"
    else
        output "SSD used life for $disk: $life%"
    fi
    echo "";
}

# Function to get SSD remaining life for NVMe devices
get_nvme_ssd_life() {
    local disk=$1
    local life=$(smartctl -A $disk | grep -i 'Percentage Used' | awk '{print $3}')
    if [ -z "$life" ]; then
        output "Unable to determine NVMe SSD life for $disk"
    else
        output "NVMe used life for $disk: $life"
    fi
    echo "";
}

# Function to get HDD health attributes

get_hdd_health_true() {
    local disk=$1
    smartctl -A $disk | grep -E 'Reallocated_Sector_Ct|Current_Pending_Sector|Offline_Uncorrectable'
}

get_hdd_health() {
    output "HDD health attributes for $disk:"
    local disk=$1
    IFS=$'\n' read -a msg -d '' <<< $(get_hdd_health_true $disk)
    for(( i=0;i<${#msg[@]};i++))
    do
        local cur=${msg[i]}
        # 提取最后一组数字
        last_number=$(echo "$cur" | awk '{print $NF}')

        # 检查最后一组数字是否不为 0
        if [ "$last_number" -ne 0 ]; then
            SEND_NOTIFY=true
            SEND_MESSAGE+="Disk $disk has issues. $cur\r\n"
        fi
        output $cur
    done
    echo "";
}

# Main script
for disk in /dev/sd? /dev/nvme?n1; do
	  if [ "$(is_ssd $disk)" == "true" ]; then
        if [[ $disk == /dev/nvme* ]]; then
            get_nvme_ssd_life $disk
        else
            get_sata_ssd_life $disk
        fi
    else
        get_hdd_health $disk
    fi
done

# 如果 SEND_NOTIFY 为 true，则发送通知
if [ "$CRON_TASK" = true ]; then
if [ "$SEND_NOTIFY" = true ]; then
    # 创建 JSON 数据
    JSON_DATA=$(jq -n \
                   --arg subject "Disk Issue Notification ($TODAY)" \
                   --arg message "$SEND_MESSAGE" \
                   --arg attach "/tmp/smart_report.log" \
                   '{subject: $subject, message: $message, attach: $attach}')

    # 使用 curl 发送 POST 请求
    curl -X POST http://127.0.0.1:8080/api/notify \
         -H "Content-Type: application/json" \
         -d "$JSON_DATA" > /dev/null 2>&1
fi
fi
