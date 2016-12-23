#!/usr/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}"`"

VIVADO_BIN="/mnt/xilinx/Vivado/2016.3/bin/vivado"

dir_ip="$dir_main/ip"
for ip in `find ${dir_ip} -mindepth 1 -maxdepth 1 -type d`; do
${VIVADO_BIN} \
	-nojournal -nolog \
	-mode batch \
	-source ${ip}/generate.tcl \
	-tclargs "${dir_main}"
done

${VIVADO_BIN} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/genproj.tcl \
	-tclargs "${dir_main}"
