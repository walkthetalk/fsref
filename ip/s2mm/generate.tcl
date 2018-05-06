pip_add_bus_if $core MBUF_W [subst {
	abstraction_type_vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:mutex_buffer_ctl:1.0
	interface_mode master
}] {
	SOF s2mm_sof
	ADDR s2mm_addr
}

pip_add_bus_if $core IMG_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	WIDTH   img_width
	HEIGHT  img_height
}

pip_add_bus_if $core S_AXIS {
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

pip_add_bus_if $core M_AXI {
	abstraction_type_vlnv {xilinx.com:interface:aximm_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:aximm:1.0}
	interface_mode {master}
} {
	AWADDR	m_axi_awaddr
	AWLEN	m_axi_awlen
	AWSIZE	m_axi_awsize
	AWBURST	m_axi_awburst
	AWLOCK	m_axi_awlock
	AWCACHE	m_axi_awcache
	AWPROT	m_axi_awprot
	AWQOS	m_axi_awqos
	AWVALID	m_axi_awvalid
	AWREADY	m_axi_awready
	WDATA	m_axi_wdata
	WSTRB	m_axi_wstrb
	WLAST	m_axi_wlast
	WVALID	m_axi_wvalid
	WREADY	m_axi_wready
	BRESP	m_axi_bresp
	BVALID	m_axi_bvalid
	BREADY	m_axi_bready
}

pip_add_bus_if $core FIFO_WRITE {
	abstraction_type_vlnv {xilinx.com:interface:fifo_write_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_write:1.0}
	interface_mode {master}
} {
	WR_DATA s2mm_wr_data
	WR_EN s2mm_wr_en
	FULL s2mm_full
	ALMOST_FULL s2mm_almost_full
}

pip_add_bus_if $core FIFO_READ {
	abstraction_type_vlnv {xilinx.com:interface:fifo_read_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_read:1.0}
	interface_mode {master}
} {
	RD_DATA s2mm_rd_data
	RD_EN s2mm_rd_en
	EMPTY s2mm_empty
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

pip_add_bus_if $core clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} {
	ASSOCIATED_BUSIF {S_AXIS:IMG_SIZE:FIFO_WRITE:FIFO_READ:MBUF_W:M_AXI}
	ASSOCIATED_RESET {resetn}
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
	display_name {Read data count bits}
	tooltip {RD_DATA_COUNT_BITS}
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
