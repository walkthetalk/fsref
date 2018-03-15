
source $origin_dir/scripts/aux/util.tcl
source $origin_dir/ip/pvdma/create.tcl
source $origin_dir/ip/pblender/create.tcl

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
	{motor_step_width 32}
	{motor_speed_width 32}
	{motor_br_addr_width 9}
	{motor_ms_width 3}
	{ts_width 64}
} {
	if {$coreversion == {}} { set coreversion [format 0x%08x [clock seconds]] }

	global VENDOR
	global LIBRARY
	global VERSION

	create_bd_cell -type hier $mname

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:timestamper:$VERSION $mname/sys_timestamper
	endgroup
	startgroup
	set_property -dict [list CONFIG.C_TS_WIDTH $ts_width] [get_bd_cells $mname/sys_timestamper]
	endgroup

	create_pvdma $mname/pvdma_T mm2s 32 $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth
	create_pvdma $mname/pvdma_0 bidirection $pixel_width $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth $ts_width
	create_pvdma $mname/pvdma_1 bidirection $pixel_width $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth $ts_width

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_window:$VERSION $mname/axis_window_0
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_window:$VERSION $mname/axis_window_1
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
		CONFIG.C_IMG_WBITS $img_w_width \
		CONFIG.C_IMG_HBITS $img_h_width \
	] [get_bd_cells $mname/axis_window_*]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_scaler:$VERSION $mname/axis_scaler_0
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_scaler:$VERSION $mname/axis_scaler_1
	endgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
		CONFIG.C_SH_WIDTH    $img_h_width \
		CONFIG.C_SW_WIDTH    $img_w_width \
		CONFIG.C_MH_WIDTH    $img_h_width \
		CONFIG.C_MW_WIDTH    $img_w_width \
	] [get_bd_cells $mname/axis_scaler_*]

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_bayer_extractor:$VERSION $mname/axis_bayer_extractor_0
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_bayer_extractor:$VERSION $mname/axis_bayer_extractor_1
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
	] [get_bd_cells $mname/axis_bayer_extractor_*]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_reshaper:$VERSION $mname/axis_reshaper_0
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_reshaper:$VERSION $mname/axis_reshaper_1
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
	] [get_bd_cells $mname/axis_reshaper_*]
	endgroup

	create_pblender $mname/pblender $pixel_width 12 12

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:step_motor:$VERSION $mname/push_motor
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_CLK_DIV_NBR 32 \
		CONFIG.C_MOTOR_NBR 2 \
		CONFIG.C_ZPD_SEQ {"11"} \
		CONFIG.C_MICROSTEP_PASSTHOUGH_SEQ {"11"} \
		CONFIG.C_STEP_NUMBER_WIDTH $motor_step_width \
		CONFIG.C_SPEED_DATA_WIDTH $motor_speed_width \
		CONFIG.C_SPEED_ADDRESS_WIDTH $motor_br_addr_width \
		CONFIG.C_MICROSTEP_WIDTH $motor_ms_width \
	] [get_bd_cells $mname/push_motor]
	endgroup

	startgroup
	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:step_motor:$VERSION $mname/align_motor
	endgroup
	startgroup
	set_property -dict [list \
		CONFIG.C_CLK_DIV_NBR 32 \
		CONFIG.C_MOTOR_NBR 2 \
		CONFIG.C_ZPD_SEQ {"00"} \
		CONFIG.C_MICROSTEP_PASSTHOUGH_SEQ {"11"} \
		CONFIG.C_STEP_NUMBER_WIDTH $motor_step_width \
		CONFIG.C_SPEED_DATA_WIDTH $motor_speed_width \
		CONFIG.C_SPEED_ADDRESS_WIDTH $motor_br_addr_width \
		CONFIG.C_MICROSTEP_WIDTH $motor_ms_width \
	] [get_bd_cells $mname/align_motor]
	endgroup

	startgroup
		create_bd_cell -type ip -vlnv ocfb:pvip:pwm:1.0.9 $mname/pwm0
		set_property -dict [list \
			CONFIG.C_PWM_CNT_WIDTH {16} \
		] [get_bd_cells $mname/pwm0]
	endgroup

	startgroup
		create_bd_cell -type ip -vlnv ocfb:pvip:pwm:1.0.9 $mname/pwm1
		set_property -dict [list \
			CONFIG.C_PWM_CNT_WIDTH {16} \
		] [get_bd_cells $mname/pwm1]
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
		CONFIG.C_STREAM_NBR 2 \
		CONFIG.C_ST_ADDR 0x3FF00000 \
		CONFIG.C_S0_ADDR 0x3F000000 \
		CONFIG.C_S0_SIZE 0x00100000 \
		CONFIG.C_S1_ADDR 0x3F400000 \
		CONFIG.C_S1_SIZE 0x00100000 \
		CONFIG.C_BR_INITOR_NBR 2 \
		CONFIG.C_BR_ADDR_WIDTH $motor_br_addr_width \
		CONFIG.C_MOTOR_NBR 4 \
		CONFIG.C_ZPD_SEQ {"0011"} \
		CONFIG.C_STEP_NUMBER_WIDTH $motor_step_width \
		CONFIG.C_SPEED_DATA_WIDTH $motor_speed_width \
		CONFIG.C_MICROSTEP_WIDTH $motor_ms_width \
		CONFIG.C_PWM_NBR 2 \
	] [get_bd_cells $mname/fsctl]
	endgroup

	pip_connect_intf_net [subst {
		$mname/axilite2regctl/M_REG_CTL $mname/fsctl/S_REG_CTL
		$mname/pvdma_T/M_AXIS           $mname/pblender/ST_AXIS
		$mname/pvdma_0/M_AXIS           $mname/axis_window_0/S_AXIS
		$mname/axis_window_0/M_AXIS     $mname/axis_scaler_0/S_AXIS
		$mname/axis_scaler_0/M_AXIS	$mname/pblender/S0_AXIS
		$mname/pvdma_1/M_AXIS           $mname/axis_window_1/S_AXIS
		$mname/axis_window_1/M_AXIS     $mname/axis_scaler_1/S_AXIS
		$mname/axis_scaler_1/M_AXIS	$mname/pblender/S1_AXIS
		$mname/fsctl/S0_ADDR            $mname/pvdma_0/BUF_ADDR
		$mname/fsctl/S1_ADDR            $mname/pvdma_1/BUF_ADDR
		$mname/fsctl/S0_READ            $mname/pvdma_0/MBUF_R
		$mname/fsctl/S1_READ            $mname/pvdma_1/MBUF_R
		$mname/fsctl/OUT_SIZE           $mname/pblender/OUT_SIZE
		$mname/fsctl/S0_DST             $mname/pblender/S0_POS
		$mname/fsctl/S1_DST             $mname/pblender/S1_POS
		$mname/fsctl/S0_WIN             $mname/axis_window_0/S_WIN_CTL
		$mname/fsctl/S1_WIN             $mname/axis_window_1/S_WIN_CTL
		$mname/fsctl/S0_SCALE           $mname/axis_scaler_0/SCALE_CTL
		$mname/fsctl/S1_SCALE           $mname/axis_scaler_1/SCALE_CTL
	}]
	pip_connect_net [subst {
		$mname/fsctl/st_addr            $mname/pvdma_T/MBUF_R_addr
		$mname/fsctl/s0_dst_bmp         $mname/pblender/s0_dst_bmp
		$mname/fsctl/s1_dst_bmp         $mname/pblender/s1_dst_bmp
		$mname/fsctl/s0_wr_done         $mname/pvdma_0/wr_done
		$mname/fsctl/s1_wr_done         $mname/pvdma_1/wr_done
	}]

	# external interface
	create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/S_AXI_LITE

	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M0_AXI
	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M1_AXI
	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M2_AXI

	create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/S0_AXIS
	create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/S1_AXIS

	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/M_AXIS

	create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:motor_ic_ctl_rtl:1.0 $mname/PUSH_MOTOR0_IC_CTL
	create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:motor_ic_ctl_rtl:1.0 $mname/PUSH_MOTOR1_IC_CTL
	create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:motor_ic_ctl_rtl:1.0 $mname/ALIGN_MOTOR0_IC_CTL
	create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:motor_ic_ctl_rtl:1.0 $mname/ALIGN_MOTOR1_IC_CTL

	pip_connect_intf_net [subst {
		$mname/axilite2regctl/S_AXI_LITE $mname/S_AXI_LITE
		$mname/pvdma_T/M_AXI             $mname/M0_AXI
		$mname/pvdma_0/M_AXI             $mname/M1_AXI
		$mname/pvdma_1/M_AXI             $mname/M2_AXI
		$mname/S0_AXIS                   $mname/axis_reshaper_0/S_AXIS
		$mname/axis_reshaper_0/M_AXIS    $mname/axis_bayer_extractor_0/S_AXIS
		$mname/axis_bayer_extractor_0/M_AXIS $mname/pvdma_0/S_AXIS
		$mname/S1_AXIS                   $mname/axis_reshaper_1/S_AXIS
		$mname/axis_reshaper_1/M_AXIS    $mname/axis_bayer_extractor_1/S_AXIS
		$mname/axis_bayer_extractor_1/M_AXIS $mname/pvdma_1/S_AXIS
		$mname/pblender/M_AXIS       $mname/M_AXIS
		$mname/fsctl/ST_SIZE             $mname/pvdma_T/IMG_SIZE
		$mname/fsctl/S0_SIZE             $mname/pvdma_0/IMG_SIZE
		$mname/fsctl/S1_SIZE             $mname/pvdma_1/IMG_SIZE
		$mname/fsctl/BR0_INIT_CTL        $mname/push_motor/BR_INIT
		$mname/fsctl/MOTOR0_CTL          $mname/push_motor/S0
		$mname/fsctl/MOTOR1_CTL          $mname/push_motor/S1
		$mname/push_motor/M0             $mname/PUSH_MOTOR0_IC_CTL
		$mname/push_motor/M1             $mname/PUSH_MOTOR1_IC_CTL
		$mname/fsctl/BR1_INIT_CTL        $mname/align_motor/BR_INIT
		$mname/fsctl/MOTOR2_CTL          $mname/align_motor/S0
		$mname/fsctl/MOTOR3_CTL          $mname/align_motor/S1
		$mname/align_motor/M0            $mname/ALIGN_MOTOR0_IC_CTL
		$mname/align_motor/M1            $mname/ALIGN_MOTOR1_IC_CTL
		$mname/fsctl/PWM0_CTL            $mname/pwm0/S_CTL
		$mname/fsctl/PWM1_CTL            $mname/pwm1/S_CTL
	}]

	pip_connect_pin $mname/fsctl/st_soft_resetn [subst {
		$mname/pvdma_T/soft_resetn
		$mname/pblender/st_enable
	}]

	pip_connect_pin $mname/sys_timestamper/ts [subst {
		$mname/pvdma_0/sys_ts
		$mname/pvdma_1/sys_ts
	}]

	pip_connect_pin $mname/fsctl/s0_soft_resetn [subst {
		$mname/pvdma_0/soft_resetn
		$mname/axis_window_0/resetn
		$mname/axis_scaler_0/resetn
		$mname/axis_bayer_extractor_0/resetn
		$mname/axis_reshaper_0/resetn
	}]

	pip_connect_pin $mname/fsctl/s1_soft_resetn [subst {
		$mname/pvdma_1/soft_resetn
		$mname/axis_window_1/resetn
		$mname/axis_scaler_1/resetn
		$mname/axis_bayer_extractor_1/resetn
		$mname/axis_reshaper_1/resetn
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
		$mname/pvdma_T/fsync
		$mname/pvdma_0/fsync
		$mname/pvdma_1/fsync
		$mname/axis_scaler_0/fsync
		$mname/axis_scaler_1/fsync
		$mname/pblender/fsync
	}]
	create_bd_pin -dir I $mname/clk
	pip_connect_pin $mname/clk [subst {
		$mname/sys_timestamper/clk
		$mname/fsctl/o_clk
		$mname/pvdma_T/clk
		$mname/pvdma_0/clk
		$mname/pvdma_1/clk
		$mname/axis_window_0/clk
		$mname/axis_window_1/clk
		$mname/axis_scaler_0/clk
		$mname/axis_scaler_1/clk
		$mname/axis_bayer_extractor_0/clk
		$mname/axis_bayer_extractor_1/clk
		$mname/axis_reshaper_0/clk
		$mname/axis_reshaper_1/clk
		$mname/pblender/clk
		$mname/push_motor/clk
		$mname/align_motor/clk
		$mname/pwm0/clk
		$mname/pwm1/clk
	}]
	create_bd_pin -dir I $mname/resetn
	pip_connect_pin $mname/resetn [subst {
		$mname/sys_timestamper/resetn
		$mname/fsctl/o_resetn
		$mname/pvdma_T/resetn
		$mname/pvdma_0/resetn
		$mname/pvdma_1/resetn
		$mname/pblender/resetn
		$mname/push_motor/resetn
		$mname/align_motor/resetn
	}]

	create_bd_pin -dir O $mname/cmos0_light
	pip_connect_pin $mname/pwm0/drive [subst {
		$mname/cmos0_light
	}]
	create_bd_pin -dir O $mname/cmos1_light
	pip_connect_pin $mname/pwm1/drive [subst {
		$mname/cmos1_light
	}]

	create_bd_pin -dir O -type intr $mname/intr
	pip_connect_pin $mname/fsctl/intr [subst {
		$mname/intr
	}]
}
