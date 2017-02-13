#!/usr/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

source ${dir_main}/scripts/setenv

if [ "x$1" == "x" ]; then
	echo "you must give the name of ip"
	exit 1
fi

dir_ip="$dir_main/ip/$1"
if not [ -d "${dir_ip}" ]; then
	echo "can't find the directory of ip '$1'"
	exit 2
fi

${VIVADO_BIN} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_ip}/generate.tcl \
	-tclargs "${dir_main}"

