#!/usr/bin/env sh

n=$1

for ((i=0; $n>0; i++)); do
	n=`expr $n / 2`
done

echo "$1 -> $i"
