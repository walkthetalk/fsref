set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -taxonomy /UserIP $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

#pip_clr_def_if_par [ipx::current_core]

pip_set_prop [ipx::current_core] {
    core_revision 1
    supported_families {zynq Production}
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
