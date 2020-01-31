set xsa_file [lindex $argv 0]
set proj_file [lindex $argv 1]

open_project ${proj_file}
write_hw_platform -fixed -force -file ${xsa_file}
close_project
