#!/usr/bin/env sh
#set -e

if [ "x$1" == "x" -o "x$2" == "x" ]; then
	echo "please use as: $0 orih dsth"
	exit 1
fi

ORIH=$1
DSTH=$2

ORICNT=1
ORIL=$DSTH
DSTCNT=1
DSTL=$ORIH

TMP=0
while true; do
	#echo "CNT:$CNT  RAT:$RAT"
	let "TMP = $ORICNT - 1"
	if [ $ORIL -ge $DSTL ]; then
		printf "%3d   %3d   %dx   %d\n" $ORIL $DSTL $TMP $DSTCNT
		let DSTL=$DSTL+$ORIH+$ORIH
		let DSTCNT++
	else
		let ORIL=$ORIL+$DSTH+$DSTH
		let ORICNT++
	fi
	if [ $ORICNT -gt $ORIH -a $DSTCNT -gt $DSTH ]; then
		break
	fi
done
