#!/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

out_dir="${dir_main}/output"
if [ ! -d "${out_dir}" ]; then
	mkdir ${out_dir}
fi

ps7init_dir="${out_dir}/ps7init"
if [ ! -d "${ps7init_dir}" ]; then
	mkdir ${ps7init_dir}
fi

dts_dir="${out_dir}/dts"
if [ ! -d "${dts_dir}" ]; then
	mkdir ${dts_dir}
fi

if [ -d "$1" ]; then
	dtxdir="$1"
fi
if [ ! -d "$dtxdir" ]; then
	echo "HINT:  git clone https://github.com/Xilinx/device-tree-xlnx.git"
	exit 1
fi

repo_dt="`readlink -fe "${dtxdir}"`"

source ${dir_main}/scripts/setenv

${HSI_BIN} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/gen_ps7init_dts.tcl \
	-tclargs "${dir_main}" "${repo_dt}" "${ps7init_dir}" "${dts_dir}"

#command -v dtc >/dev/null 2>&1 || { echo >&2 "ERROR: require dtc but not installed."; exit 1; }
#dtc -I dts -O dtb -R 8 -p 0x3000 \
#	-i ${dts_dir} \
#	-o ${out_dir}/devicetree.dtb \
#	${dir_main}/scripts/dtspatch/wrapper.dts
