#!/usr/bin/env sh
set -e

dir_self="`dirname "$0"`"
dir_main="`readlink -fe "${dir_self}"`"

cd $dir_main
rm -rf *.str
rm -rf fsref.*
rm -rf *.log
rm -rf *.jou
rm -rf .Xil
rm -rf dts/pl.dtsi
rm -rf dts/skeleton.dtsi
rm -rf dts/system.dts
rm -rf dts/zynq-7000.dtsi
rm -rf dts/device-tree.mss
rm -rf output

cd ip
for i in `find -maxdepth 1 -mindepth 1 -type d`; do
    rm -rf $i/xgui
    rm -rf $i/component.xml
done
