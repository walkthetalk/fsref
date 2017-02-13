#!/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

out_dir="${dir_main}/output"
if [ ! -d "${out_dir}" ]; then
	mkdir ${out_dir}
fi

repo_dt="`readlink -fe "${dir_main}/../device-tree-xlnx/"`"
if [ ! -d "${repo_dt}" ]; then
	echo "ERROR: please clone device-tree-xlnx first!"
	exit 1
fi

${HSI_BIN} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/gendts.tcl \
	-tclargs "${dir_main}" "${repo_dt}"

dtc -I dts -O dtb -R 8 -p 0x3000 \
	-i ${dir_main}/dts \
	-o ${out_dir}/devicetree.dtb \
	${dir_main}/dts/wrapper.dts
