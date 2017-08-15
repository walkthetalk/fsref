set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -taxonomy $TAXONOMY $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_set_prop [ipx::current_core] {
	display_name {Fusion Splicer Lcd}
	description {Lcd interface on Fusion splicer}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}

pip_clr_def_if_par [ipx::current_core]

pip_add_bus_if [ipx::current_core] vid_io_in {
	abstraction_type_vlnv {xilinx.com:interface:vid_io_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:vid_io:1.0}
	interface_mode {slave}
} {
	ACTIVE_VIDEO vid_active_video
	DATA vid_data
	HSYNC vid_hsync
	VSYNC vid_vsync
}

pip_add_bus_if [ipx::current_core] vid_io_in_clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK vid_io_in_clk
} {
	ASSOCIATED_BUSIF vid_io_in
}

pip_add_usr_par [ipx::current_core] {C_IN_COMP_WIDTH} {
	display_name {Single Component In Data Width}
	tooltip {SINGLE COMPONENT In DATA WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {6 8 10 12}
} {
	value 8
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_OUT_COMP_WIDTH} {
	display_name {Single Component Out Data Width}
	tooltip {SINGLE COMPONENT Out DATA WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {6 8 10 12}
} {
	value 8
	value_format long
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
