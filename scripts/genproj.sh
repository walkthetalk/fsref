#!/usr/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

source ${dir_main}/scripts/setenv

${VIVADO_BIN} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/genall.tcl \
	-tclargs "${dir_main}" ${1+$@} \

#	|grep -v "^#"|grep -v "^INFO"|grep -v "19-3899"
