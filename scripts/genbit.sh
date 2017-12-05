#!/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

out_dir="${dir_main}/output"
if [ ! -d "${out_dir}" ]; then
	mkdir ${out_dir}
fi

BDNAME="bd1"
if [ "$1" != "" ]; then
	BDNAME="$1"
fi

${dir_main}/scripts/aux/conv ${dir_main}/fsref.runs/impl_1/${BDNAME}_wrapper.bit ${out_dir}/system.bit.bin
