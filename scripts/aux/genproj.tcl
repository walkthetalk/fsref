set origin_dir [lindex $argv 0]

source $origin_dir/scripts/aux/util.tcl
source $origin_dir/ip/fscore/create.tcl

# create project
create_project fsref $origin_dir -part xc7z020clg400-1
set_property simulator_language Verilog [current_project]

# update ips
# @note: must use [list xx yy]. the {xx yy} form cannot extent $ rightly.
set_property ip_repo_paths $origin_dir/ip [current_project]
update_ip_catalog

# create board design
create_bd_design "bd1"
source $origin_dir/scripts/aux/genbd1.tcl
save_bd_design
make_wrapper -files [get_files $origin_dir/fsref.srcs/sources_1/bd/bd1/bd1.bd] -top
add_files -norecurse $origin_dir/fsref.srcs/sources_1/bd/bd1/hdl/bd1_wrapper.v

# set property of bd1
set_property used_in_simulation false [get_files  $origin_dir/fsref.srcs/sources_1/bd/bd1/bd1.bd]
set_property used_in_simulation false [get_files  $origin_dir/fsref.srcs/sources_1/bd/bd1/hdl/bd1_wrapper.v]
update_compile_order -fileset sources_1

# xdc
set xdc_file $origin_dir/ip/top.xdc
add_files -fileset constrs_1 $xdc_file
set_property target_constrs_file $xdc_file [current_fileset -constrset]
set_property used_in_synthesis false [get_files $xdc_file]
set_property used_in_implementation true [get_files $xdc_file]
