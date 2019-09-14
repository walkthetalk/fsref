#!/usr/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"
out_dir="${dir_main}/output"
out_file="${out_dir}/BOOT.bin"

source ${dir_main}/scripts/setenv

BIF_FILE="${out_dir}/freertos.bif"
echo "//arch = zynq; split = false; format = BIN
the_ROM_image:
{
        [bootloader]${out_dir}/fsbl/executable.elf
        ${out_dir}/hwplat/bd1_wrapper.bit
        ${out_dir}/rtos/executable.elf
}" > ${BIF_FILE}

${SDK_BIN_DIR}/bootgen \
	-image ${BIF_FILE} -arch zynq -o ${out_file} -w on 
