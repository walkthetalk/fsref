set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -name fsctl -taxonomy $TAXONOMY $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_set_prop [ipx::current_core] [subst {
	display_name {Fusion Splicer Controller}
	description {Fusion Splicer Controller}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}]

pip_clr_def_if_par_memmap [ipx::current_core]

pip_add_bus_if [ipx::current_core] S_REG_CTL [subst {
	abstraction_type_vlnv {$VENDOR:interface:reg_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:reg_ctl:1.0}
	interface_mode {slave}
}] {
	RD_EN   rd_en
	RD_ADDR rd_addr
	RD_DATA rd_data
	WR_EN   wr_en
	WR_ADDR wr_addr
	WR_DATA wr_data
}

pip_add_bus_if [ipx::current_core] OUT_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {master}
}] [subst {
	WIDTH  out_width
	HEIGHT out_height
}]

for {set i 0} {$i < 3} {incr i} {
	pip_add_bus_if [ipx::current_core] S[set i]_SIZE [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
	}] [subst {
		WIDTH  s[set i]_width
		HEIGHT s[set i]_height
	}]

	pip_add_bus_if [ipx::current_core] S[set i]_WIN [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
	}] [subst {
		LEFT   s[set i]_win_left
		WIDTH  s[set i]_win_width
		TOP    s[set i]_win_top
		HEIGHT s[set i]_win_height
	}]

	pip_add_bus_if [ipx::current_core] S[set i]_SCALE [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
	}] [subst {
		SRC_WIDTH  s[set i]_scale_src_width
		SRC_HEIGHT s[set i]_scale_src_height
		DST_WIDTH  s[set i]_scale_dst_width
		DST_HEIGHT s[set i]_scale_dst_height
	}]

	pip_add_bus_if [ipx::current_core] S[set i]_DST [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
	}] [subst {
		LEFT   s[set i]_dst_left
		WIDTH  s[set i]_dst_width
		TOP    s[set i]_dst_top
		HEIGHT s[set i]_dst_height
	}]
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
} {
	ASSOCIATED_BUSIF {S_REG_CTL}
	ASSOCIATED_RESET {resetn}
}

# parameters
pip_add_usr_par [ipx::current_core] {C_DATA_WIDTH} {
	display_name {Data Width}
	tooltip { DATA WIDTH}
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

pip_add_usr_par [ipx::current_core] {C_ADDR_WIDTH} {
	display_name {Address Width}
	tooltip {ADDRESS WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {8}
} {
	value 8
	value_format long
}
pip_add_usr_par [ipx::current_core] {C_IMG_WBITS} {
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

pip_add_usr_par [ipx::current_core] {C_IMG_HBITS} {
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
pip_add_usr_par [ipx::current_core] {C_IMG_WDEF} {
	display_name {Default Image Width}
	tooltip {Default Image Width}
	widget {textEdit}
} {
	value_resolve_type user
	value 320
	value_format long
} {
	value 320
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_IMG_HDEF} {
	display_name {Default Image Height}
	tooltip {Default Image Height}
	widget {textEdit}
} {
	value_resolve_type user
	value 240
	value_format long
} {
	value 240
	value_format long
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
