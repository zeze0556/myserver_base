#!/bin/bash
set -x
KEYFILE=""
HEADFILE=""
KEYFILEOFFSET=0
KEYFILESIZE=8388608 #8MB
DEVICE=""
S_POS=0
PAYLOAD=0
ACTION=""
UUID=`cat /proc/sys/kernel/random/uuid`
CIPHER="serpent-xts-plain64"
CRYPTSETUP="cryptsetup"
EXTEND="extend"
BLOCKSIZE=4194304 #4MB
MOUNT=""
QUITE=""
N=1
DEVICENAME=""
#cryptsetup --cipher serpent-xts-plain64 --key-size 512 --keyfile-size 4193952 --hash sha512  --key-file homekey.img --keyfile-offset 352 --header home.img --align-payload 104857600 luksFormat /dev/sde1

#dd if=/dev/urandom of=test.key bs=32M count=1
#/app/scripts/cryptsetup_help.sh format -d test.img -k test.key -s 4 -m test -u "3a947c16-1386-4964-bc50-17e46786fc09"
#/app/scripts/cryptsetup_help.sh open -d test.img -k test.key -s 4 -m test -u "3a947c16-1386-4964-bc50-17e46786fc09"
#/app/scripts/cryptsetup_help.sh close -d test.img -k test.key -s 4 -m test -u "3a947c16-1386-4964-bc50-17e46786fc09"


function convert() {
    local input="$1"
    local number unit multiplier

    # 提取数字和单位（支持带小数的数字）
    number=$(echo "$input" | grep -Eo '^[0-9]+(\.[0-9]+)?')
    unit=$(echo "$input" | grep -Eo '[A-Za-z]+$' | tr '[:lower:]' '[:upper:]')

    case "$unit" in
        #B)  multiplier=1 ;;
        K) multiplier=1024 ;;
        M) multiplier=$((1024 ** 2)) ;;
        G) multiplier=$((1024 ** 3)) ;;
        T) multiplier=$((1024 ** 4)) ;;
        *) multiplier=1 ;;
        #*) echo "Unknown unit: $unit" >&2; return 1 ;;
    esac

    # 使用 awk 计算：支持浮点乘法
    awk "BEGIN {printf \"%.0f\n\", $number * $multiplier}"
#local ret=`echo $1 | awk '/[0-9]$/{print $1;next};/[gG]$/{printf "%u\n", $1*(1024*1024*1024);next};/[mM]$/{printf "%u\n", $1*(1024*1024);next};/[kK]$/{printf "%u\n", $1*1024;next}' `
#echo "$ret"
}

function random_offset() {
    echo $((100 * 1024 + RANDOM % (412 * 1024)))
}

function get_args() {
	while getopts "k:h:d:p:s:c:eb:n:m:u:qb:" arg
		do
			case $arg in
				k)
				KEYFILE=$OPTARG
				;;
		h)
			HEADFILE=$OPTARG
			;;
		d)
			DEVICE=$OPTARG
			;;
		p)
			PAYLOAD=$(($(convert $OPTARG) / 512))
			;;
		s)
			S_POS=$(convert $OPTARG)
			;;
		c)
			CIPHER=$OPTARG
			;;
		q)
			QUITE="-q"
			;;
		b)
			BLOCKSIZE=$(convert $OPTARG)
			;;
		n)
			N=$OPTARG
			;;
		m)
			DEVICENAME=$OPTARG
			;;
    u)
        UUID=$OPTARG
        ;;
		?)
			echo "unknow argument"
			exit 1
			;;
		esac
			done
}


function open() {
	dname=${DEVICENAME:-`basename $DEVICE`}
	$CRYPTSETUP open --keyfile-size $KEYSIZE  --key-file $KEYFILE --keyfile-offset $KEYOFFSET --header $HEADFILE $DEVICE $dname
  #$CRYPTSETUP open  --key-file $KEYFILE --header $HEADFILE $DEVICE $dname
}

function close() {
	dname=${DEVICENAME:-`basename $DEVICE`}
	$CRYPTSETUP close $dname
}

function format() {
	$CRYPTSETUP luksFormat $QUITE --cipher $CIPHER --key-size 512 --keyfile-size $KEYSIZE --hash sha512  --key-file $KEYFILE --keyfile-offset $KEYOFFSET --header $HEADFILE --offset $PAYLOAD --uuid $UUID $DEVICE
  dd if=$HEADFILE of=$KEYFILE bs=$BLOCKSIZE conv=notrunc seek=2
}

function dump() {
	$CRYPTSETUP luksDump --keyfile-size $KEYSIZE  --key-file $KEYFILE --keyfile-offset $KEYOFFSET $HEADFILE
}

function extend() {
    #keyfile|header
    #keyfile size=8MB(2*blocksize)
    #header after all
	dd if=$KEYFILE of=/dev/shm/`basename $KEYFILE` bs=$BLOCKSIZE skip=2
		HEADFILE=/dev/shm/`basename $KEYFILE`
}

function quit() {
return 0
}

function extendquit() {
    rm -rf /dev/shm/`basename $KEYFILE`
}


ACTION=$1
shift
get_args $@
$EXTEND
echo $KEYFILE
echo $HEADFILE
KEYOFFSET=$((`od $KEYFILE -N $N -tu4 -j $S_POS | grep [^0$N] | awk '{print $2}'` * 8))
KEYSIZE=$((KEYFILESIZE - KEYOFFSET))

$ACTION

${EXTEND}quit

