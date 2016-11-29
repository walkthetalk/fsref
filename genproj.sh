#!/usr/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}"`"

/mnt/xilinx/Vivado/2016.3/bin/vivado \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/genproj.tcl \
	-tclargs "${dir_main}"
