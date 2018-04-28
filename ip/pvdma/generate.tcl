set origin_dir [lindex $argv 0]

source $origin_dir/scripts/aux/util.tcl

# create project
create_project pvdma $origin_dir/pvdma -part xc7z020clg400-1
set_property simulator_language Verilog [current_project]

# update ips
# @note: must use [list xx yy]. the {xx yy} form cannot extent $ rightly.
set_property ip_repo_paths $origin_dir/ip [current_project]
update_ip_catalog

################################## create board design: pvdma ##############################
create_bd_design "pvdma"

create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:mutex_buffer_ctl:$VERSION mutex_buffer_ctl_0
set_property -dict [list CONFIG.C_ADDR_WIDTH {32}] [get_bd_cells mutex_buffer_ctl_0]

create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:mm2s:$VERSION mm2s_0
set_property -dict [list \
	CONFIG.C_PIXEL_WIDTH {8} \
	CONFIG.C_IMG_WBITS {12} \
	CONFIG.C_IMG_HBITS {12} \
	CONFIG.C_M_AXI_BURST_LEN {8} \
	CONFIG.C_M_AXI_DATA_WIDTH {64} \
] [get_bd_cells mm2s_0]

create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:s2mm:$VERSION s2mm_0
set_property -dict [list \
	CONFIG.C_PIXEL_WIDTH {8} \
	CONFIG.C_IMG_WBITS {12} \
	CONFIG.C_IMG_HBITS {12} \
	CONFIG.C_M_AXI_BURST_LEN {8} \
	CONFIG.C_M_AXI_DATA_WIDTH {64} \
] [get_bd_cells s2mm_0]

create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axi_combiner:$VERSION axi_combiner_0
set_property -dict [list \
	CONFIG.C_M_AXI_ADDR_WIDTH {32} \
	CONFIG.C_M_AXI_DATA_WIDTH {64} \
] [get_bd_cells axi_combiner_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 fifo_mm2s
set_property -dict [list \
	CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
	CONFIG.INTERFACE_TYPE {Native} \
	CONFIG.Input_Data_Width {80} \
	CONFIG.Input_Depth {128} \
	CONFIG.Output_Data_Width {10} \
	CONFIG.Output_Depth {1024} \
	CONFIG.Reset_Type {Asynchronous_Reset} \
	CONFIG.Full_Flags_Reset_Value {1} \
] [get_bd_cells fifo_mm2s]

create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 fifo_s2mm
set_property -dict [list \
	CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
	CONFIG.Input_Data_Width {10} \
	CONFIG.Input_Depth {1024} \
	CONFIG.Output_Data_Width {80} \
	CONFIG.Output_Depth {128} \
	CONFIG.Reset_Type {Asynchronous_Reset} \
	CONFIG.Full_Flags_Reset_Value {1} \
] [get_bd_cells fifo_s2mm]

# eternal interface
# data
make_bd_intf_pins_external \
 	[get_bd_intf_pins s2mm_0/S_AXIS] \
	[get_bd_intf_pins mm2s_0/M_AXIS] \
	[get_bd_intf_pins axi_combiner_0/M_AXI]

# cfg
make_bd_pins_external \
	[get_bd_pins mm2s_0/img_height] \
	[get_bd_pins mm2s_0/img_width] \
	[get_bd_pins mutex_buffer_ctl_0/buf0_addr] \
	[get_bd_pins mutex_buffer_ctl_0/buf1_addr] \
	[get_bd_pins mutex_buffer_ctl_0/buf2_addr] \
	[get_bd_pins mutex_buffer_ctl_0/buf3_addr]

# signal
make_bd_pins_external \
	[get_bd_intf_pins mutex_buffer_ctl_0/MBUF_R0] \
	[get_bd_pins mm2s_0/fsync]

# interrupt
make_bd_pins_external  [get_bd_pins mutex_buffer_ctl_0/intr]

# clock & reset
make_bd_pins_external \
	[get_bd_pins mutex_buffer_ctl_0/clk] \
	[get_bd_pins mutex_buffer_ctl_0/resetn] \
	[get_bd_pins mm2s_0/soft_resetn]

set_property CONFIG.ASSOCIATED_BUSIF {S_AXIS:M_AXIS:M_AXI} [get_bd_ports /clk]

############################## connect #########################################
connect_bd_intf_net [get_bd_intf_pins s2mm_0/MBUF_W] [get_bd_intf_pins mutex_buffer_ctl_0/MBUF_W]
connect_bd_intf_net [get_bd_intf_pins mutex_buffer_ctl_0/MBUF_R1] [get_bd_intf_pins mm2s_0/MBUF_R]

connect_bd_net [get_bd_ports clk] [get_bd_pins mm2s_0/f2s_aclk]
connect_bd_net [get_bd_ports clk] [get_bd_pins mm2s_0/m2f_aclk]
connect_bd_net [get_bd_ports clk] [get_bd_pins s2mm_0/s2f_aclk]
connect_bd_net [get_bd_ports clk] [get_bd_pins s2mm_0/f2m_aclk]
connect_bd_net [get_bd_ports clk] [get_bd_pins axi_combiner_0/clk]
connect_bd_net [get_bd_ports clk] [get_bd_pins fifo_s2mm/clk]
connect_bd_net [get_bd_ports clk] [get_bd_pins fifo_mm2s/clk]

connect_bd_net [get_bd_ports resetn] [get_bd_pins mm2s_0/resetn]
connect_bd_net [get_bd_ports resetn] [get_bd_pins s2mm_0/resetn]

connect_bd_intf_net [get_bd_intf_pins s2mm_0/M_AXI] [get_bd_intf_pins axi_combiner_0/S_AXI_W]
connect_bd_intf_net [get_bd_intf_pins mm2s_0/M_AXI] [get_bd_intf_pins axi_combiner_0/S_AXI_R]

connect_bd_intf_net [get_bd_intf_pins mm2s_0/FIFO_WRITE] [get_bd_intf_pins fifo_mm2s/FIFO_WRITE]
connect_bd_intf_net [get_bd_intf_pins mm2s_0/FIFO_READ] [get_bd_intf_pins fifo_mm2s/FIFO_READ]
connect_bd_net [get_bd_pins mm2s_0/resetting] [get_bd_pins fifo_mm2s/rst]
connect_bd_intf_net [get_bd_intf_pins s2mm_0/FIFO_WRITE] [get_bd_intf_pins fifo_s2mm/FIFO_WRITE]
connect_bd_intf_net [get_bd_intf_pins s2mm_0/FIFO_READ] [get_bd_intf_pins fifo_s2mm/FIFO_READ]
connect_bd_net [get_bd_pins s2mm_0/resetting] [get_bd_pins fifo_s2mm/rst]

connect_bd_net [get_bd_ports img_width] [get_bd_pins s2mm_0/img_width]
connect_bd_net [get_bd_ports img_height] [get_bd_pins s2mm_0/img_height]

# save board design
save_bd_design

# package
ipx::package_project -root_dir $origin_dir/ip/pvdma -vendor $VENDOR -library $LIBRARY -taxonomy $TAXONOMY -module pvdma -import_files
set_property version $VERSION [ipx::find_open_core $VENDOR:$LIBRARY:pvdma:1.0]

pip_set_prop [ipx::find_open_core $VENDOR:$LIBRARY:pvdma:$VERSION] [subst {
	display_name {Private VDMA}
	description {Private Video DMA}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}]

ipx::create_xgui_files [ipx::find_open_core $VENDOR:$LIBRARY:pvdma:$VERSION]
ipx::update_checksums [ipx::find_open_core $VENDOR:$LIBRARY:pvdma:$VERSION]
ipx::save_core [ipx::find_open_core $VENDOR:$LIBRARY:pvdma:$VERSION]
update_ip_catalog -rebuild -repo_path $origin_dir/ip
