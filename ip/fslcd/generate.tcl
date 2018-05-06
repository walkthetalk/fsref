pip_add_bus_if $core vid_io_in {
	abstraction_type_vlnv {xilinx.com:interface:vid_io_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:vid_io:1.0}
	interface_mode {slave}
} {
	ACTIVE_VIDEO vid_active_video
	DATA vid_data
	HSYNC vid_hsync
	VSYNC vid_vsync
}

pip_add_bus_if $core vid_io_in_clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK vid_io_in_clk
} {
	ASSOCIATED_BUSIF vid_io_in
}

pip_add_usr_par $core {C_IN_COMP_WIDTH} {
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

pip_add_usr_par $core {C_OUT_COMP_WIDTH} {
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
