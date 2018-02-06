#!/usr/bin/env sh

MEMCMD="./mem"
getAddr() {
         echo  $((0x43c00000+$1*4))
}

WR() {
        $MEMCMD `getAddr $1` w $2 > /dev/null
}

IDX=$1
FORWARD=$2
STEPCNT=$3
SPEED=$4

WR 16 0x3
for i in `seq 0 511`; do
	WR 17 $((1000 + 100 * (511 - $i)))
done
WR 16 0x0

WR 18 0x11111111
WR 21 0xFFFFFFFF

for i in `seq 23 30`; do
	WR $i 64000
done

if [ $FORWARD == "1" ]; then
	WR 22 0x11111111
else
	WR 22 0x0
fi

WR $((31 + $IDX)) $STEPCNT
WR $((39 + $IDX)) $SPEED

WR 20 0x11111111
