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

OWH=$(($2 *65536+$3))
SLT=$(($4 *65536+$5))
SWH=$(($6 *65536+$7))
DLT=$(($8 *65536+$9))
DWH=$(($10*65536+$11))

#echo "SLT is: `printf "%#x" $SLT`"
#start config
WR 0 0x1

# set operator bitmap
WR 1 $SBMP

# set enable
WR 5 0x1
# set dst layer bitmap
WR 6 0x1

# set width/height...
WR 7  $OWH
WR 8  $SLT
WR 9  $SWH
WR 10 $DLT
WR 11 $DWH

#stop config
WR 0 0x0

