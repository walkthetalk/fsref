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

SRC_FILE="${dir_main}/scripts/bit2bin/zynq_bit2bin.c"
gcc ${SRC_FILE} -o ${out_dir}/bit2bin

${out_dir}/bit2bin ${dir_main}/fsref.runs/impl_1/${BDNAME}_wrapper.bit ${out_dir}/system.bit.bin

echo "
#Load the Bitstream
	mkdir -p /lib/firmware
	cp /media/design_1_wrapper.bit.bin /lib/firmware/
	echo design_1_wrapper.bit.bin > /sys/class/fpga_manager/fpga0/firmware
"
