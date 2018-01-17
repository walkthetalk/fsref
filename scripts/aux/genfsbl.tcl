set origin_dir [lindex $argv 0]
set output_dir [lindex $argv 1]

file copy -force ${origin_dir}/fsref.runs/impl_1/bd1_wrapper.sysdef \
${origin_dir}/fsref.sdk/bd1_wrapper.hdf

set hwdsgn [open_hw_design ${origin_dir}/fsref.sdk/bd1_wrapper.hdf]

generate_app -hw ${hwdsgn} \
-os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -compile -sw fsbl \
-dir ${output_dir}
