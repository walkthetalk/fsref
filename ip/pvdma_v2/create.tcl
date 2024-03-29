proc create_pvdma_v2 {
	mname
	{direction {bidirection}}
	{pixel_width 8}
	{img_w_width 12}
	{img_h_width 12}
	{addr_width 32}
	{data_width 64}
	{burst_length 16}
	{fifo_aximm_depth 128}
	{ts_width 64}
	{stride_size 1024}
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
		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:mm2s_adv:$VERSION $mname/mm2s
		set_property -dict [list \
			CONFIG.C_PIXEL_WIDTH $pixel_width \
			CONFIG.C_IMG_WBITS $img_w_width \
			CONFIG.C_IMG_HBITS $img_h_width \
			CONFIG.C_M_AXI_BURST_LEN $burst_length \
			CONFIG.C_M_AXI_ADDR_WIDTH $addr_width \
			CONFIG.C_M_AXI_DATA_WIDTH $data_width \
			CONFIG.C_IMG_STRIDE_SIZE $stride_size \
			CONFIG.C_MAXIS_CHANNEL 1 \
		] [get_bd_cells $mname/mm2s]

		create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/M_AXIS
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/M_AXIS] [get_bd_intf_pins $mname/M_AXIS]
		create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/M_AXIS_INDEX
		pip_connect_intf_net [subst {$mname/M_AXIS_INDEX      $mname/mm2s/M_AXIS_INDEX}]

		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/S_WIN
		pip_connect_intf_net [subst {$mname/S_WIN      $mname/mm2s/SRC_WIN}]
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:scale_ctl_rtl:1.0 $mname/S_SCALE
		pip_connect_intf_net [subst {$mname/S_SCALE    $mname/mm2s/SCALE_CTL}]

		# signal
		create_bd_pin -dir I $mname/fsync
		connect_bd_net [get_bd_pins $mname/mm2s/fsync] [get_bd_pins $mname/fsync]
	}

	if {$dir_s2mm == 1} {
		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:s2mm_adv:$VERSION $mname/s2mm
		set_property -dict [list \
			CONFIG.C_PIXEL_WIDTH $pixel_width \
			CONFIG.C_IMG_WBITS $img_w_width \
			CONFIG.C_IMG_HBITS $img_h_width \
			CONFIG.C_M_AXI_BURST_LEN $burst_length \
			CONFIG.C_M_AXI_ADDR_WIDTH $addr_width \
			CONFIG.C_M_AXI_DATA_WIDTH $data_width \
			CONFIG.C_DATACOUNT_BITS $datacount_width \
			CONFIG.C_IMG_STRIDE_SIZE $stride_size \
		] [get_bd_cells $mname/s2mm]

		set pixel_store_width [get_property CONFIG.C_PIXEL_STORE_WIDTH [get_bd_cells $mname/s2mm]]
		set adata_pixels [expr {$data_width/$pixel_store_width}]
		set fifo_axis_width [expr {$pixel_width+2}]
		set fifo_aximm_width [expr {$fifo_axis_width*$adata_pixels}]

		create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 $mname/fifo_s2mm
		set_property -dict [list \
			CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
			CONFIG.Input_Data_Width $fifo_axis_width \
			CONFIG.Output_Data_Width $fifo_aximm_width \
			CONFIG.Output_Depth $fifo_aximm_depth \
			CONFIG.Read_Data_Count {true} \
			CONFIG.Reset_Type {Synchronous_Reset} \
			CONFIG.Almost_Full_Flag {true} \
		] [get_bd_cells $mname/fifo_s2mm]

		create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/S_AXIS
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/S_AXIS] [get_bd_intf_pins $mname/S_AXIS]

		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/FIFO_WRITE] [get_bd_intf_pins $mname/fifo_s2mm/FIFO_WRITE]
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/FIFO_READ] [get_bd_intf_pins $mname/fifo_s2mm/FIFO_READ]
		connect_bd_net [get_bd_pins $mname/fifo_s2mm/rd_data_count] [get_bd_pins $mname/s2mm/s2mm_rd_data_count]
	}

	if {$bidirection == 1} {
		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:mutex_buffer:$VERSION $mname/mutex_buffer
		set_property -dict [list \
			CONFIG.C_ADDR_WIDTH $addr_width \
			CONFIG.C_TS_WIDTH   $ts_width \
		] [get_bd_cells $mname/mutex_buffer]

		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axi_combiner:$VERSION $mname/axi_combiner
		set_property -dict [list \
			CONFIG.C_M_AXI_ADDR_WIDTH $addr_width \
			CONFIG.C_M_AXI_DATA_WIDTH $data_width \
		] [get_bd_cells $mname/axi_combiner]

		# interrupt
		create_bd_pin -dir O $mname/wr_done
		connect_bd_net [get_bd_pins $mname/wr_done] [get_bd_pins $mname/mutex_buffer/wr_done]
		# signal
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0 $mname/MBUF_R
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/MBUF_R] [get_bd_intf_pins $mname/mutex_buffer/MBUF_R1]
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/MBUF_W] [get_bd_intf_pins $mname/mutex_buffer/MBUF_W]
		connect_bd_intf_net [get_bd_intf_pins $mname/mutex_buffer/MBUF_R0] [get_bd_intf_pins $mname/MBUF_R]

		create_bd_pin -from [expr $ts_width - 1] -to 0 -dir I -type data $mname/sys_ts
		connect_bd_net [get_bd_pins $mname/sys_ts] [get_bd_pins $mname/mutex_buffer/sys_ts]

		#cfg
		#     address
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:addr_array_rtl:1.0 $mname/BUF_ADDR
		connect_bd_intf_net [get_bd_intf_pins $mname/mutex_buffer/BUF_ADDR] [get_bd_intf_pins $mname/BUF_ADDR]
		#     image size
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/IMG_SIZE
		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:window_broadcaster:$VERSION $mname/size_broadcaster
		set_property -dict [list \
			CONFIG.C_WBITS $img_w_width \
			CONFIG.C_HBITS $img_h_width \
			CONFIG.C_MASTER_NUM {2} \
			CONFIG.C_HAS_POSITION {false} \
			] [get_bd_cells $mname/size_broadcaster]
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/IMG_SIZE] [get_bd_intf_pins $mname/size_broadcaster/M0_WIN]
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/IMG_SIZE] [get_bd_intf_pins $mname/size_broadcaster/M1_WIN]
		connect_bd_intf_net [get_bd_intf_pins $mname/size_broadcaster/S_WIN] [get_bd_intf_pins $mname/IMG_SIZE]

		create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M_AXI
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/M_AXI] [get_bd_intf_pins $mname/axi_combiner/S_AXI_R]
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/M_AXI] [get_bd_intf_pins $mname/axi_combiner/S_AXI_W]
		connect_bd_intf_net [get_bd_intf_pins $mname/axi_combiner/M_AXI] [get_bd_intf_pins $mname/M_AXI]
	} elseif {$dir_s2mm == 1} {
		# signal
		create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0 $mname/MBUF_W
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/MBUF_W] [get_bd_intf_pins $mname/MBUF_W]

		create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M_AXI
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/M_AXI] [get_bd_intf_pins $mname/M_AXI]
		#     image size
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/IMG_SIZE
		connect_bd_intf_net [get_bd_intf_pins $mname/s2mm/IMG_SIZE] [get_bd_intf_pins $mname/IMG_SIZE]
	} elseif {$dir_mm2s == 1} {
		# signal
		create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0 $mname/MBUF_R
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/MBUF_R] [get_bd_intf_pins $mname/MBUF_R]

		create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M_AXI
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/M_AXI] [get_bd_intf_pins $mname/M_AXI]
		#     image size
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/IMG_SIZE
		connect_bd_intf_net [get_bd_intf_pins $mname/mm2s/IMG_SIZE] [get_bd_intf_pins $mname/IMG_SIZE]
	}

	# clock & reset
	create_bd_pin -dir I -type clk $mname/clk
	connect_bd_net [get_bd_pins $mname/clk] [get_bd_pins $mname/*/clk]

	create_bd_pin -dir I -type rst $mname/resetn
	connect_bd_net [get_bd_pins $mname/resetn] [get_bd_pins $mname/*/resetn]

	if {$dir_s2mm == 1} {
		create_bd_pin -dir I -type rst $mname/s2mm_resetn
		connect_bd_net [get_bd_pins $mname/s2mm_resetn] [get_bd_pins $mname/s2mm/soft_resetn]

		connect_bd_net [get_bd_pins $mname/s2mm/resetting] [get_bd_pins $mname/fifo_s2mm/srst]
	}

	if {$dir_mm2s == 1} {
		create_bd_pin -dir I -type rst $mname/mm2s_resetn
		connect_bd_net [get_bd_pins $mname/mm2s_resetn] [get_bd_pins $mname/mm2s/soft_resetn]
	}
}
