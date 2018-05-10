
source $origin_dir/ip/pvdma/create.tcl
source $origin_dir/ip/pblender/create.tcl

proc creat_stream {
	mname
	{fsa_ena 0}
	{channel_width 8}
	{img_w_width 12}
	{img_h_width 12}
	{addr_width 32}
	{data_width 64}
	{burst_length 16}
	{fifo_aximm_depth 128}
	{ts_width 64}
} {
	global VENDOR
	global LIBRARY
	global VERSION

	set pixel_width [expr $channel_width * 3]

	create_bd_cell -type hier $mname

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_reshaper:$VERSION $mname/axis_reshaper
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $channel_width \
	] [get_bd_cells $mname/axis_reshaper]

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_bayer_extractor:$VERSION $mname/axis_bayer_extractor
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $channel_width \
	] [get_bd_cells $mname/axis_bayer_extractor]

	create_pvdma $mname/pvdma bidirection $channel_width $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth $ts_width

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_window:$VERSION $mname/axis_window
	set_property -dict [list \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
		CONFIG.C_IMG_WBITS $img_w_width \
		CONFIG.C_IMG_HBITS $img_h_width \
	] [get_bd_cells $mname/axis_window]

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_scaler:$VERSION $mname/axis_scaler
	set_property -dict [list \
		CONFIG.C_CH0_WIDTH   $channel_width \
		CONFIG.C_CH1_WIDTH   $channel_width \
		CONFIG.C_CH2_WIDTH   $channel_width \
		CONFIG.C_PIXEL_WIDTH $pixel_width \
		CONFIG.C_SH_WIDTH    $img_h_width \
		CONFIG.C_SW_WIDTH    $img_w_width \
		CONFIG.C_MH_WIDTH    $img_h_width \
		CONFIG.C_MW_WIDTH    $img_w_width \
	] [get_bd_cells $mname/axis_scaler]

	# interfaces
	# input
	create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/S_AXIS
	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 $mname/M_AXIS
	pip_connect_intf_net [subst {
		$mname/S_AXIS                       $mname/axis_reshaper/S_AXIS
		$mname/axis_reshaper/M_AXIS         $mname/axis_bayer_extractor/S_AXIS
		$mname/axis_bayer_extractor/M_AXIS  $mname/pvdma/S_AXIS
		$mname/pvdma/M_AXIS                 $mname/axis_window/S_AXIS
		$mname/axis_window/M_AXIS           $mname/axis_scaler/S_AXIS
		$mname/axis_scaler/M_AXIS           $mname/M_AXIS
	}]

	create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0 $mname/MBUF_R
	pip_connect_intf_net [subst {$mname/MBUF_R     $mname/pvdma/MBUF_R}]
	create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:addr_array_rtl:1.0 $mname/BUF_ADDR
	pip_connect_intf_net [subst {$mname/BUF_ADDR   $mname/pvdma/BUF_ADDR}]
	create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/IMG_SIZE
	pip_connect_intf_net [subst {$mname/IMG_SIZE   $mname/pvdma/IMG_SIZE}]
	create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:window_ctl_rtl:1.0 $mname/M_WIN
	pip_connect_intf_net [subst {$mname/M_WIN      $mname/axis_window/S_WIN_CTL}]
	create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:scale_ctl_rtl:1.0 $mname/M_SCALE
	pip_connect_intf_net [subst {$mname/M_SCALE    $mname/axis_scaler/SCALE_CTL}]

	create_bd_pin -from [expr $ts_width - 1] -to 0 -dir I -type data $mname/sys_ts
	connect_bd_net [get_bd_pins $mname/sys_ts] [get_bd_pins $mname/pvdma/sys_ts]

	create_bd_pin -dir I $mname/fsync
	pip_connect_pin $mname/fsync [subst {
		$mname/pvdma/fsync
		$mname/axis_scaler/fsync
	}]

	# output
	create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $mname/M_AXI
	pip_connect_intf_net [subst {$mname/M_AXI    $mname/pvdma/M_AXI}]
	create_bd_pin -dir O $mname/wr_done
	pip_connect_pin $mname/pvdma/wr_done $mname/wr_done

	# clk/resetn
	create_bd_pin -dir I $mname/clk
	pip_connect_pin $mname/clk [subst {
		$mname/pvdma/clk
		$mname/axis_window/clk
		$mname/axis_scaler/clk
		$mname/axis_bayer_extractor/clk
		$mname/axis_reshaper/clk
	}]
	create_bd_pin -dir I $mname/resetn
	pip_connect_pin $mname/resetn [subst {
		$mname/pvdma/resetn
	}]
	create_bd_pin -dir I $mname/s_resetn
	pip_connect_pin $mname/s_resetn [subst {
		$mname/axis_reshaper/resetn
		$mname/axis_bayer_extractor/resetn
		$mname/pvdma/s2mm_resetn
	}]
	create_bd_pin -dir I $mname/m_resetn
	pip_connect_pin $mname/m_resetn [subst {
		$mname/axis_window/resetn
		$mname/axis_scaler/resetn
		$mname/pvdma/mm2s_resetn
	}]

	# fsa
	if {$fsa_ena == 1} {
		create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster:1.1 $mname/axis_broadcaster
		set_property -dict [list \
			CONFIG.M_TDATA_NUM_BYTES.VALUE_SRC USER \
			CONFIG.TID_WIDTH.VALUE_SRC USER \
			CONFIG.S_TDATA_NUM_BYTES.VALUE_SRC USER \
			CONFIG.TDEST_WIDTH.VALUE_SRC USER \
			CONFIG.M_TUSER_WIDTH.VALUE_SRC USER \
			CONFIG.S_TUSER_WIDTH.VALUE_SRC USER \
			CONFIG.HAS_TREADY.VALUE_SRC USER \
			CONFIG.HAS_TREADY {1} \
			CONFIG.HAS_TSTRB.VALUE_SRC USER \
			CONFIG.HAS_TKEEP.VALUE_SRC USER \
			CONFIG.HAS_TLAST.VALUE_SRC USER \
			CONFIG.HAS_TLAST {1} \
			CONFIG.M_TUSER_WIDTH {1} \
			CONFIG.S_TUSER_WIDTH {1} \
			CONFIG.M00_TUSER_REMAP {tuser[0:0]} \
			CONFIG.M01_TUSER_REMAP {tuser[0:0]} \
		] [get_bd_cells $mname/axis_broadcaster]

		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:window_broadcaster:$VERSION $mname/window_broadcaster
		set_property -dict [list CONFIG.C_HAS_POSITION {false}] [get_bd_cells $mname/window_broadcaster]

		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fsa:$VERSION $mname/fsa
		set_property -dict [list \
			CONFIG.C_OUT_DW {32} \
			CONFIG.C_OUT_DV {0xFFFF0000} \
		] [get_bd_cells $mname/fsa]

		create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axis_blender:$VERSION $mname/axis_blender
		set_property -dict [list \
			CONFIG.C_S1_CHN_NUM {3} \
			CONFIG.C_M_WIDTH $pixel_width \
			CONFIG.C_S1_ENABLE {true} \
		] [get_bd_cells $mname/axis_blender]

		delete_bd_objs [get_bd_intf_nets $mname/axis_bayer_extractor_M_AXIS]
		delete_bd_objs [get_bd_intf_nets $mname/pvdma_M_AXIS]
		delete_bd_objs [get_bd_intf_nets $mname/IMG_SIZE_1]
		pip_connect_intf_net [subst {
			$mname/axis_bayer_extractor/M_AXIS  $mname/axis_broadcaster/S_AXIS
			$mname/axis_broadcaster/M00_AXIS    $mname/pvdma/S_AXIS
			$mname/pvdma/M_AXIS                 $mname/axis_blender/S0_AXIS
			$mname/axis_broadcaster/M01_AXIS    $mname/fsa/S_AXIS
			$mname/fsa/M_AXIS                   $mname/axis_blender/S1_AXIS
			$mname/axis_blender/M_AXIS          $mname/axis_window/S_AXIS
			$mname/IMG_SIZE                     $mname/window_broadcaster/S_WIN
			$mname/window_broadcaster/M0_WIN    $mname/fsa/IMG_SIZE
			$mname/window_broadcaster/M1_WIN    $mname/pvdma/IMG_SIZE
		}]

		pip_connect_pin $mname/clk [subst {
			$mname/fsa/clk
			$mname/axis_blender/clk
			$mname/axis_broadcaster/aclk
		}]

		pip_connect_pin $mname/s_resetn [subst {
			$mname/fsa/resetn
			$mname/axis_broadcaster/aresetn
		}]

		pip_connect_pin $mname/m_resetn [subst {
			$mname/axis_blender/resetn
		}]

		pip_connect_pin $mname/fsync [subst {
			$mname/fsa/m_axis_fsync
		}]

		create_bd_pin -dir I $mname/fsa_disp_resetn
		pip_connect_pin $mname/fsa_disp_resetn [subst {
			$mname/fsa/m_axis_resetn
			$mname/axis_blender/s1_enable
		}]

		create_bd_intf_pin -mode Slave -vlnv $VENDOR:interface:fsa_ctl_rtl:1.0 $mname/FSA_CTL
		pip_connect_intf_net [subst {
			$mname/FSA_CTL  $mname/fsa/FSA_CTL
		}]

		create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:fsa_result_rtl:1.0 $mname/FSA_RESULT
		pip_connect_intf_net [subst {
			$mname/FSA_RESULT  $mname/fsa/FSA_RESULT
		}]

		create_bd_intf_pin -mode Master -vlnv $VENDOR:interface:fsa_result_rtl:1.0 $mname/FSA_RESULT_EXT
		pip_connect_intf_net [subst {
			$mname/FSA_RESULT_EXT  $mname/fsa/FSA_RESULT_EXT
		}]
	}
}

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
	{motor_br_addr_width 12}
	{motor_ms_width 3}
	{ts_width 64}
} {
	if {$coreversion == {}} { set coreversion [format 0x%08x [clock seconds]] }

	global VENDOR
	global LIBRARY
	global VERSION

	create_bd_cell -type hier $mname

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:timestamper:$VERSION $mname/sys_timestamper
	set_property -dict [list CONFIG.C_TS_WIDTH $ts_width] [get_bd_cells $mname/sys_timestamper]

	create_pvdma $mname/pvdma_T mm2s 32 $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth
	creat_stream $mname/stream0 1 $pixel_width $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth $ts_width
	creat_stream $mname/stream1 1 $pixel_width $img_w_width $img_h_width $addr_width $data_width $burst_length $fifo_aximm_depth $ts_width

	create_pblender $mname/pblender $pixel_width 12 12

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:step_motor:$VERSION $mname/push_motor
	set_property -dict [list \
		CONFIG.C_CLK_DIV_NBR 32 \
		CONFIG.C_MOTOR_NBR 2 \
		CONFIG.C_ZPD_SEQ {"11"} \
		CONFIG.C_MICROSTEP_PASSTHOUGH_SEQ {"11"} \
		CONFIG.C_STEP_NUMBER_WIDTH $motor_step_width \
		CONFIG.C_SPEED_DATA_WIDTH $motor_speed_width \
		CONFIG.C_SPEED_ADDRESS_WIDTH $motor_br_addr_width \
		CONFIG.C_MICROSTEP_WIDTH $motor_ms_width \
		CONFIG.C_OPT_BR_TIME {true} \
	] [get_bd_cells $mname/push_motor]

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:step_motor:$VERSION $mname/align_motor
	set_property -dict [list \
		CONFIG.C_CLK_DIV_NBR 32 \
		CONFIG.C_MOTOR_NBR 2 \
		CONFIG.C_ZPD_SEQ {"00"} \
		CONFIG.C_MICROSTEP_PASSTHOUGH_SEQ {"11"} \
		CONFIG.C_STEP_NUMBER_WIDTH $motor_step_width \
		CONFIG.C_SPEED_DATA_WIDTH $motor_speed_width \
		CONFIG.C_SPEED_ADDRESS_WIDTH $motor_br_addr_width \
		CONFIG.C_MICROSTEP_WIDTH $motor_ms_width \
		CONFIG.C_OPT_BR_TIME {true} \
	] [get_bd_cells $mname/align_motor]

		create_bd_cell -type ip -vlnv ocfb:pvip:pwm:1.0.9 $mname/pwm0
		set_property -dict [list \
			CONFIG.C_PWM_CNT_WIDTH {16} \
		] [get_bd_cells $mname/pwm0]

		create_bd_cell -type ip -vlnv ocfb:pvip:pwm:1.0.9 $mname/pwm1
		set_property -dict [list \
			CONFIG.C_PWM_CNT_WIDTH {16} \
		] [get_bd_cells $mname/pwm1]

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:axilite2regctl:$VERSION $mname/axilite2regctl

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fsctl:$VERSION $mname/fsctl
	set_property -dict [list \
		CONFIG.C_CORE_VERSION $coreversion \
		CONFIG.C_STREAM_NBR 2 \
		CONFIG.C_ST_ADDR 0x3FF00000 \
		CONFIG.C_S0_ADDR 0x3F000000 \
		CONFIG.C_S0_SIZE 0x00100000 \
		CONFIG.C_S1_ADDR 0x3F400000 \
		CONFIG.C_S1_SIZE 0x00100000 \
		CONFIG.C_BR_INITOR_NBR 3 \
		CONFIG.C_BR_ADDR_WIDTH [expr max($motor_br_addr_width, $img_w_width, $img_h_width)] \
		CONFIG.C_MOTOR_NBR 4 \
		CONFIG.C_ZPD_SEQ {"0011"} \
		CONFIG.C_STEP_NUMBER_WIDTH $motor_step_width \
		CONFIG.C_SPEED_DATA_WIDTH $motor_speed_width \
		CONFIG.C_MICROSTEP_WIDTH $motor_ms_width \
		CONFIG.C_PWM_NBR 2 \
	] [get_bd_cells $mname/fsctl]

	create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fscpu:$VERSION $mname/fscpu
	set_property -dict [list \
		CONFIG.C_IMG_WW $img_w_width \
		CONFIG.C_IMG_HW $img_h_width \
		CONFIG.C_STEP_NUMBER_WIDTH $motor_step_width \
		CONFIG.C_SPEED_DATA_WIDTH $motor_speed_width \
	] [get_bd_cells $mname/fscpu]

	pip_connect_intf_net [subst {
		$mname/axilite2regctl/M_REG_CTL $mname/fsctl/S_REG_CTL
		$mname/pvdma_T/M_AXIS           $mname/pblender/ST_AXIS
		$mname/stream0/M_AXIS           $mname/pblender/S0_AXIS
		$mname/stream1/M_AXIS           $mname/pblender/S1_AXIS
		$mname/fsctl/OUT_SIZE           $mname/pblender/OUT_SIZE
		$mname/fsctl/S0_ADDR            $mname/stream0/BUF_ADDR
		$mname/fsctl/S0_READ            $mname/stream0/MBUF_R
		$mname/fsctl/S0_WIN             $mname/stream0/M_WIN
		$mname/fsctl/S0_SCALE           $mname/stream0/M_SCALE
		$mname/fsctl/S0_FSA_CTL         $mname/stream0/FSA_CTL
		$mname/fsctl/S0_FSA_RESULT      $mname/stream0/FSA_RESULT
		$mname/fsctl/S1_ADDR            $mname/stream1/BUF_ADDR
		$mname/fsctl/S1_READ            $mname/stream1/MBUF_R
		$mname/fsctl/S1_WIN             $mname/stream1/M_WIN
		$mname/fsctl/S1_SCALE           $mname/stream1/M_SCALE
		$mname/fsctl/S1_FSA_CTL         $mname/stream1/FSA_CTL
		$mname/fsctl/S1_FSA_RESULT      $mname/stream1/FSA_RESULT
		$mname/fsctl/S0_DST             $mname/pblender/S0_POS
		$mname/fsctl/S1_DST             $mname/pblender/S1_POS
		$mname/fsctl/BR2_INIT_CTL	$mname/fscpu/BPM_INIT
		$mname/fsctl/REQ0_CTL           $mname/fscpu/REQ_CTL
		$mname/stream0/FSA_RESULT_EXT   $mname/fscpu/FSA_RESULT
		$mname/fscpu/Ml_REQ             $mname/push_motor/S0_EXT_REQ
		$mname/fscpu/Mr_REQ             $mname/push_motor/S1_EXT_REQ
	}]

	pip_connect_net [subst {
		$mname/fsctl/st_addr            $mname/pvdma_T/MBUF_R_addr
		$mname/fsctl/s0_dst_bmp         $mname/pblender/s0_dst_bmp
		$mname/fsctl/s1_dst_bmp         $mname/pblender/s1_dst_bmp
		$mname/fsctl/s0_wr_done         $mname/stream0/wr_done
		$mname/fsctl/s1_wr_done         $mname/stream1/wr_done
		$mname/fscpu/ml_sel             $mname/push_motor/s0_ext_sel
		$mname/fscpu/mr_sel             $mname/push_motor/s1_ext_sel
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
		$mname/stream0/M_AXI             $mname/M1_AXI
		$mname/stream1/M_AXI             $mname/M2_AXI
		$mname/S0_AXIS                   $mname/stream0/S_AXIS
		$mname/S1_AXIS                   $mname/stream1/S_AXIS
		$mname/pblender/M_AXIS           $mname/M_AXIS
		$mname/fsctl/ST_SIZE             $mname/pvdma_T/IMG_SIZE
		$mname/fsctl/S0_SIZE             $mname/stream0/IMG_SIZE
		$mname/fsctl/S1_SIZE             $mname/stream1/IMG_SIZE
		$mname/fsctl/BR0_INIT_CTL        $mname/push_motor/BR_INIT
		$mname/fsctl/MOTOR0_CFG          $mname/push_motor/S0_CFG
		$mname/fsctl/MOTOR0_REQ          $mname/push_motor/S0_REQ
		$mname/fsctl/MOTOR1_CFG          $mname/push_motor/S1_CFG
		$mname/fsctl/MOTOR1_REQ          $mname/push_motor/S1_REQ
		$mname/push_motor/M0             $mname/PUSH_MOTOR0_IC_CTL
		$mname/push_motor/M1             $mname/PUSH_MOTOR1_IC_CTL
		$mname/fsctl/BR1_INIT_CTL        $mname/align_motor/BR_INIT
		$mname/fsctl/MOTOR2_CFG          $mname/align_motor/S0_CFG
		$mname/fsctl/MOTOR2_REQ          $mname/align_motor/S0_REQ
		$mname/fsctl/MOTOR3_CFG          $mname/align_motor/S1_CFG
		$mname/fsctl/MOTOR3_REQ          $mname/align_motor/S1_REQ
		$mname/align_motor/M0            $mname/ALIGN_MOTOR0_IC_CTL
		$mname/align_motor/M1            $mname/ALIGN_MOTOR1_IC_CTL
		$mname/fsctl/PWM0_CTL            $mname/pwm0/S_CTL
		$mname/fsctl/PWM1_CTL            $mname/pwm1/S_CTL
	}]

	pip_connect_pin $mname/fsctl/st_out_resetn [subst {
		$mname/pvdma_T/mm2s_resetn
		$mname/pblender/st_enable
	}]

	pip_connect_pin $mname/sys_timestamper/ts [subst {
		$mname/stream0/sys_ts
		$mname/stream1/sys_ts
	}]

	pip_connect_pin $mname/fsctl/s0_in_resetn       $mname/stream0/s_resetn
	pip_connect_pin $mname/fsctl/s0_fsa_disp_resetn $mname/stream0/fsa_disp_resetn
	pip_connect_pin $mname/fsctl/s0_out_resetn      $mname/stream0/m_resetn
	pip_connect_pin $mname/fsctl/s1_in_resetn       $mname/stream1/s_resetn
	pip_connect_pin $mname/fsctl/s1_fsa_disp_resetn $mname/stream1/fsa_disp_resetn
	pip_connect_pin $mname/fsctl/s1_out_resetn      $mname/stream1/m_resetn
	pip_connect_pin $mname/fscpu/resetn             $mname/fsctl/reqctl0_resetn

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
		$mname/stream0/fsync
		$mname/stream1/fsync
		$mname/pblender/fsync
	}]
	create_bd_pin -dir I $mname/clk
	pip_connect_pin $mname/clk [subst {
		$mname/sys_timestamper/clk
		$mname/fsctl/o_clk
		$mname/pvdma_T/clk
		$mname/stream0/clk
		$mname/stream1/clk
		$mname/pblender/clk
		$mname/push_motor/clk
		$mname/align_motor/clk
		$mname/pwm0/clk
		$mname/pwm1/clk
		$mname/fscpu/clk
	}]
	create_bd_pin -dir I $mname/resetn
	pip_connect_pin $mname/resetn [subst {
		$mname/sys_timestamper/resetn
		$mname/fsctl/o_resetn
		$mname/pvdma_T/resetn
		$mname/stream0/resetn
		$mname/stream1/resetn
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

	create_bd_pin -dir O $mname/s0_in_resetn
	pip_connect_pin $mname/fsctl/s0_in_resetn [subst {
		$mname/s0_in_resetn
	}]

	create_bd_pin -dir O $mname/s1_in_resetn
	pip_connect_pin $mname/fsctl/s1_in_resetn [subst {
		$mname/s1_in_resetn
	}]

	create_bd_pin -dir O $mname/st_out_resetn
	pip_connect_pin $mname/fsctl/st_out_resetn [subst {
		$mname/st_out_resetn
	}]
}
