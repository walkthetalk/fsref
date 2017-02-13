set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -taxonomy /UserIP $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_clr_def_if_par [ipx::current_core]

pip_add_bus_if [ipx::current_core] M_AXI {
	abstraction_type_vlnv {xilinx.com:interface:aximm_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:aximm:1.0}
	interface_mode {master}
} {
	AWID	m_axi_awid
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
	BID	m_axi_bid
	BRESP	m_axi_bresp
	BVALID	m_axi_bvalid
	BREADY	m_axi_bready
	ARID	m_axi_arid
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
	RID	m_axi_rid
	RDATA	m_axi_rdata
	RRESP	m_axi_rresp
	RLAST	m_axi_rlast
	RVALID	m_axi_rvalid
	RREADY	m_axi_rready
}

pip_add_bus_if [ipx::current_core] FIFO_WRITE {
	abstraction_type_vlnv {xilinx.com:interface:fifo_write_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_write:1.0}
	interface_mode {master}
} {
	WR_DATA wr_data
	WR_EN wr_en
	FULL full
}

pip_add_bus_if [ipx::current_core] FIFO_READ {
	abstraction_type_vlnv {xilinx.com:interface:fifo_read_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_read:1.0}
	interface_mode {master}
} {
	RD_DATA rd_data
	RD_EN rd_en
	EMPTY empty
}

pip_add_bus_if [ipx::current_core] MBUF_W {
	abstraction_type_vlnv {user.org:user:mutex_buffer_rtl:1.0}
	bus_type_vlnv {user.org:user:mutex_buffer:1.0}
	interface_mode {slave}
} {
	SOF w_sof
	ADDR w_addr
}

pip_add_bus_if [ipx::current_core] MBUF_R {
	abstraction_type_vlnv {user.org:user:mutex_buffer_rtl:1.0}
	bus_type_vlnv {user.org:user:mutex_buffer:1.0}
	interface_mode {slave}
} {
	SOF r_sof
	ADDR r_addr
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
	ASSOCIATED_BUSIF {M_AXI:FIFO_WRITE:FIFO_READ:MBUF_W:MBUF_R}
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
	value_validation_list {8 16 32}
} {
	value 8
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_IMG_WH_WIDTH} {
	display_name {Image Width/Height Bit Width}
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

pip_add_usr_par [ipx::current_core] {C_M_AXI_BURST_LEN} {
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

pip_add_usr_par [ipx::current_core] {C_M_AXI_ADDR_WIDTH} {
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

pip_add_usr_par [ipx::current_core] {C_M_AXI_DATA_WIDTH} {
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

# address space
pip_add_address_space [ipx::current_core] M_AXI M_AXI_REG {
	width 32
	range 4294967296
	range_dependency {pow(2,(spirit:decode(id('MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH')) - 1) + 1)}
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