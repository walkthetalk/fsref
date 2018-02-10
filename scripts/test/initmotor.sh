#!/usr/bin/env sh

MEMCMD="./mem"
getAddr() {
         echo  $((0x43c00000+$1*4))
}

WR() {
	#echo $1  $2
        $MEMCMD `getAddr $1` w $2 > /dev/null
}

# 1/32 microstep
MAXSPEED=$((2000 / 32))

WR 16 0x3
for i in `seq 511 -1 0`; do
	WR 17 $(($MAXSPEED + 10 * $i))
	#WR 17 $(($MAXSPEED + 1000 * (255 - $i)))
done
WR 16 0x0

