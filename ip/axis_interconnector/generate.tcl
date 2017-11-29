set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -name axis_interconnector -taxonomy $TAXONOMY -root_dir $ip_dir $ip_dir/src
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

define_associate_busif clk

pip_set_prop [ipx::current_core] [subst {
	display_name {AXI Stream InterConnector}
	description {AXI Stream InterConnector}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}]

pip_clr_def_if_par_memmap [ipx::current_core]

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if [ipx::current_core] S[set i]_AXIS [subst {
		abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
		bus_type_vlnv {xilinx.com:interface:axis:1.0}
		interface_mode {slave}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_S_STREAM_NUM')) > $i}
	}] [subst {
		TVALID	s[set i]_axis_tvalid
		TDATA	s[set i]_axis_tdata
		TUSER	s[set i]_axis_tuser
		TLAST	s[set i]_axis_tlast
		TREADY	s[set i]_axis_tready
	}]
	append_associate_busif clk S[set i]_AXIS
}
for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if [ipx::current_core] M[set i]_AXIS [subst {
		abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
		bus_type_vlnv {xilinx.com:interface:axis:1.0}
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_M_STREAM_NUM')) > $i}
	}] [subst {
		TVALID	m[set i]_axis_tvalid
		TDATA	m[set i]_axis_tdata
		TUSER	m[set i]_axis_tuser
		TLAST	m[set i]_axis_tlast
		TREADY	m[set i]_axis_tready
	}]
	append_associate_busif clk M[set i]_AXIS

	pip_add_bus_if [ipx::current_core] s[set i]_dst_bmp [subst {
		abstraction_type_vlnv {xilinx.com:signal:data_rtl:1.0}
		bus_type_vlnv {xilinx.com:signal:data:1.0}
		interface_mode {slave}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_M_STREAM_NUM')) > $i}
	}] [subst {
		DATA s[set i]_dst_bmp
	}]
	append_associate_busif clk s[set i]_dst_bmp
}

# clock & reset
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
} [subst {
	ASSOCIATED_BUSIF [get_associate_busif clk]
	ASSOCIATED_RESET {resetn}
}]

# parameters
pip_add_usr_par [ipx::current_core] {C_PIXEL_WIDTH} {
	display_name {Stream Pixel Width}
	tooltip {Stream Pixel Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {8 10 12 16 24 32}
} {
	value 8
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_S_STREAM_NUM} {
	display_name {Slave Stream Number}
	tooltip {Slave Stream Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 2
	value_format long
	value_validation_type list
	value_validation_list {2 3 4 5 6 7 8}
} {
	value 2
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_M_STREAM_NUM} {
	display_name {Master Stream Number}
	tooltip {Master Stream Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 2
	value_format long
	value_validation_type list
	value_validation_list {2 3 4 5 6 7 8}
} {
	value 2
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_ONE2MANY} {
	display_name {Support One To Many}
	tooltip {Support One To Many}
	widget {checkBox}
} {
	value_resolve_type user
	value false
	value_format bool
} {
	value false
	value_format bool
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
