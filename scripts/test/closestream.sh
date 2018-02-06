#!/usr/bin/env sh
MEMCMD="./mem"
getAddr() {
	 echo  $((0x43c00000+$1*4))
}

WR() {
	$MEMCMD `getAddr $1` w $2 > /dev/null
}

SIDX=$1

SIDXM4=$(($1 * 4))
SBMP=$((2**$SIDXM4))

#echo "SLT is: `printf "%#x" $SLT`"
#start config
WR 0 0x1

# set operator bitmap
WR 1 $SBMP

# set enable
WR 5 0x0

#stop config
WR 0 0x0

