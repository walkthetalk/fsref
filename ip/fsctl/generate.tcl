set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -name fsctl -taxonomy $TAXONOMY $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_set_prop [ipx::current_core] [subst {
	display_name {FsCtl}
	description {Fusion Splice Controller}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}]

pip_clr_def_if_par_memmap [ipx::current_core]

pip_add_bus_if [ipx::current_core] S_AXI_LITE {
	abstraction_type_vlnv {xilinx.com:interface:aximm_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:aximm:1.0}
	interface_mode {slave}
} {
	AWADDR	s_axi_awaddr
	AWPROT	s_axi_awprot
	AWVALID	s_axi_awvalid
	AWREADY	s_axi_awready
	WDATA	s_axi_wdata
	WVALID	s_axi_wvalid
	WREADY	s_axi_wready
	BRESP	s_axi_bresp
	BVALID	s_axi_bvalid
	BREADY	s_axi_bready

	ARADDR	s_axi_araddr
	ARPROT	s_axi_arprot
	ARVALID	s_axi_arvalid
	ARREADY	s_axi_arready
	RDATA	s_axi_rdata
	RRESP	s_axi_rresp
	RVALID	s_axi_rvalid
	RREADY	s_axi_rready
}

# clock & reset
pip_add_bus_if [ipx::current_core] aresetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST aresetn
} {
	POLARITY {ACTIVE_LOW}
}

pip_add_bus_if [ipx::current_core] aclk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK aclk
} {
	ASSOCIATED_BUSIF {S_AXI_LITE}
	ASSOCIATED_RESET {aresetn}
}

# parameters
pip_add_usr_par [ipx::current_core] {C_S_AXI_DATA_WIDTH} {
	display_name {S_AXI_LITE Data Width}
	tooltip {S_AXI_LITE DATA WIDTH}
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

# address space
pip_add_memory_map [ipx::current_core] S_AXI_LITE S_AXI_LITE_reg S_AXI_LITE {
	width 32
	range 4096
	usage register
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
