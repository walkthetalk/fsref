#!/usr/bin/env sh

MEMCMD="./mem"
getAddr() {
         echo  $((0x43c00000+$1*4))
}

WR() {
        $MEMCMD `getAddr $1` w $2 > /dev/null
}

WR 66 3000
WR 67 1500

WR 68 3000
WR 69 1500

WR 65 3
