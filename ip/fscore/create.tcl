
source $origin_dir/scripts/aux/util.tcl
source $origin_dir/ip/pvdma/create.tcl

proc create_fscore {
	mname
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

	create_bd_cell -type hier $mname

	create_pvdma $mname/pvdma_0 mm2s 32 $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth
	create_pvdma $mname/pvdma_1 bidirection $pixel_width $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth
	create_pvdma $mname/pvdma_2 bidirection $pixel_width $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_window:$VERSION $mname/axis_window_1
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_window:$VERSION $mname/axis_window_2
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_blender:$VERSION $mname/axis_blender
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axilite2regctl:$VERSION $mname/axilite2regctl
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fsctl:$VERSION $mname/fsctl
	endgroup

	pip_connect_intf_net [subst {
		$mname/axilite2regctl/M_REG_CTL $mname/fsctl/S_REG_CTL
		$mname/pvdma_0/M_AXIS           $mname/axis_blender/S0_AXIS
		$mname/pvdma_1/M_AXIS           $mname/axis_window_1/S_AXIS
		$mname/axis_window_1/M_AXIS     $mname/axis_blender/S1_AXIS
		$mname/pvdma_2/M_AXIS           $mname/axis_window_2/S_AXIS
		$mname/axis_window_2/M_AXIS     $mname/axis_blender/S2_AXIS
		$mname/fsctl/CMOS0BUF_ADDR      $mname/pvdma_1/BUF_ADDR
		$mname/fsctl/CMOS1BUF_ADDR      $mname/pvdma_2/BUF_ADDR
		$mname/fsctl/OUT_SIZE           $mname/axis_blender/OUT_SIZE
		$mname/fsctl/S0_DST             $mname/axis_blender/S0_WIN_CTL
		$mname/fsctl/S1_DST             $mname/axis_blender/S1_WIN_CTL
		$mname/fsctl/S2_DST             $mname/axis_blender/S2_WIN_CTL
		$mname/fsctl/S1_WIN             $mname/axis_window_1/S_WIN_CTL
		$mname/fsctl/S2_WIN             $mname/axis_window_2/S_WIN_CTL
	}]
	pip_connect_net [subst {
		$mname/fsctl/dispbuf0_addr      $mname/pvdma_0/MBUF_R_addr
		$mname/fsctl/order_1over2       $mname/axis_blender/order_1over2
	}]

	# external interface
	create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/S_AXI_LITE

	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M0_AXI
	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M1_AXI
	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M2_AXI

	create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/S0_AXIS
	create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/S1_AXIS

	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/M_AXIS

	pip_connect_intf_net [subst {
		$mname/axilite2regctl/S_AXI_LITE $mname/S_AXI_LITE
		$mname/pvdma_0/M_AXI             $mname/M0_AXI
		$mname/pvdma_1/M_AXI             $mname/M1_AXI
		$mname/pvdma_2/M_AXI             $mname/M2_AXI
		$mname/pvdma_1/S_AXIS            $mname/S0_AXIS
		$mname/pvdma_2/S_AXIS            $mname/S1_AXIS
		$mname/axis_blender/M_AXIS       $mname/M_AXIS
		$mname/fsctl/S0_SIZE             $mname/pvdma_0/IMG_SIZE
		$mname/fsctl/S1_SIZE             $mname/pvdma_1/IMG_SIZE
		$mname/fsctl/S2_SIZE             $mname/pvdma_2/IMG_SIZE
	}]
	pip_connect_pin $mname/fsctl/soft_resetn [subst {
		$mname/pvdma_0/soft_resetn
		$mname/pvdma_1/soft_resetn
		$mname/pvdma_2/soft_resetn
	}]

	# external signal
	create_bd_pin -dir I $mname/s_axi_clk
	pip_connect_pin $mname/s_axi_clk [subst {
		$mname/axilite2regctl/clk
		$mname/fsctl/clk
	}]
	create_bd_pin -dir I $mname/s_axi_resetn
	pip_connect_pin $mname/s_axi_resetn [subst {
		$mname/axilite2regctl/resetn
		$mname/fsctl/resetn
	}]

	create_bd_pin -dir I $mname/fsync
	pip_connect_pin $mname/fsync $mname/fsctl/fsync
	pip_connect_pin $mname/fsctl/o_fsync [subst {
		$mname/pvdma_0/fsync
		$mname/pvdma_1/fsync
		$mname/pvdma_2/fsync
	}]
	create_bd_pin -dir I $mname/clk
	pip_connect_pin $mname/clk [subst {
		$mname/fsctl/o_clk
		$mname/pvdma_0/clk
		$mname/pvdma_1/clk
		$mname/pvdma_2/clk
		$mname/axis_window_1/clk
		$mname/axis_window_2/clk
		$mname/axis_blender/clk
	}]
	create_bd_pin -dir I $mname/resetn
	pip_connect_pin $mname/resetn [subst {
		$mname/fsctl/o_resetn
		$mname/pvdma_0/resetn
		$mname/pvdma_1/resetn
		$mname/pvdma_2/resetn
		$mname/axis_window_1/resetn
		$mname/axis_window_2/resetn
		$mname/axis_blender/resetn
	}]
}