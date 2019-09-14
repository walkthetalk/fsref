#!/usr/bin/env sh
SELFDIR=`readlink -f $0 | xargs dirname`

ADDR=$1
if [ "$2" == "" ]; then
SRCFILE=`readlink -f $SELFDIR/../output/system.bit.bin`
else
SRCFILE=`readlink -f $2`
fi

DSTFILE=`basename $SRCFILE`

echo "SRCFILE is $SRCFILE"

ftp -v -i -n $ADDR << END_SCRIPT
quote USER root
quote PASS ""
binary
cd /mnt
put "$SRCFILE" "$DSTFILE"
bye
END_SCRIPT

echo "put done"

exit 0
