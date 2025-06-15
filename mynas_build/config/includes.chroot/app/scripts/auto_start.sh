#!/bin/bash

function auto_start_docker()
{
    docker_config=$(cat /app/config/docker.config)
    auto_start=$(echo "$docker_config" | jq -r '.auto_start')
    case "$auto_start" in
        "true")
            /app/scripts/start_docker.sh
            ;;
        *)
            ;;
    esac
}

function auto_start_zram()
{
    config=$(cat /app/config/zram.config)
    auto_start=$(echo "$config" | jq -r '.auto_start')
    case "$auto_start" in
        "true")
            /app/scripts/start_zram.sh
            ;;
        *)
            ;;
    esac
}
udevadm trigger

/app/scripts/cryptsetup_auto_open.sh

/app/scripts/mount_pool.sh

auto_start_docker

websockify -D --web=/usr/share/novnc/ --token-plugin TokenFile --token-source /app/token/ 6080

echo "done"

exit 0
