pip_add_bus_if $core S_AXI_LITE {
	abstraction_type_vlnv {xilinx.com:interface:aximm_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:aximm:1.0}
	interface_mode {slave}
} {
	AWADDR	s_axi_awaddr
	AWVALID	s_axi_awvalid
	AWREADY	s_axi_awready
	WDATA	s_axi_wdata
	WVALID	s_axi_wvalid
	WREADY	s_axi_wready
	BRESP	s_axi_bresp
	BVALID	s_axi_bvalid
	BREADY	s_axi_bready

	ARADDR	s_axi_araddr
	ARVALID	s_axi_arvalid
	ARREADY	s_axi_arready
	RDATA	s_axi_rdata
	RRESP	s_axi_rresp
	RVALID	s_axi_rvalid
	RREADY	s_axi_rready
}

pip_add_bus_if $core M_REG_CTL [subst {
	abstraction_type_vlnv {$VENDOR:interface:reg_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:reg_ctl:1.0}
	interface_mode {master}
}] {
	RD_EN   rd_en
	RD_ADDR rd_addr
	RD_DATA rd_data
	WR_EN   wr_en
	WR_ADDR wr_addr
	WR_DATA wr_data
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

pip_add_bus_if $core clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} {
	ASSOCIATED_BUSIF {S_AXI_LITE:M_REG_CTL}
	ASSOCIATED_RESET {resetn}
}

# parameters
pip_add_usr_par $core {C_DATA_WIDTH} {
	display_name {Data Width}
	tooltip {DATA WIDTH}
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

pip_add_usr_par $core {C_ADDR_WIDTH} {
	display_name {Address Width}
	tooltip {ADDRESS WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 10
	value_format long
	value_validation_type list
	value_validation_list {10}
} {
	value 10
	value_format long
}

pip_add_usr_par $core {C_REG_IDX_WIDTH} {
	display_name {Register Index Width}
	tooltip {REG INDEX WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list 8
} {
	value 8
	value_format long
}

# address space
pip_add_memory_map $core S_AXI_LITE S_AXI_LITE_reg S_AXI_LITE {
	width 32
	range 4096
	usage register
}
