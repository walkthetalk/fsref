pip_add_bus_if $core M_AXIS {
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

pip_add_bus_if $core MBUF_R [subst {
	abstraction_type_vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:mutex_buffer_ctl:1.0
	interface_mode master
}] {
	SOF r_sof
	ADDR r_addr
}

pip_add_bus_if $core IMG_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	WIDTH   img_width
	HEIGHT  img_height
}

pip_add_bus_if $core FIFO_WRITE {
	abstraction_type_vlnv {xilinx.com:interface:fifo_write_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_write:1.0}
	interface_mode {master}
} {
	WR_DATA mm2s_wr_data
	WR_EN mm2s_wr_en
	FULL mm2s_full
}

pip_add_bus_if $core FIFO_READ {
	abstraction_type_vlnv {xilinx.com:interface:fifo_read_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_read:1.0}
	interface_mode {master}
} {
	RD_DATA mm2s_rd_data
	RD_EN mm2s_rd_en
	EMPTY mm2s_empty
}

pip_add_bus_if $core resetting {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode master
} {
	RST resetting
} {
	POLARITY {ACTIVE_HIGH}
}

pip_add_bus_if $core M_AXI {
	abstraction_type_vlnv {xilinx.com:interface:aximm_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:aximm:1.0}
	interface_mode {master}
} {
	ARADDR	m_axi_araddr
	ARLEN	m_axi_arlen
	ARSIZE	m_axi_arsize
	ARBURST	m_axi_arburst
	ARLOCK	m_axi_arlock
	ARCACHE	m_axi_arcache
	ARPROT	m_axi_arprot
	ARQOS	m_axi_arqos
	ARVALID	m_axi_arvalid
	ARREADY	m_axi_arready
	RDATA	m_axi_rdata
	RRESP	m_axi_rresp
	RLAST	m_axi_rlast
	RVALID	m_axi_rvalid
	RREADY	m_axi_rready
}

# clock & reset
pip_add_bus_if $core resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST resetn
} {
	POLARITY {ACTIVE_LOW}
}

pip_add_bus_if $core soft_resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST soft_resetn
} {
	POLARITY {ACTIVE_LOW}
}

pip_add_bus_if $core fsync {
	abstraction_type_vlnv xilinx.com:signal:video_frame_sync_rtl:1.0
	bus_type_vlnv xilinx.com:signal:video_frame_sync:1.0
	interface_mode slave
} {
	FRAME_SYNC fsync
}

pip_add_bus_if $core clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} {
	ASSOCIATED_BUSIF {fsync:M_AXI:IMG_SIZE:FIFO_WRITE:MBUF_R:FIFO_READ:M_AXIS}
}

# parameters
pip_add_usr_par $core {C_PIXEL_WIDTH} {
	display_name {Pixel Width}
	tooltip {PIXEL WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {8 16 32}
} {
	value 8
	value_format long
}

pip_add_usr_par $core {C_IMG_WBITS} {
	display_name {Image Width (PIXEL) Bit Width}
	tooltip {IMAGE WIDTH/HEIGHT BIT WIDTH}
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

pip_add_usr_par $core {C_IMG_HBITS} {
	display_name {Image Height (PIXEL) Bit Width}
	tooltip {IMAGE WIDTH/HEIGHT BIT WIDTH}
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

pip_add_usr_par $core {C_DATACOUNT_BITS} {
	display_name {Write data count bits}
	tooltip {WR_DATA_COUNT_BITS}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {3 4 5 6 7 8 9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par $core {C_M_AXI_BURST_LEN} {
	display_name {Burst Length}
	tooltip {BURST LENGTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 16
	value_format long
	value_validation_type list
	value_validation_list {1 2 4 8 16 32 64 128 256}
} {
	value 16
	value_format long
}

pip_add_usr_par $core {C_M_AXI_ADDR_WIDTH} {
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

pip_add_usr_par $core {C_M_AXI_DATA_WIDTH} {
	display_name {Data Width}
	tooltip {DATA WIDTH}
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

pip_add_usr_par $core {C_PIXEL_STORE_WIDTH} {
	display_name {Pixel Store Width}
	tooltip {PIXEL STORE WIDTH}
	widget {textEdit}
} {
	enablement_value false
	value_resolve_type user
	value 8
	value_format long
	value_tcl_expr {expr ($C_PIXEL_WIDTH <= 8 ? 8 : ($C_PIXEL_WIDTH <= 16 ? 16 : ($C_PIXEL_WIDTH <= 32 ? 32 : 64)))}
} {
	value 8
	value_format long
}

# address space
pip_add_address_space $core M_AXI M_AXI_REG {
	width 32
	range 4294967296
	range_dependency {pow(2,(spirit:decode(id('MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH')) - 1) + 1)}
}
