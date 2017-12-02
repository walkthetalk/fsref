
source $origin_dir/scripts/aux/util.tcl

proc create_pblender {
	mname
	{pixel_width  8}
	{img_w_width 12}
	{img_h_width 12}
} {
	global VENDOR
	global LIBRARY
	global VERSION

	create_bd_cell -type hier $mname

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_generator:$VERSION $mname/background
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_WIN_NUM     2 \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
		CONFIG.C_IMG_WBITS   $img_w_width \
		CONFIG.C_IMG_HBITS   $img_h_width \
		CONFIG.C_EXT_FSYNC   1 \
	] [get_bd_cells $mname/background]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_interconnector:$VERSION $mname/axis_interconnector
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH  $pixel_width \
		CONFIG.C_S_STREAM_NUM 2 \
		CONFIG.C_M_STREAM_NUM 2 \
		CONFIG.C_ONE2MANY     0 \
	] [get_bd_cells $mname/axis_interconnector]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_blender:$VERSION $mname/blender0
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_CHN_WIDTH        $pixel_width \
		CONFIG.C_S0_CHN_NUM       1 \
		CONFIG.C_S1_CHN_NUM       1 \
		CONFIG.C_ALPHA_WIDTH	  0 \
		CONFIG.C_IN_NEED_WIDTH	  2 \
	] [get_bd_cells $mname/blender0]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_blender:$VERSION $mname/blender1
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_CHN_WIDTH        $pixel_width \
		CONFIG.C_S0_CHN_NUM       1 \
		CONFIG.C_S1_CHN_NUM       1 \
		CONFIG.C_ALPHA_WIDTH	  0 \
		CONFIG.C_IN_NEED_WIDTH	  1 \
	] [get_bd_cells $mname/blender1]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_blender:$VERSION $mname/blender2
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_CHN_WIDTH        $pixel_width \
		CONFIG.C_S0_CHN_NUM       1 \
		CONFIG.C_S1_CHN_NUM       3 \
		CONFIG.C_ALPHA_WIDTH	  8 \
		CONFIG.C_S1_ENABLE        {true} \
		CONFIG.C_IN_NEED_WIDTH	  0 \
	] [get_bd_cells $mname/blender2]
	endgroup

	# external interface
	create_bd_pin -dir I -type CLK $mname/clk
	create_bd_pin -dir I -type RST $mname/resetn
	create_bd_pin -dir I -type DATA $mname/fsync

	create_bd_pin -dir I -type RST $mname/st_enable

	create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0         $mname/OUT_SIZE
	for {set i 0} {$i < 2} {incr i} {
		create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0    $mname/S[set i]_AXIS
		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/S[set i]_POS
		create_bd_pin  -from 1 -to 0 -dir I -type data $mname/s[set i]_dst_bmp
	}

	create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0  $mname/ST_AXIS

	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/M_AXIS

	# connect
	pip_connect_intf_net [subst {
		$mname/S0_AXIS                     $mname/axis_interconnector/S0_AXIS
		$mname/S1_AXIS                     $mname/axis_interconnector/S1_AXIS
		$mname/axis_interconnector/M0_AXIS $mname/blender0/S1_AXIS
		$mname/axis_interconnector/M1_AXIS $mname/blender1/S1_AXIS
		$mname/background/M_AXIS           $mname/blender0/S0_AXIS
		$mname/blender0/M_AXIS             $mname/blender1/S0_AXIS
		$mname/blender1/M_AXIS             $mname/blender2/S0_AXIS
		$mname/ST_AXIS                     $mname/blender2/S1_AXIS
		$mname/blender2/M_AXIS             $mname/M_AXIS
		$mname/S0_POS                      $mname/background/S0_WIN
		$mname/S1_POS                      $mname/background/S1_WIN
		$mname/OUT_SIZE                    $mname/background/OUT_SIZE
	}]

	pip_connect_pin $mname/s0_dst_bmp                  $mname/background/s0_dst_bmp
	pip_connect_pin $mname/background/s0_dst_bmp_o     $mname/axis_interconnector/s0_dst_bmp
	pip_connect_pin $mname/s1_dst_bmp                  $mname/background/s1_dst_bmp
	pip_connect_pin $mname/background/s1_dst_bmp_o     $mname/axis_interconnector/s1_dst_bmp
	pip_connect_net [subst {
		$mname/st_enable $mname/blender2/s1_enable
		$mname/fsync     $mname/background/fsync
	}]

	pip_connect_pin $mname/clk [subst {
		$mname/background/clk
		$mname/axis_interconnector/clk
		$mname/blender0/clk
		$mname/blender1/clk
		$mname/blender2/clk
	}]

	pip_connect_pin $mname/resetn [subst {
		$mname/background/resetn
		$mname/axis_interconnector/resetn
		$mname/blender0/resetn
		$mname/blender1/resetn
		$mname/blender2/resetn
	}]
}
