#!/usr/bin/env sh
set -e

dir_self="`dirname "$0"`"
dir_main="`readlink -fe "${dir_self}/.."`"

clr_proj=false
clr_allip=false
ip_name=""
if [ "$1" == "" ]; then
	clr_proj=true
	clr_allip=true
elif [ "$1" == "project" ]; then
	clr_proj=true
elif [ "$1" == "allip" ]; then
	clr_allip=true
else
	ip_name="$1"
fi

cd $dir_main
if [ $clr_proj == true ]; then
	echo "clearing project"
	rm -rf fsref.*
	rm -rf .Xil
	rm -rf output
	rm -rf ip/fsctl/src/fsctl.v
fi

cd ip
for i in `find -maxdepth 1 -mindepth 1 -type d | cut -d '/' -f 2`; do
	if [ $clr_allip == true ] || [ "$i" == "$ip_name" ]; then
		echo "clearing ip: $i"
		rm -rf $i/.Xil
		rm -rf $i/xgui
		rm -rf $i/*.xml
		rm -rf $i/tmp
		rm -rf $i/gui
	fi
done

echo "clear done!"
