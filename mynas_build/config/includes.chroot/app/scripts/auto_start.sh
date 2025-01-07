#!/bin/bash

function auto_start_docker()
{
    docker_config=$(cat /app/config/docker.config)
    auto_start=$(echo "$config" | jq -r '.auto_start')
    case "$auto_start" in
        "true")
            /app/scripts/start_docker.sh
            ;;
        *)
            ;;
    esac
}

/app/scripts/mount_pool.sh

auto_start_docker

websockify -D --web=/usr/share/novnc/ --token-plugin TokenFile --token-source /app/token/ 6080

echo "done"

exit 0
