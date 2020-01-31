set xpr_file [lindex $argv 0]
set parallel_num [lindex $argv 1]

open_project ${xpr_file}
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs ${parallel_num}
wait_on_run impl_1
close_project
