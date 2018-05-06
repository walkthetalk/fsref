#!/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

out_dir="${dir_main}/output"
if [ ! -d "${out_dir}" ]; then
	mkdir ${out_dir}
fi

tmp_dir="${out_dir}/dts"
if [ ! -d "${tmp_dir}" ]; then
	mkdir ${tmp_dir}
fi

dtxdir="${dir_main}/../device-tree-xlnx/"
if [ ! -d "${dtxdir}" ]; then
	echo "ERROR: please clone device-tree-xlnx first!"
	echo "HINT:  git cloen https://github.com/Xilinx/device-tree-xlnx.git"
	exit 1
fi

repo_dt="`readlink -fe "${dtxdir}"`"

source ${dir_main}/scripts/setenv

${HSI_BIN} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/gendts.tcl \
	-tclargs "${dir_main}" "${repo_dt}" "${tmp_dir}"

command -v dtc >/dev/null 2>&1 || { echo >&2 "ERROR: require dtc but not installed."; exit 1; }
dtc -I dts -O dtb -R 8 -p 0x3000 \
	-i ${tmp_dir} \
	-o ${out_dir}/devicetree.dtb \
	${dir_main}/scripts/dtspatch/wrapper.dts
