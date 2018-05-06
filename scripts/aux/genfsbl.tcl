set origin_dir [lindex $argv 0]
set output_dir [lindex $argv 1]

set hdf_file ${origin_dir}/output/bd1_wrapper.hdf
file copy -force ${origin_dir}/fsref.runs/impl_1/bd1_wrapper.sysdef ${hdf_file}

set hwdsgn [open_hw_design ${hdf_file}]

generate_app -hw ${hwdsgn} \
-os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -compile -sw fsbl \
-dir ${output_dir}
