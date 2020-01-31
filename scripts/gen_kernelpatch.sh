#!/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

src_dir="${dir_main}/scripts/kernelpatch"
out_dir="${dir_main}/output"
tmp_dir="`mktemp -p /tmp -d fsref.XXXXX`"

kernel_dir=${tmp_dir}/linux
mkdir ${kernel_dir}

patch_name="add_fsref.patch"

file_list=(
	"arch/arm/configs/fsref_defconfig"
	"arch/arm/boot/dts/zynq-fsref.dts"
)

cd ${kernel_dir}
quilt new ${patch_name}
for i in ${file_list[@]}; do
	idir=`dirname $i`
	ifile=`basename $i`
	quilt add $i
	mkdir -p ${idir}
	cp ${src_dir}/${ifile} $i
done
quilt refresh

if [ ! -d ${out_dir} ]; then
	mkdir -p ${out_dir}
fi
cp ${kernel_dir}/patches/${patch_name} ${out_dir}

rm -rf ${tmp_dir}
