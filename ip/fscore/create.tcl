
source $origin_dir/scripts/aux/util.tcl
source $origin_dir/ip/pvdma/create.tcl

proc create_fscore {
	mname
	{coreversion {}}
	{pixel_width 8}
	{img_w_width 12}
	{img_h_width 12}
	{addr_width 32}
	{data_width 64}
	{burst_length 16}
	{fifo_aximm_depth 128}
} {
	if {$coreversion == {}} { set coreversion [format 0x%08x [clock seconds]] }

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
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
		CONFIG.C_IMG_WBITS $img_w_width \
		CONFIG.C_IMG_HBITS $img_h_width \
	] [get_bd_cells $mname/axis_window_*]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_scaler:$VERSION $mname/axis_scaler_1
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_scaler:$VERSION $mname/axis_scaler_2
	endgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
		CONFIG.C_RESO_WIDTH $img_w_width \
	] [get_bd_cells $mname/axis_scaler_*]
	puts "\n\nNOTE: 'axis_scaler' don't support different width/height of image!!\n\n"

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_relay:$VERSION $mname/axis_relay_1
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_relay:$VERSION $mname/axis_relay_2
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
	] [get_bd_cells $mname/axis_relay_*]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_bayer_extractor:$VERSION $mname/axis_bayer_extractor_1
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_bayer_extractor:$VERSION $mname/axis_bayer_extractor_2
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
	] [get_bd_cells $mname/axis_bayer_extractor_*]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_reshaper:$VERSION $mname/axis_reshaper_1
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_reshaper:$VERSION $mname/axis_reshaper_2
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
	] [get_bd_cells $mname/axis_reshaper_*]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_blender:$VERSION $mname/axis_blender
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_S1_PIXEL_WIDTH $pixel_width \
		CONFIG.C_S2_PIXEL_WIDTH $pixel_width \
		CONFIG.C_IMG_WBITS      $img_w_width \
		CONFIG.C_IMG_HBITS      $img_h_width \
	] [get_bd_cells $mname/axis_blender]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axilite2regctl:$VERSION $mname/axilite2regctl
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fsctl:$VERSION $mname/fsctl
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_CORE_VERSION $coreversion \
	] [get_bd_cells $mname/fsctl]
	endgroup

	pip_connect_intf_net [subst {
		$mname/axilite2regctl/M_REG_CTL $mname/fsctl/S_REG_CTL
		$mname/pvdma_0/M_AXIS           $mname/axis_blender/S0_AXIS
		$mname/pvdma_1/M_AXIS           $mname/axis_window_1/S_AXIS
		$mname/axis_window_1/M_AXIS     $mname/axis_scaler_1/S_AXIS
		$mname/axis_scaler_1/M_AXIS	$mname/axis_relay_1/S_AXIS
		$mname/axis_relay_1/M_AXIS	$mname/axis_blender/S1_AXIS
		$mname/pvdma_2/M_AXIS           $mname/axis_window_2/S_AXIS
		$mname/axis_window_2/M_AXIS     $mname/axis_scaler_2/S_AXIS
		$mname/axis_scaler_2/M_AXIS	$mname/axis_relay_2/S_AXIS
		$mname/axis_relay_2/M_AXIS	$mname/axis_blender/S2_AXIS
		$mname/fsctl/CMOS0BUF_ADDR      $mname/pvdma_1/BUF_ADDR
		$mname/fsctl/CMOS1BUF_ADDR      $mname/pvdma_2/BUF_ADDR
		$mname/fsctl/OUT_SIZE           $mname/axis_blender/OUT_SIZE
		$mname/fsctl/S0_DST             $mname/axis_blender/S0_WIN_CTL
		$mname/fsctl/S1_DST             $mname/axis_blender/S1_WIN_CTL
		$mname/fsctl/S2_DST             $mname/axis_blender/S2_WIN_CTL
		$mname/fsctl/S1_WIN             $mname/axis_window_1/S_WIN_CTL
		$mname/fsctl/S2_WIN             $mname/axis_window_2/S_WIN_CTL
		$mname/fsctl/S1_SCALE           $mname/axis_scaler_1/SCALE_CTL
		$mname/fsctl/S2_SCALE           $mname/axis_scaler_2/SCALE_CTL
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
		$mname/S0_AXIS                   $mname/axis_reshaper_1/S_AXIS
		$mname/axis_reshaper_1/M_AXIS    $mname/axis_bayer_extractor_1/S_AXIS
		$mname/axis_bayer_extractor_1/M_AXIS $mname/pvdma_1/S_AXIS
		$mname/S1_AXIS                   $mname/axis_reshaper_2/S_AXIS
		$mname/axis_reshaper_2/M_AXIS    $mname/axis_bayer_extractor_2/S_AXIS
		$mname/axis_bayer_extractor_2/M_AXIS $mname/pvdma_2/S_AXIS
		$mname/axis_blender/M_AXIS       $mname/M_AXIS
		$mname/fsctl/S0_SIZE             $mname/pvdma_0/IMG_SIZE
		$mname/fsctl/S1_SIZE             $mname/pvdma_1/IMG_SIZE
		$mname/fsctl/S2_SIZE             $mname/pvdma_2/IMG_SIZE
	}]
	pip_connect_net [subst {
		$mname/fsctl/s0_soft_resetn $mname/pvdma_0/soft_resetn
		$mname/fsctl/s1_soft_resetn $mname/pvdma_1/soft_resetn
		$mname/fsctl/s2_soft_resetn $mname/pvdma_2/soft_resetn
	}]

	pip_connect_pin $mname/fsctl/s1_soft_resetn [subst {
		$mname/axis_window_1/resetn
		$mname/axis_scaler_1/resetn
		$mname/axis_relay_1/resetn
		$mname/axis_bayer_extractor_1/resetn
		$mname/axis_reshaper_1/resetn
	}]

	pip_connect_pin $mname/fsctl/s2_soft_resetn [subst {
		$mname/axis_window_2/resetn
		$mname/axis_scaler_2/resetn
		$mname/axis_relay_2/resetn
		$mname/axis_bayer_extractor_2/resetn
		$mname/axis_reshaper_2/resetn
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
		$mname/axis_scaler_1/fsync
		$mname/axis_scaler_2/fsync
	}]
	create_bd_pin -dir I $mname/clk
	pip_connect_pin $mname/clk [subst {
		$mname/fsctl/o_clk
		$mname/pvdma_0/clk
		$mname/pvdma_1/clk
		$mname/pvdma_2/clk
		$mname/axis_window_1/clk
		$mname/axis_window_2/clk
		$mname/axis_scaler_1/clk
		$mname/axis_scaler_2/clk
		$mname/axis_relay_1/clk
		$mname/axis_relay_2/clk
		$mname/axis_bayer_extractor_1/clk
		$mname/axis_bayer_extractor_2/clk
		$mname/axis_reshaper_1/clk
		$mname/axis_reshaper_2/clk
		$mname/axis_blender/clk
	}]
	create_bd_pin -dir I $mname/resetn
	pip_connect_pin $mname/resetn [subst {
		$mname/fsctl/o_resetn
		$mname/pvdma_0/resetn
		$mname/pvdma_1/resetn
		$mname/pvdma_2/resetn
		$mname/axis_blender/resetn
	}]
}
