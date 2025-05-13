#!/bin/bash
#set -x
source /root/.bashrc
default=${1:-"init_cron"}

function init_cron() {
    if [ "${CRON,,}" = "true" ]; then
       crontab -u root /data/cron/*.cron
       cron
    fi
    tail -f /dev/null
}

$default

