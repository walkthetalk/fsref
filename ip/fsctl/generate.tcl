
define_associate_busif clk_busif
define_associate_busif clk_reset
define_associate_busif o_clk_busif
define_associate_busif o_clk_reset

pip_add_bus_if $core S_REG_CTL [subst {
	abstraction_type_vlnv {$VENDOR:interface:reg_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:reg_ctl:1.0}
	interface_mode {slave}
}] {
	RD_EN   rd_en
	RD_ADDR rd_addr
	RD_DATA rd_data
	WR_EN   wr_en
	WR_ADDR wr_addr
	WR_DATA wr_data
}
append_associate_busif clk_busif S_REG_CTL

pip_add_bus_if $core fsync {
	abstraction_type_vlnv xilinx.com:signal:video_frame_sync_rtl:1.0
	bus_type_vlnv xilinx.com:signal:video_frame_sync:1.0
	interface_mode slave
} {
	FRAME_SYNC fsync
}

pip_add_bus_if $core o_fsync {
	abstraction_type_vlnv xilinx.com:signal:video_frame_sync_rtl:1.0
	bus_type_vlnv xilinx.com:signal:video_frame_sync:1.0
	interface_mode master
} {
	FRAME_SYNC o_fsync
}
append_associate_busif o_clk_busif o_fsync

pip_add_bus_if $core OUT_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {master}
}] {
	WIDTH  out_width
	HEIGHT out_height
}
append_associate_busif o_clk_busif OUT_SIZE

pip_add_bus_if $core ST_ADDR [subst {
	abstraction_type_vlnv $VENDOR:interface:addr_array_rtl:1.0
	bus_type_vlnv $VENDOR:interface:addr_array:1.0
	interface_mode master
}] {
	ADDR0 st_addr
}
append_associate_busif o_clk_busif ST_ADDR

pip_add_bus_if $core ST_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {master}
}] {
	WIDTH  st_width
	HEIGHT st_height
}
append_associate_busif o_clk_busif ST_SIZE

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if $core S[set i]_READ [subst {
		abstraction_type_vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:mutex_buffer_ctl:1.0
		interface_mode master
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		SOF s[set i]_rd_en
		IDX s[set i]_rd_buf_idx
		TS  s[set i]_rd_buf_ts
	}]
	append_associate_busif o_clk_busif S[set i]_READ

	pip_add_bus_if $core s[set i]_wr_done [subst {
		abstraction_type_vlnv xilinx.com:signal:data_rtl:1.0
		bus_type_vlnv xilinx.com:signal:data:1.0
		interface_mode slave
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		DATA s[set i]_wr_done
	}]
	append_associate_busif o_clk_busif s[set i]_wr_done

	pip_add_bus_if $core s[set i]_dst_bmp [subst {
		abstraction_type_vlnv xilinx.com:signal:data_rtl:1.0
		bus_type_vlnv xilinx.com:signal:data:1.0
		interface_mode master
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		DATA s[set i]_dst_bmp
	}]
	append_associate_busif o_clk_busif s[set i]_dst_bmp

	pip_add_bus_if $core S[set i]_ADDR [subst {
		abstraction_type_vlnv $VENDOR:interface:addr_array_rtl:1.0
		bus_type_vlnv $VENDOR:interface:addr_array:1.0
		interface_mode master
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		ADDR0 s[set i]_buf0_addr
		ADDR1 s[set i]_buf1_addr
		ADDR2 s[set i]_buf2_addr
		ADDR3 s[set i]_buf3_addr
	}]
	append_associate_busif o_clk_busif S[set i]_ADDR

	pip_add_bus_if $core S[set i]_SIZE [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		WIDTH  s[set i]_width
		HEIGHT s[set i]_height
	}]
	append_associate_busif o_clk_busif S[set i]_SIZE

	pip_add_bus_if $core S[set i]_WIN [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		LEFT    s[set i]_win_left
		WIDTH   s[set i]_win_width
		TOP     s[set i]_win_top
		HEIGHT  s[set i]_win_height
	}]
	append_associate_busif o_clk_busif S[set i]_WIN

	pip_add_bus_if $core S[set i]_SCALE [subst {
		abstraction_type_vlnv {$VENDOR:interface:scale_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:scale_ctl:1.0}
		interface_mode {master}
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		SRC_WIDTH  s[set i]_scale_src_width
		SRC_HEIGHT s[set i]_scale_src_height
		DST_WIDTH  s[set i]_scale_dst_width
		DST_HEIGHT s[set i]_scale_dst_height
	}]
	append_associate_busif o_clk_busif S[set i]_SCALE

	pip_add_bus_if $core S[set i]_DST [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		LEFT    s[set i]_dst_left
		WIDTH   s[set i]_dst_width
		TOP     s[set i]_dst_top
		HEIGHT  s[set i]_dst_height
	}]
	append_associate_busif o_clk_busif S[set i]_DST

	pip_add_bus_if $core s[set i]_in_resetn [subst {
		abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
		bus_type_vlnv xilinx.com:signal:reset:1.0
		interface_mode master
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		RST s[set i]_in_resetn
	}] {
		POLARITY {ACTIVE_LOW}
	}
	append_associate_busif o_clk_reset s[set i]_in_resetn

	pip_add_bus_if $core s[set i]_fsa_disp_resetn [subst {
		abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
		bus_type_vlnv xilinx.com:signal:reset:1.0
		interface_mode master
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		RST s[set i]_fsa_disp_resetn
	}] {
		POLARITY {ACTIVE_LOW}
	}
	append_associate_busif o_clk_reset s[set i]_fsa_disp_resetn

	pip_add_bus_if $core s[set i]_out_resetn [subst {
		abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
		bus_type_vlnv xilinx.com:signal:reset:1.0
		interface_mode master
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		RST s[set i]_out_resetn
	}] {
		POLARITY {ACTIVE_LOW}
	}
	append_associate_busif o_clk_reset s[set i]_out_resetn

	pip_add_bus_if $core S[set i]_FSA_CTL [subst {
		abstraction_type_vlnv {$VENDOR:interface:fsa_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:fsa_ctl:1.0}
		interface_mode {master}
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		REF_DATA     s[set i]_ref_data
	}]
	append_associate_busif o_clk_busif S[set i]_FSA_CTL

	pip_add_bus_if $core S[set i]_FSA_RESULT [subst {
		abstraction_type_vlnv {$VENDOR:interface:fsa_result_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:fsa_result:1.0}
		interface_mode {slave}
		enablement_dependency {\$C_STREAM_NBR > $i}
	}] [subst {
		LEFT_VERTEX  s[set i]_lft_v
		RIGHT_VERTEX s[set i]_rt_v
	}]
	append_associate_busif o_clk_busif S[set i]_FSA_RESULT
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if $core BR[set i]_INIT_CTL [subst {
		abstraction_type_vlnv {$VENDOR:interface:blockram_init_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:blockram_init_ctl:1.0}
		interface_mode {master}
		enablement_dependency {\$C_BR_INITOR_NBR > $i}
	}] [subst {
		INIT  br[set i]_init
		WR_EN br[set i]_wr_en
		DATA  br[set i]_data
		SIZE  br[set i]_size
	}]
	append_associate_busif o_clk_busif BR[set i]_INIT_CTL
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if $core MOTOR[set i]_CFG [subst {
		abstraction_type_vlnv {$VENDOR:interface:step_motor_cfg_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:step_motor_cfg_ctl:1.0}
		interface_mode {master}
		enablement_dependency {\$C_MOTOR_NBR > $i}
	}] [subst {
		XEN       motor[set i]_xen
		XRST      motor[set i]_xrst
		STROKE    motor[set i]_stroke
		MICROSTEP motor[set i]_ms
	}]
	append_associate_busif o_clk_busif MOTOR[set i]_CFG

	pip_add_bus_if $core MOTOR[set i]_REQ [subst {
		abstraction_type_vlnv {$VENDOR:interface:step_motor_req_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:step_motor_req_ctl:1.0}
		interface_mode {master}
		enablement_dependency {\$C_MOTOR_NBR > $i}
	}] [subst {
		ZPSIGN    motor[set i]_zpsign
		TPSIGN    motor[set i]_tpsign
		STATE     motor[set i]_state
		RT_SPEED  motor[set i]_rt_speed
		START     motor[set i]_start
		STOP      motor[set i]_stop
		SPEED     motor[set i]_speed
		STEP      motor[set i]_step
		DIRECTION motor[set i]_dir
	}]
	append_associate_busif o_clk_busif MOTOR[set i]_REQ
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if $core PWM[set i]_CTL [subst {
		abstraction_type_vlnv $VENDOR:interface:pwm_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:pwm_ctl:1.0
		interface_mode master
		enablement_dependency {\$C_PWM_NBR > $i}
	}] [subst {
		DEF_VAL      pwm[set i]_def
		EN           pwm[set i]_en
		NUMERATOR    pwm[set i]_numerator
		DENOMINATOR  pwm[set i]_denominator
	}]
	append_associate_busif o_clk_busif PWM[set i]_CTL
}

# clock & reset
pip_add_bus_if $core resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST resetn
} {
	POLARITY {ACTIVE_LOW}
}
append_associate_busif clk_reset resetn

pip_add_bus_if $core clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} [subst {
	ASSOCIATED_BUSIF [get_associate_busif clk_busif]
	ASSOCIATED_RESET [get_associate_busif clk_reset]
}]

pip_add_bus_if $core o_resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST o_resetn
} {
	POLARITY {ACTIVE_LOW}
}
append_associate_busif o_clk_reset o_resetn

# stream resetn
pip_add_bus_if $core st_out_resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode master
} {
	RST st_out_resetn
} {
	POLARITY {ACTIVE_LOW}
}
append_associate_busif o_clk_reset st_out_resetn

pip_add_bus_if $core o_clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK o_clk
} [subst {
	ASSOCIATED_BUSIF [get_associate_busif o_clk_busif]
	ASSOCIATED_RESET [get_associate_busif o_clk_reset]
}]

# interrupt
pip_add_bus_if $core intr {
	abstraction_type_vlnv xilinx.com:signal:interrupt_rtl:1.0
	bus_type_vlnv xilinx.com:signal:interrupt:1.0
	interface_mode master
} {
	INTERRUPT intr
}

###################################################################### parameters

pip_add_usr_par $core C_CORE_VERSION {
	display_name {Version Of IMPLEMENTATION}
	tooltip {Version Of IMPLEMENTATION}
	widget {hexEdit}
} {
	value_bit_string_length 32
	value_resolve_type user
	value {0xFF00FF00}
	value_format bitString
	value_validation_type none
} {
	value_bit_string_length 32
	value {0xFF00FF00}
	value_format bitString
}

pip_add_usr_par $core {C_TS_WIDTH} {
	display_name {Timestamp Width}
	tooltip {Timestamp WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 64
	value_format long
	value_validation_type list
	value_validation_list {64}
} {
	value 64
	value_format long
}

pip_add_usr_par $core {C_DATA_WIDTH} {
	display_name {Register Width}
	tooltip {Register WIDTH}
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

pip_add_usr_par $core {C_REG_IDX_WIDTH} {
	display_name {Register Index Width}
	tooltip {REG INDEX WIDTH}
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

pip_add_usr_par $core {C_TEST} {
	display_name {Enable Test}
	tooltip {Enable Test}
	widget {checkBox}
} {
	value_resolve_type user
	value false
	value_format bool
} {
	value false
	value_format bool
}

gui_new $core {page "Default"} {
	{param C_CORE_VERSION}
	{param C_TS_WIDTH}
	{param C_DATA_WIDTH}
	{param C_REG_IDX_WIDTH}
	{param C_TEST}
}

pip_add_usr_par $core {C_IMG_PBITS} {
	display_name {Image PIXEL Bit Width}
	tooltip {IMAGE PIXEL BIT WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {8 10 12 24 32}
} {
	value 8
	value_format long
}

pip_add_usr_par $core {C_IMG_WBITS} {
	display_name {Image Width (PIXEL) Bit Width}
	tooltip {IMAGE WIDTH BIT WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {5 6 7 8 9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par $core {C_IMG_HBITS} {
	display_name {Image Height (PIXEL) Bit Width}
	tooltip {IMAGE HEIGHT BIT WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {5 6 7 8 9 10 11 12}
} {
	value 12
	value_format long
}
pip_add_usr_par $core {C_IMG_WDEF} {
	display_name {Default Image Width}
	tooltip {Default Image Width}
	widget {textEdit}
} {
	value_resolve_type user
	value 320
	value_format long
} {
	value 320
	value_format long
}

pip_add_usr_par $core {C_IMG_HDEF} {
	display_name {Default Image Height}
	tooltip {Default Image Height}
	widget {textEdit}
} {
	value_resolve_type user
	value 240
	value_format long
} {
	value 240
	value_format long
}

gui_new $core {page "Stream"} {
	{param C_IMG_PBITS}
	{param C_IMG_WBITS}
	{param C_IMG_HBITS}
	{param C_IMG_WDEF}
	{param C_IMG_HDEF}
}

pip_add_usr_par $core {C_BUF_ADDR_WIDTH} {
	display_name {Buffer Address Width}
	tooltip {Buffer Address Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 32
	value_format long
	value_validation_type list
	value_validation_list {32 64}
} {
	value 32
	value_format long
}

pip_add_usr_par $core {C_STREAM_NBR} {
	display_name {Stream Number}
	tooltip {Stream Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 2
	value_format long
	value_validation_type list
	value_validation_list {0 1 2 3 4 5 6 7 8}
} {
	value 2
	value_format long
}

pip_add_usr_par $core C_ST_ADDR {
	display_name {Stream Top Address}
	tooltip {Stream Top Address}
	widget {hexEdit}
} {
	value_bit_string_length 32
	value_resolve_type user
	value {0x3FF00000}
	value_format bitString
	value_validation_type none
} {
	value_bit_string_length 32
	value {0x3FF00000}
	value_format bitString
}

gui_new $core {page "StreamAddr"} {
	{param C_STREAM_NBR}
	{param C_BUF_ADDR_WIDTH}
	{param C_ST_ADDR}
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_usr_par $core C_S[set i]_ADDR [subst {
		display_name {stream $i address}
		tooltip {first buffer address of stream $i}
		widget {hexEdit}
		show_label {false}
	}] [subst {
		enablement_tcl_expr {\$C_STREAM_NBR > $i}
		value_bit_string_length 32
		value_resolve_type user
		value [format %#x [expr 0x3E000000 + 0x400000 * $i]]
		value_format bitString
		value_validation_type none
	}] [subst {
		value_bit_string_length 32
		value [format %#x [expr 0x3E000000 + 0x400000 * $i]]
		value_format bitString
	}]

	pip_add_usr_par $core C_S[set i]_SIZE [subst {
		display_name {stream $i size}
		tooltip {single buffer size of stream $i}
		widget {hexEdit}
		show_label {false}
	}] [subst {
		enablement_tcl_expr {\$C_STREAM_NBR > $i}
		value_bit_string_length 32
		value_resolve_type user
		value {0x00100000}
		value_format bitString
		value_validation_type none
	}] [subst {
		value_bit_string_length 32
		value {0x00100000}
		value_format bitString
	}]
}

gui_new_table $core "streamAddressTable" {page "StreamAddr"} 8 stream {
	"address" "address" C_S _ADDR
	"size"    "size"    C_S _SIZE
}

pip_add_usr_par $core {C_BR_INITOR_NBR} {
	display_name {Blockram Initor Number}
	tooltip {Blockram Initor Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 2
	value_format long
	value_validation_type list
	value_validation_list {0 1 2 3 4 5 6 7 8}
} {
	value 2
	value_format long
}

pip_add_usr_par $core {C_BR_ADDR_WIDTH} {
	display_name {Blockram Address Width}
	tooltip {Blockram Address Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 9
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
} {
	value 9
	value_format long
}

gui_new $core {page "blockram"} {
	{param C_BR_INITOR_NBR}
	{param C_BR_ADDR_WIDTH}
}

pip_add_usr_par $core {C_MOTOR_NBR} {
	display_name {Motor Number}
	tooltip {Motor Number, must smaller than clock division number}
	widget {comboBox}
} {
	value_resolve_type user
	value 4
	value_format long
	value_validation_type list
	value_validation_list {0 1 2 3 4 5 6 7 8}
} {
	value 4
	value_format long
}
pip_add_usr_par $core {C_ZPD_SEQ} {
	display_name {Zero Position Detection}
	tooltip {when specific bit is 1, then enable zero position detection for corresponding motor.}
	widget {hexEdit}
} {
	value_bit_string_length 8
	value_resolve_type user
	value {"00000000"}
	value_format bitString
	value_validation_type none
} {
	value_bit_string_length 8
	value {"00000000"}
	value_format bitString
}
pip_add_usr_par $core {C_STEP_NUMBER_WIDTH} {
	display_name {Step Number Width}
	tooltip {Step Number WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 16
	value_format long
	value_validation_type list
	value_validation_list {8 16 24 32}
} {
	value 16
	value_format long
}
pip_add_usr_par $core {C_SPEED_DATA_WIDTH} {
	display_name {Speed Data Width}
	tooltip {Speed Data WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 16
	value_format long
	value_validation_type list
	value_validation_list {8 16 24 32}
} {
	value 16
	value_format long
}

pip_add_usr_par $core {C_MICROSTEP_WIDTH} {
	display_name {Microstep Width}
	tooltip {microstep WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 3
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4}
} {
	value 3
	value_format long
}

gui_new $core {page "motor"} {
	{param C_MOTOR_NBR}
	{param C_ZPD_SEQ}
	{param C_STEP_NUMBER_WIDTH}
	{param C_SPEED_DATA_WIDTH}
	{param C_MICROSTEP_WIDTH}
}

pip_add_usr_par $core {C_PWM_NBR} {
	display_name {PWM Number}
	tooltip {PWM Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 4
	value_format long
	value_validation_type list
	value_validation_list {0 1 2 3 4 5 6 7 8}
} {
	value 4
	value_format long
}
pip_add_usr_par $core {C_PWM_CNT_WIDTH} {
	display_name {PWM Counter Width}
	tooltip {PWM Counter Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 16
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
} {
	value 16
	value_format long
}

gui_new $core {page "pwm"} {
	{param C_PWM_NBR}
	{param C_PWM_CNT_WIDTH}
}
