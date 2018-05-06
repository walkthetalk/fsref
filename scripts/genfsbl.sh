#!/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

out_dir="${dir_main}/output"
if [ ! -d "${out_dir}" ]; then
	mkdir ${out_dir}
fi

tmp_dir="${out_dir}/fsbl"
if [ ! -d "${tmp_dir}" ]; then
	mkdir ${tmp_dir}
fi

source ${dir_main}/scripts/setenv

command -v gmake >/dev/null 2>&1 || {
	echo >&2 "ERROR: require gmake but not installed."
	echo >&2 "HINT:  sudo ln -s make /usr/bin/gmake"
	exit 1
}

${HSI_BIN} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/genfsbl.tcl \
	-tclargs "${dir_main}" "${tmp_dir}"
