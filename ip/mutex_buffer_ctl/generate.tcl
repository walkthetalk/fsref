set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -taxonomy /UserIP $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_set_prop [ipx::current_core] [subst {
	display_name {Mutex Buffer Controller}
	description {1W2R buffer controller}
	vendor_display_name {OCFB}
	version $VERSION
	core_revision 1
	company_url {https:://github.com/walkthetalk}
	supported_families {zynq Production}
}]

pip_clr_def_if_par [ipx::current_core]

pip_add_bus_if [ipx::current_core] MBUF_R0 [subst {
	abstraction_type_vlnv $VENDOR:$LIBRARY:mutex_buffer_rtl:1.0
	bus_type_vlnv $VENDOR:$LIBRARY:mutex_buffer:1.0
	interface_mode {master}
}] {
	SOF r0_sof
	ADDR r0_addr
}

pip_add_bus_if [ipx::current_core] MBUF_R1 [subst {
	abstraction_type_vlnv $VENDOR:$LIBRARY:mutex_buffer_rtl:1.0
	bus_type_vlnv $VENDOR:$LIBRARY:mutex_buffer:1.0
	interface_mode master
}] {
	SOF r1_sof
	ADDR r1_addr
}

pip_add_bus_if [ipx::current_core] MBUF_W [subst {
	abstraction_type_vlnv $VENDOR:$LIBRARY:mutex_buffer_rtl:1.0
	bus_type_vlnv $VENDOR:$LIBRARY:mutex_buffer:1.0
	interface_mode master
}] {
	SOF w_sof
	ADDR w_addr
}

pip_add_bus_if [ipx::current_core] intr {
	abstraction_type_vlnv xilinx.com:signal:interrupt_rtl:1.0
	bus_type_vlnv xilinx.com:signal:interrupt:1.0
	interface_mode master
} {
	INTERRUPT intr
}

pip_add_bus_if [ipx::current_core] resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST resetn
} {
	POLARITY {ACTIVE_LOW}
}

pip_add_bus_if [ipx::current_core] clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} {
	ASSOCIATED_BUSIF {MBUF_W:MBUF_R0:MBUF_R1}
	ASSOCIATED_RESET {resetn}
}

pip_add_usr_par [ipx::current_core] {C_ADDR_WIDTH} {
	display_name {Address Width}
	tooltip {ADDRESS WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 32
	value_format long
	value_validation_type list
	value_validation_list {32 64}
} {
	value 32
	value_format long
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
