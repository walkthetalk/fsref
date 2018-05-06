pip_add_bus_if $core vid_io_out {
	abstraction_type_vlnv {xilinx.com:interface:vid_io_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:vid_io:1.0}
	interface_mode {master}
} {
	ACTIVE_VIDEO vid_active_video
	DATA vid_data
	HBLANK vid_hblank
	HSYNC vid_hsync
	VBLANK vid_vblank
	VSYNC vid_vsync
}

pip_add_usr_par $core {C_DATA_WIDTH} {
	display_name {Data Width}
	tooltip {DATA WIDTH}
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
