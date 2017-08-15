set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -name axi_combiner -taxonomy $TAXONOMY $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_set_prop [ipx::current_core] {
	display_name {AXI MM Combiner}
	description {Combine read/ra and write/wa channel into one full AXI Bus}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}

pip_clr_def_if_par [ipx::current_core]

pip_add_bus_if [ipx::current_core] M_AXI {
	abstraction_type_vlnv {xilinx.com:interface:aximm_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:aximm:1.0}
	interface_mode {master}
} {
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
}

pip_add_bus_if [ipx::current_core] S_AXI_R {
	abstraction_type_vlnv {xilinx.com:interface:aximm_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:aximm:1.0}
	interface_mode {slave}
} {
	ARID	s_axi_arid
	ARADDR	s_axi_araddr
	ARLEN	s_axi_arlen
	ARSIZE	s_axi_arsize
	ARBURST	s_axi_arburst
	ARLOCK	s_axi_arlock
	ARCACHE	s_axi_arcache
	ARPROT	s_axi_arprot
	ARQOS	s_axi_arqos
	ARVALID	s_axi_arvalid
	ARREADY	s_axi_arready
	RID	s_axi_rid
	RDATA	s_axi_rdata
	RRESP	s_axi_rresp
	RLAST	s_axi_rlast
	RVALID	s_axi_rvalid
	RREADY	s_axi_rready
}

pip_add_bus_if [ipx::current_core] S_AXI_W {
	abstraction_type_vlnv {xilinx.com:interface:aximm_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:aximm:1.0}
	interface_mode {slave}
} {
	AWID	s_axi_awid
	AWADDR	s_axi_awaddr
	AWLEN	s_axi_awlen
	AWSIZE	s_axi_awsize
	AWBURST	s_axi_awburst
	AWLOCK	s_axi_awlock
	AWCACHE	s_axi_awcache
	AWPROT	s_axi_awprot
	AWQOS	s_axi_awqos
	AWVALID	s_axi_awvalid
	AWREADY	s_axi_awready
	WDATA	s_axi_wdata
	WSTRB	s_axi_wstrb
	WLAST	s_axi_wlast
	WVALID	s_axi_wvalid
	WREADY	s_axi_wready
	BID	s_axi_bid
	BRESP	s_axi_bresp
	BVALID	s_axi_bvalid
	BREADY	s_axi_bready
}

pip_add_bus_if [ipx::current_core] clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} {
	ASSOCIATED_BUSIF {M_AXI:S_AXI_W:S_AXI_R}
}

# parameters
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

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
