#!/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

kernel_src="`dirname "$1"`"
if [ ! -d "${kernel_src}" ]; then
	echo "ERROR: need kernel source directory!"
	exit 1
fi
kernel_src="`readlink -fe "${kernel_src}"`"

out_dir="${dir_main}/output"
if [ ! -d "${out_dir}" ]; then
	mkdir ${out_dir}
fi

cd ${kernel_src}
#quilt import ${dir_main}/scripts/kernelpatch/0001-first-running-version.patch
#quilt push
cp ${dir_main}/scripts/kernelpatch/fsref_defconfig ${kernel_src}/arch/arm/configs/

if [ "${ARCH}" != "arm" ]; then
	echo "ERROR: please source env file first!"
	exit 2
fi

make fsref_defconfig

cpu_num="`cat /proc/cpuinfo| grep "processor"| wc -l`"
make uImage UIMAGE_LOADADDR=0x8000 -j${cpu_num}
cp ${kernel_src}/arch/arm/boot/uImage  ${dir_main}/output/
