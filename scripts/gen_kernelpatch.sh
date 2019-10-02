#!/bin/env sh
set -e

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

src_dir="${dir_main}/scripts/kernelpatch"
out_dir="${dir_main}/output"
tmp_dir="`mktemp -p /tmp -d fsref.XXXXX`"

patch_name="add_fsref.patch"

file_list=(
	"arch/arm/configs/fsref_defconfig"
)

cd ${tmp_dir}
quilt new ${patch_name}
for i in ${file_list[@]}; do
	idir=`dirname $i`
	ifile=`basename $i`
	quilt add $i
	mkdir -p ${idir}
	cp ${src_dir}/${ifile} $i
done
quilt refresh

cp ${tmp_dir}/patches/${patch_name} ${out_dir}

rm -rf ${tmp_dir}
