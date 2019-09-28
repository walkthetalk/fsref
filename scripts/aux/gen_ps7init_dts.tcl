set origin_dir [lindex $argv 0]
set repo_dir [lindex $argv 1]
set ps7init_dir [lindex $argv 2]
set dts_dir [lindex $argv 3]

open_hw_design ${origin_dir}/fsref.runs/impl_1/bd1_wrapper.sysdef

generate_target {psinit} [get_cells -filter {CONFIGURABLE==1}] -dir ${ps7init_dir}

set_repo_path ${repo_dir}
# get_cells -filter {IP_TYPE == PROCESSOR}
create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
generate_target -dir ${dts_dir}
