set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -taxonomy /UserIP $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_clr_def_if_par [ipx::current_core]

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

pip_add_bus_if [ipx::current_core] M_AXIS {
	abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:axis:1.0}
	interface_mode {master}
} {
	TVALID	m_axis_tvalid
	TDATA	m_axis_tdata
	TUSER	m_axis_tuser
	TLAST	m_axis_tlast
	TREADY	m_axis_tready
}

pip_add_bus_if [ipx::current_core] FIFO0_WRITE {
	abstraction_type_vlnv {xilinx.com:interface:fifo_write_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_write:1.0}
	interface_mode {master}
} {
	WR_DATA	f0_wr_data
	WR_EN	f0_wr_en
	FULL	f0_full
}

pip_add_bus_if [ipx::current_core] FIFO0_READ {
	abstraction_type_vlnv {xilinx.com:interface:fifo_read_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_read:1.0}
	interface_mode {master}
} {
	RD_DATA	f0_rd_data
	RD_EN	f0_rd_en
	EMPTY	f0_empty
}

pip_add_bus_if [ipx::current_core] FIFO1_WRITE {
	abstraction_type_vlnv {xilinx.com:interface:fifo_write_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_write:1.0}
	interface_mode {master}
} {
	WR_DATA	f1_wr_data
	WR_EN	f1_wr_en
	FULL	f1_full
}

pip_add_bus_if [ipx::current_core] FIFO1_READ {
	abstraction_type_vlnv {xilinx.com:interface:fifo_read_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_read:1.0}
	interface_mode {master}
} {
	RD_DATA	f1_rd_data
	RD_EN	f1_rd_en
	EMPTY	f1_empty
}

pip_add_bus_if [ipx::current_core] FIFO2_WRITE {
	abstraction_type_vlnv {xilinx.com:interface:fifo_write_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_write:1.0}
	interface_mode {master}
} {
	WR_DATA	f2_wr_data
	WR_EN	f2_wr_en
	FULL	f2_full
}

pip_add_bus_if [ipx::current_core] FIFO2_READ {
	abstraction_type_vlnv {xilinx.com:interface:fifo_read_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_read:1.0}
	interface_mode {master}
} {
	RD_DATA	f2_rd_data
	RD_EN	f2_rd_en
	EMPTY	f2_empty
}

pip_add_bus_if [ipx::current_core] FIFO3_WRITE {
	abstraction_type_vlnv {xilinx.com:interface:fifo_write_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_write:1.0}
	interface_mode {master}
} {
	WR_DATA	f3_wr_data
	WR_EN	f3_wr_en
	FULL	f3_full
}

pip_add_bus_if [ipx::current_core] FIFO3_READ {
	abstraction_type_vlnv {xilinx.com:interface:fifo_read_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_read:1.0}
	interface_mode {master}
} {
	RD_DATA	f3_rd_data
	RD_EN	f3_rd_en
	EMPTY	f3_empty
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
	ASSOCIATED_BUSIF {S_AXIS:M_AXIS:FIFO0_WRITE:FIFO0_READ:FIFO1_WRITE:FIFO1_READ:FIFO2_WRITE:FIFO2_READ:FIFO3_WRITE:FIFO3_READ}
	ASSOCIATED_RESET {resetn}
}

# parameters
pip_add_usr_par [ipx::current_core] {C_PIXEL_WIDTH} {
	display_name {Pixel Width}
	tooltip {PIXEL WIDTH}
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

pip_add_usr_par [ipx::current_core] {C_BAYER_PHASE} {
	display_name {Bayer Phase}
	tooltip {BAYER PHASE}
	widget {comboBox}
} {
	value_resolve_type user
	value 0
	value_format long
	value_validation_type pairs
	value_validation_pairs {RGGB 0 GRBG 1 GBRG 2 BGGR 3}
} {
	value 0
	value_format long
}


# core prop
pip_set_prop [ipx::current_core] {
    core_revision 1
    supported_families {zynq Production}
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
