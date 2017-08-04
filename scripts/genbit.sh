#!/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

out_dir="${dir_main}/output"
if [ ! -d "${out_dir}" ]; then
	mkdir ${out_dir}
fi

${dir_main}/scripts/aux/conv ${dir_main}/fsref.runs/impl_1/bd1_wrapper.bit ${out_dir}/system.bit.bin
