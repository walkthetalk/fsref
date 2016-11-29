set origin_dir [lindex $argv 0]
set repo_dir [lindex $argv 1]

open_hw_design ${origin_dir}/fsref.runs/impl_1/bd1_wrapper.sysdef
set_repo_path ${repo_dir}
create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
generate_target -dir ${origin_dir}/dts
