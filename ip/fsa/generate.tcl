set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -taxonomy $TAXONOMY $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_set_prop [ipx::current_core] [subst {
	display_name {Fusion Splicer PreProcessor}
	description {Fusion Splicer PreProcessor}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}]

pip_clr_def_if_par_memmap [ipx::current_core]

# start
define_associate_busif clk

pip_add_bus_if [ipx::current_core] IMG_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	WIDTH  width
	HEIGHT height
}
append_associate_busif clk IMG_SIZE

pip_add_bus_if [ipx::current_core] S_AXIS {
	abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:axis:1.0}
	interface_mode {slave}
} {
	TVALID	s_axis_tvalid
	TDATA	s_axis_tdata
	TUSER	s_axis_tuser
	TLAST	s_axis_tlast
	TREADY	s_axis_tready
}
append_associate_busif clk S_AXIS

proc MBR_RD_F {idx} {
	return "MBR_RD_$idx"
}

pip_add_bus_ifa [ipx::current_core] MBR_RD_F 8 {spirit:decode(id('MODELPARAM_VALUE.C_READER_NUM'))} [subst {
	abstraction_type_vlnv $VENDOR:interface:mbr_rd_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:mbr_rd_ctl:1.0
	interface_mode slave
}] {
	SOF       r_sof     1
	EN        r_en      1
	ADDR      r_addr    {spirit:decode(id('MODELPARAM_VALUE.BR_AW'))}
	DATA      r_data    {spirit:decode(id('MODELPARAM_VALUE.BR_DW'))}
}

append_associate_busifa clk MBR_RD_F 8

pip_add_bus_if [ipx::current_core] FSA_CTL [subst {
	abstraction_type_vlnv $VENDOR:interface:fsa_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:fsa_ctl:1.0
	interface_mode slave
}] {
	REF_DATA    ref_data
	LEFT_VERTEX lft_v
	RIGHT_VERTEX rt_v
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
	display_name {Stream Data Width}
	tooltip {Stream Data Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {8 10 12}
} {
	value 8
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_IMG_WW} {
	display_name {Image Width (PIXEL) Bit Width}
	tooltip {IMAGE WIDTH BIT WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {5 6 7 8 9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_IMG_HW} {
	display_name {Image Height (PIXEL) Bit Width}
	tooltip {IMAGE HEIGHT BIT WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {5 6 7 8 9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_READER_NUM} {
	display_name {Reader Number}
	tooltip {Reader Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 2
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4 5 6}
} {
	value 2
	value_format long
}

pip_add_usr_par [ipx::current_core] {BR_NUM} {
	display_name {blockram Number}
	tooltip {blockram Number}
	widget {textEdit}
} {
	value_resolve_type user
	enablement_value false
	value_tcl_expr {spirit:decode(id('MODELPARAM_VALUE.C_READER_NUM')) + 2}
	value 4
	value_format long
} {
	value 4
	value_format long
}
pip_add_usr_par [ipx::current_core] {BR_AW} {
	display_name {Blockram Address Width}
	tooltip {Blockram Address Width}
	widget {textEdit}
} {
	value_resolve_type user
	enablement_value false
	value_tcl_expr {spirit:decode(id('MODELPARAM_VALUE.C_IMG_WW'))}
	value 12
	value_format long
} {
	value 12
	value_format long
}

pip_add_usr_par [ipx::current_core] {BR_DW} {
	display_name {Blockram Data Width}
	tooltip {Blockram Data Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 32
	value_format long
	value_validation_type list
	value_validation_list {32}
} {
	value 32
	value_format long
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
