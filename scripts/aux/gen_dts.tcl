set dst_path [lindex $argv 0]
set tmp_path [lindex $argv 1]
set xsa_file [lindex $argv 2]
set proc_name [lindex $argv 3]
set repo_path [lindex $argv 4]

set project_name dtcproj

# prepare hw design
file mkdir ${tmp_path}
file copy -force ${xsa_file} $tmp_path/$project_name.xsa
hsi set_repo_path $repo_path
hsi open_hw_design $tmp_path/$project_name.xsa

# generate device tree though sw design
hsi create_sw_design -proc $proc_name -os device_tree devicetree
#set boot_args {console=ttyPS0,115200 earlyprintk}
#hsi set_property CONFIG.kernel_version {2019.2} [hsi get_os]
#hsi set_property CONFIG.bootargs $boot_args [hsi get_os]
file mkdir ${dst_path}
hsi generate_target -dir ${dst_path}
hsi close_sw_design [hsi current_sw_design]

# close hw design
hsi close_hw_design [hsi current_hw_design]
