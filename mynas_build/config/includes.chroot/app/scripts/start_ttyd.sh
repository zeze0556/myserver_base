#!/bin/bash

function start() {
	/usr/bin/ttyd -i /var/run/ttyd.sock -W /bin/bash
}
#export -f start
nohup bash -c "/usr/bin/ttyd -i /var/run/ttyd.sock -W /bin/bash" > /var/log/ttyd.log 2>&1 &
sleep 2
chmod a+rw /var/run/ttyd.sock
