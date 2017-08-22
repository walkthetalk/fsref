
source $origin_dir/scripts/aux/util.tcl

proc create_pvdma {
	mname
	{direction {bidirection}}
	{pixel_width 8}
	{img_w_width 12}
	{img_h_width 12}
	{addr_width 32}
	{data_width 64}
	{burst_length 16}
	{fifo_aximm_depth 128}
} {
	global VENDOR
	global LIBRARY
	global VERSION

	set dir_s2mm 0
	set dir_mm2s 0
	set bidirection 0
	puts "direction is: $direction"
	set dir_list {}
	if {$direction == {s2mm}} {
		set dir_s2mm 1
		set dir_list {s2mm}
	} elseif {$direction == {mm2s}} {
		set dir_mm2s 1
		set dir_list {mm2s}
	} else {
		set dir_s2mm 1
		set dir_mm2s 1
		set bidirection 1
		set dir_list {s2mm mm2s}
	}

	puts "dirlist: $dir_list"

	set datacount_width [log2 $fifo_aximm_depth]

	create_bd_cell -type hier $mname

	if {$dir_mm2s == 1} {
		startgroup
		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:mm2s:$VERSION $mname/mm2s
		endgroup
		startgroup
		set_property -dict [list \
			CONFIG.C_PIXEL_WIDTH $pixel_width \
			CONFIG.C_IMG_WBITS $img_w_width \
			CONFIG.C_IMG_HBITS $img_h_width \
			CONFIG.C_M_AXI_BURST_LEN $burst_length \
			CONFIG.C_M_AXI_ADDR_WIDTH $addr_width \
			CONFIG.C_M_AXI_DATA_WIDTH $data_width \
			CONFIG.C_DATACOUNT_BITS $datacount_width \
		] [get_bd_cells $mname/mm2s]
		endgroup

		set pixel_store_width [get_property CONFIG.C_PIXEL_STORE_WIDTH [get_bd_cells $mname/mm2s]]
		set adata_pixels [expr {$data_width/$pixel_store_width}]
		set fifo_axis_width [expr {$pixel_width+2}]
		set fifo_aximm_width [expr {$fifo_axis_width*$adata_pixels}]

		startgroup
		create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 $mname/fifo_mm2s
		endgroup
		startgroup
		set_property -dict [list \
			CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
			CONFIG.INTERFACE_TYPE {Native} \
			CONFIG.Input_Data_Width $fifo_aximm_width \
			CONFIG.Input_Depth $fifo_aximm_depth \
			CONFIG.Output_Data_Width $fifo_axis_width \
			CONFIG.Write_Data_Count {true} \
			CONFIG.Reset_Type {Synchronous_Reset} \
		] [get_bd_cells $mname/fifo_mm2s]
		endgroup

		create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/M_AXIS
		connect_bd_intf_net [get_bd_intf_pins $mname/M_AXIS] [get_bd_intf_pins $mname/mm2s/M_AXIS]

		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/FIFO_WRITE] [get_bd_intf_pins $mname/fifo_mm2s/FIFO_WRITE]
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/FIFO_READ] [get_bd_intf_pins $mname/fifo_mm2s/FIFO_READ]
		connect_bd_net [get_bd_pins $mname/fifo_mm2s/wr_data_count] [get_bd_pins $mname/mm2s/mm2s_wr_data_count]

		# signal
		create_bd_pin -dir I $mname/fsync
		connect_bd_net [get_bd_pins $mname/fsync] [get_bd_pins $mname/mm2s/fsync]
	}

	if {$dir_s2mm == 1} {
		startgroup
		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:s2mm:$VERSION $mname/s2mm
		endgroup
		startgroup
		set_property -dict [list \
			CONFIG.C_PIXEL_WIDTH $pixel_width \
			CONFIG.C_IMG_WBITS $img_w_width \
			CONFIG.C_IMG_HBITS $img_h_width \
			CONFIG.C_M_AXI_BURST_LEN $burst_length \
			CONFIG.C_M_AXI_ADDR_WIDTH $addr_width \
			CONFIG.C_M_AXI_DATA_WIDTH $data_width \
			CONFIG.C_DATACOUNT_BITS $datacount_width \
		] [get_bd_cells $mname/s2mm]
		endgroup

		set pixel_store_width [get_property CONFIG.C_PIXEL_STORE_WIDTH [get_bd_cells $mname/s2mm]]
		set adata_pixels [expr {$data_width/$pixel_store_width}]
		set fifo_axis_width [expr {$pixel_width+2}]
		set fifo_aximm_width [expr {$fifo_axis_width*$adata_pixels}]

		startgroup
		create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 $mname/fifo_s2mm
		endgroup
		startgroup
		set_property -dict [list \
			CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
			CONFIG.Input_Data_Width $fifo_axis_width \
			CONFIG.Output_Data_Width $fifo_aximm_width \
			CONFIG.Output_Depth $fifo_aximm_depth \
			CONFIG.Read_Data_Count {true} \
			CONFIG.Reset_Type {Synchronous_Reset} \
		] [get_bd_cells $mname/fifo_s2mm]
		endgroup

		create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/S_AXIS
		connect_bd_intf_net [get_bd_intf_pins $mname/S_AXIS] [get_bd_intf_pins $mname/s2mm/S_AXIS]

		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/FIFO_WRITE] [get_bd_intf_pins $mname/fifo_s2mm/FIFO_WRITE]
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/FIFO_READ] [get_bd_intf_pins $mname/fifo_s2mm/FIFO_READ]
		connect_bd_net [get_bd_pins $mname/fifo_s2mm/rd_data_count] [get_bd_pins $mname/s2mm/s2mm_rd_data_count]
	}

	if {$bidirection == 1} {
		startgroup
		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:mutex_buffer:$VERSION $mname/mutex_buffer
		endgroup
		set_property -dict [list CONFIG.C_ADDR_WIDTH $addr_width] [get_bd_cells $mname/mutex_buffer]

		startgroup
		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axi_combiner:$VERSION $mname/axi_combiner
		endgroup
		startgroup
		set_property -dict [list \
			CONFIG.C_M_AXI_ADDR_WIDTH $addr_width \
			CONFIG.C_M_AXI_DATA_WIDTH $data_width \
		] [get_bd_cells $mname/axi_combiner]
		endgroup

		# interrupt
		create_bd_pin -dir O -type intr $mname/intr
		connect_bd_net [get_bd_pins $mname/intr] [get_bd_pins $mname/mutex_buffer/intr]
		# signal
		create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0 $mname/MBUF_R
		connect_bd_intf_net [get_bd_intf_pins $mname/MBUF_R] [get_bd_intf_pins $mname/mutex_buffer/MBUF_R0]
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/MBUF_R] [get_bd_intf_pins $mname/mutex_buffer/MBUF_R1]
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/MBUF_W] [get_bd_intf_pins $mname/mutex_buffer/MBUF_W]

		#cfg
		#     address
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:addr_array_rtl:1.0 $mname/BUF_ADDR
		connect_bd_intf_net [get_bd_intf_pins $mname/BUF_ADDR] [get_bd_intf_pins $mname/mutex_buffer/BUF_ADDR]
		#     image size
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/IMG_SIZE
		startgroup
		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:window_broadcaster:1.0.9 $mname/window_broadcaster
		endgroup
		startgroup
		set_property -dict [list \
			CONFIG.C_WBITS $img_w_width \
			CONFIG.C_HBITS $img_h_width \
			CONFIG.C_MASTER_NUM {2} \
			CONFIG.C_HAS_POSITION {false} \
			] [get_bd_cells $mname/window_broadcaster]
		endgroup
		connect_bd_intf_net [get_bd_intf_pins $mname/IMG_SIZE] [get_bd_intf_pins $mname/window_broadcaster/S_WIN]
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/IMG_SIZE] [get_bd_intf_pins $mname/window_broadcaster/M0_WIN]
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/IMG_SIZE] [get_bd_intf_pins $mname/window_broadcaster/M1_WIN]


		create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M_AXI
		connect_bd_intf_net [get_bd_intf_pins $mname/M_AXI] [get_bd_intf_pins $mname/axi_combiner/M_AXI]
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/M_AXI] [get_bd_intf_pins $mname/axi_combiner/S_AXI_R]
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/M_AXI] [get_bd_intf_pins $mname/axi_combiner/S_AXI_W]
	} elseif {$dir_s2mm == 1} {
		# signal
		create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0 $mname/MBUF_W
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/MBUF_R] [get_bd_intf_pins $mname/MBUF_W]

		create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M_AXI
		connect_bd_intf_net [get_bd_intf_pins $mname/M_AXI] [get_bd_intf_pins $mname/s2mm/M_AXI]
		#     image size
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/IMG_SIZE
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/IMG_SIZE] [get_bd_intf_pins $mname/IMG_SIZE]
	} elseif {$dir_mm2s == 1} {
		# signal
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0 $mname/MBUF_R
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/MBUF_R] [get_bd_intf_pins $mname/MBUF_R]

		create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M_AXI
		connect_bd_intf_net [get_bd_intf_pins $mname/M_AXI] [get_bd_intf_pins $mname/mm2s/M_AXI]
		#     image size
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/IMG_SIZE
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/IMG_SIZE] [get_bd_intf_pins $mname/IMG_SIZE]
	}

	# clock & reset
	create_bd_pin -dir I -type clk $mname/clk
	connect_bd_net [get_bd_pins $mname/clk] [get_bd_pins $mname/*/clk]

	create_bd_pin -dir I -type rst $mname/resetn
	connect_bd_net [get_bd_pins $mname/resetn] [get_bd_pins $mname/*/resetn]

	foreach i $dir_list {
		connect_bd_net [get_bd_pins $mname/$i/resetting] [get_bd_pins $mname/fifo_$i/srst]
	}

	create_bd_pin -dir I -type rst $mname/soft_resetn
	connect_bd_net [get_bd_pins $mname/soft_resetn] [get_bd_pins $mname/*/soft_resetn]
}
