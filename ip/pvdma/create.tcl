
source $origin_dir/scripts/util.tcl

proc create_pvdma {
	mname
} {
	global VENDOR
	global LIBRARY
	global VERSION

	create_bd_cell -type hier $mname

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:mutex_buffer_ctl:$VERSION $mname/mutex_buffer_ctl
	endgroup
	set_property -dict [list CONFIG.C_ADDR_WIDTH {32}] [get_bd_cells $mname/mutex_buffer_ctl]

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:mm2s:$VERSION $mname/mm2s
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH {8} \
		CONFIG.C_IMG_WBITS {12} \
		CONFIG.C_IMG_HBITS {12} \
		CONFIG.C_M_AXI_BURST_LEN {8} \
		CONFIG.C_M_AXI_DATA_WIDTH {64} \
	] [get_bd_cells $mname/mm2s]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:s2mm:$VERSION $mname/s2mm
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH {8} \
		CONFIG.C_IMG_WBITS {12} \
		CONFIG.C_IMG_HBITS {12} \
		CONFIG.C_M_AXI_BURST_LEN {8} \
		CONFIG.C_M_AXI_DATA_WIDTH {64} \
	] [get_bd_cells $mname/s2mm]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axi_combiner:$VERSION $mname/axi_combiner
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_M_AXI_ADDR_WIDTH {32} \
		CONFIG.C_M_AXI_DATA_WIDTH {64} \
	] [get_bd_cells $mname/axi_combiner]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 $mname/fifo_mm2s
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
		CONFIG.INTERFACE_TYPE {Native} \
		CONFIG.Input_Data_Width {80} \
		CONFIG.Input_Depth {128} \
		CONFIG.Output_Data_Width {10} \
		CONFIG.Output_Depth {1024} \
		CONFIG.Reset_Type {Asynchronous_Reset} \
		CONFIG.Full_Flags_Reset_Value {1} \
	] [get_bd_cells $mname/fifo_mm2s]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 $mname/fifo_s2mm
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
		CONFIG.Input_Data_Width {10} \
		CONFIG.Input_Depth {1024} \
		CONFIG.Output_Data_Width {80} \
		CONFIG.Output_Depth {128} \
		CONFIG.Reset_Type {Asynchronous_Reset} \
		CONFIG.Full_Flags_Reset_Value {1} \
	] [get_bd_cells $mname/fifo_s2mm]
	endgroup

	# data
	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M_AXI
	connect_bd_intf_net [get_bd_intf_pins $mname/M_AXI] [get_bd_intf_pins $mname/axi_combiner/M_AXI]
	connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/M_AXI] [get_bd_intf_pins $mname/axi_combiner/S_AXI_R]
	connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/M_AXI] [get_bd_intf_pins $mname/axi_combiner/S_AXI_W]

	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/M_AXIS
	connect_bd_intf_net [get_bd_intf_pins $mname/M_AXIS] [get_bd_intf_pins $mname/mm2s/M_AXIS]

	create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/S_AXIS
	connect_bd_intf_net [get_bd_intf_pins $mname/S_AXIS] [get_bd_intf_pins $mname/s2mm/S_AXIS]

	connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/FIFO_WRITE] [get_bd_intf_pins $mname/fifo_mm2s/FIFO_WRITE]
	connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/FIFO_READ] [get_bd_intf_pins $mname/fifo_mm2s/FIFO_READ]

	connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/FIFO_WRITE] [get_bd_intf_pins $mname/fifo_s2mm/FIFO_WRITE]
	connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/FIFO_READ] [get_bd_intf_pins $mname/fifo_s2mm/FIFO_READ]

	# cfg
	for {set buf_idx 0} {$buf_idx < 4} {incr buf_idx} {
		create_bd_pin -dir I -from 31 -to 0 $mname/buf[set buf_idx]_addr
		connect_bd_net [get_bd_pins $mname/buf[set buf_idx]_addr] [get_bd_pins $mname/mutex_buffer_ctl/buf[set buf_idx]_addr]
	}
	foreach pinname [list img_height img_width] {
		create_bd_pin -dir I -from 11 -to 0 $mname/$pinname
		connect_bd_net [get_bd_pins $mname/$pinname] [get_bd_pins $mname/mm2s/$pinname]
		connect_bd_net [get_bd_pins $mname/$pinname] [get_bd_pins $mname/s2mm/$pinname]
	}

	# signal
	create_bd_intf_pin -mode Master -vlnv $VENDOR:$LIBRARY:mutex_buffer_rtl:1.0 $mname/MBUF_R
	connect_bd_intf_net [get_bd_intf_pins $mname/MBUF_R] [get_bd_intf_pins $mname/mutex_buffer_ctl/MBUF_R0]
	connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/MBUF_R] [get_bd_intf_pins $mname/mutex_buffer_ctl/MBUF_R1]
	connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/MBUF_W] [get_bd_intf_pins $mname/mutex_buffer_ctl/MBUF_W]

	create_bd_pin -dir I $mname/fsync
	connect_bd_net [get_bd_pins $mname/fsync] [get_bd_pins $mname/mm2s/fsync]


	# interrupt
	create_bd_pin -dir O -type intr $mname/intr
	connect_bd_net [get_bd_pins $mname/intr] [get_bd_pins $mname/mutex_buffer_ctl/intr]

	# clock & reset
	create_bd_pin -dir I -type clk $mname/clk
	connect_bd_net [get_bd_pins $mname/clk] [get_bd_pins $mname/mutex_buffer_ctl/clk]
	connect_bd_net [get_bd_pins $mname/clk] [get_bd_pins $mname/mm2s/clk]
	connect_bd_net [get_bd_pins $mname/clk] [get_bd_pins $mname/s2mm/clk]
	connect_bd_net [get_bd_pins $mname/clk] [get_bd_pins $mname/fifo_mm2s/clk]
	connect_bd_net [get_bd_pins $mname/clk] [get_bd_pins $mname/fifo_s2mm/clk]
	connect_bd_net [get_bd_pins $mname/clk] [get_bd_pins $mname/axi_combiner/clk]

	create_bd_pin -dir I -type rst $mname/resetn
	connect_bd_net [get_bd_pins $mname/resetn] [get_bd_pins $mname/mutex_buffer_ctl/resetn]
	connect_bd_net [get_bd_pins $mname/resetn] [get_bd_pins $mname/mm2s/resetn]
	connect_bd_net [get_bd_pins $mname/resetn] [get_bd_pins $mname/s2mm/resetn]

	connect_bd_net [get_bd_pins $mname/s2mm/resetting] [get_bd_pins $mname/fifo_s2mm/rst]
	connect_bd_net [get_bd_pins $mname/mm2s/resetting] [get_bd_pins $mname/fifo_mm2s/rst]

	create_bd_pin -dir I -type rst $mname/soft_resetn
	connect_bd_net [get_bd_pins $mname/soft_resetn] [get_bd_pins $mname/mm2s/soft_resetn]
	connect_bd_net [get_bd_pins $mname/soft_resetn] [get_bd_pins $mname/s2mm/soft_resetn]
}
