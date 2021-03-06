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

pip_add_bus_if $core M_AXIS_INDEX [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {master}
}] {
	WIDTH   m_axis_source_x
	HEIGHT  m_axis_source_y
}


pip_add_bus_if $core MBUF_R [subst {
	abstraction_type_vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:mutex_buffer_ctl:1.0
	interface_mode master
}] {
	SOF sof
	ADDR frame_addr
}

pip_add_bus_if $core IMG_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	WIDTH   img_width
	HEIGHT  img_height
}

pip_add_bus_if $core SRC_WIN [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	WIDTH   win_width
	HEIGHT  win_height
	LEFT    win_left
	TOP     win_top
}

#NOTE: source size of scale same as WIDTH/HEIGHT of SRC_WIN
pip_add_bus_if $core SCALE_CTL [subst {
	abstraction_type_vlnv {$VENDOR:interface:scale_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:scale_ctl:1.0}
	interface_mode {slave}
}] {
	DST_WIDTH   dst_width
	DST_HEIGHT  dst_height
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
	ASSOCIATED_BUSIF {fsync:M_AXI:IMG_SIZE:MBUF_R:M_AXIS:M_AXIS_INDEX:SCALE_CTL:SRC_WIN}
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

pip_add_usr_par $core {C_IMG_STRIDE_SIZE} {
	display_name {Image Stride Size of Bytes}
	tooltip {IMAGE STRIDE SIZE OF BYTES, must not less than store_bytes_per_pixel * pixels_per_line, and must be devided by size_bytes_per_full_burst exactly.}
	widget {comboBox}
} {
	value_resolve_type user
	value 1024
	value_format long
	value_validation_type list
	value_validation_list {512 1024 2048 4096}
} {
	value 1024
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

pip_add_usr_par $core {C_MAXIS_CHANNEL} {
	display_name {M_AXIS Channel Number}
	tooltip {M_AXIS Channel Number, duplicated}
	widget {comboBox}
} {
	value_resolve_type user
	value 1
	value_format long
	value_validation_type list
	value_validation_list {1 3}
} {
	value 1
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
