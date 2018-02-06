set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -name fsctl -taxonomy $TAXONOMY -root_dir $ip_dir $ip_dir/src
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

define_associate_busif clk_busif
define_associate_busif clk_reset
define_associate_busif o_clk_busif
define_associate_busif o_clk_reset

pip_set_prop [ipx::current_core] [subst {
	display_name {Fusion Splicer Controller}
	description {Fusion Splicer Controller}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}]

pip_clr_def_if_par_memmap [ipx::current_core]

pip_add_bus_if [ipx::current_core] S_REG_CTL [subst {
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

pip_add_bus_if [ipx::current_core] fsync {
	abstraction_type_vlnv xilinx.com:signal:video_frame_sync_rtl:1.0
	bus_type_vlnv xilinx.com:signal:video_frame_sync:1.0
	interface_mode slave
} {
	FRAME_SYNC fsync
}

pip_add_bus_if [ipx::current_core] o_fsync {
	abstraction_type_vlnv xilinx.com:signal:video_frame_sync_rtl:1.0
	bus_type_vlnv xilinx.com:signal:video_frame_sync:1.0
	interface_mode master
} {
	FRAME_SYNC o_fsync
}
append_associate_busif o_clk_busif o_fsync

pip_add_bus_if [ipx::current_core] OUT_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {master}
}] {
	WIDTH  out_width
	HEIGHT out_height
}
append_associate_busif o_clk_busif OUT_SIZE

pip_add_bus_if [ipx::current_core] ST_ADDR [subst {
	abstraction_type_vlnv $VENDOR:interface:addr_array_rtl:1.0
	bus_type_vlnv $VENDOR:interface:addr_array:1.0
	interface_mode master
}] {
	ADDR0 st_addr
}
append_associate_busif o_clk_busif ST_ADDR

pip_add_bus_if [ipx::current_core] ST_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {master}
}] {
	WIDTH  st_width
	HEIGHT st_height
}
append_associate_busif o_clk_busif ST_SIZE

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if [ipx::current_core] S[set i]_READ [subst {
		abstraction_type_vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:mutex_buffer_ctl:1.0
		interface_mode master
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
	}] [subst {
		SOF s[set i]_rd_en
		IDX s[set i]_rd_buf_idx
	}]
	append_associate_busif o_clk_busif S[set i]_READ

	pip_add_bus_if [ipx::current_core] s[set i]_wr_done [subst {
		abstraction_type_vlnv xilinx.com:signal:data_rtl:1.0
		bus_type_vlnv xilinx.com:signal:data:1.0
		interface_mode slave
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
	}] [subst {
		DATA s[set i]_wr_done
	}]
	append_associate_busif o_clk_busif s[set i]_wr_done

	pip_add_bus_if [ipx::current_core] s[set i]_dst_bmp [subst {
		abstraction_type_vlnv xilinx.com:signal:data_rtl:1.0
		bus_type_vlnv xilinx.com:signal:data:1.0
		interface_mode master
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
	}] [subst {
		DATA s[set i]_dst_bmp
	}]
	append_associate_busif o_clk_busif s[set i]_dst_bmp

	pip_add_bus_if [ipx::current_core] S[set i]_ADDR [subst {
		abstraction_type_vlnv $VENDOR:interface:addr_array_rtl:1.0
		bus_type_vlnv $VENDOR:interface:addr_array:1.0
		interface_mode master
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
	}] [subst {
		ADDR0 s[set i]_buf0_addr
		ADDR1 s[set i]_buf1_addr
		ADDR2 s[set i]_buf2_addr
		ADDR3 s[set i]_buf3_addr
	}]
	append_associate_busif o_clk_busif S[set i]_ADDR

	pip_add_bus_if [ipx::current_core] S[set i]_SIZE [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
	}] [subst {
		WIDTH  s[set i]_width
		HEIGHT s[set i]_height
	}]
	append_associate_busif o_clk_busif S[set i]_SIZE

	pip_add_bus_if [ipx::current_core] S[set i]_WIN [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
	}] [subst {
		LEFT    s[set i]_win_left
		WIDTH   s[set i]_win_width
		TOP     s[set i]_win_top
		HEIGHT  s[set i]_win_height
	}]
	append_associate_busif o_clk_busif S[set i]_WIN

	pip_add_bus_if [ipx::current_core] S[set i]_SCALE [subst {
		abstraction_type_vlnv {$VENDOR:interface:scale_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:scale_ctl:1.0}
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
	}] [subst {
		SRC_WIDTH  s[set i]_scale_src_width
		SRC_HEIGHT s[set i]_scale_src_height
		DST_WIDTH  s[set i]_scale_dst_width
		DST_HEIGHT s[set i]_scale_dst_height
	}]
	append_associate_busif o_clk_busif S[set i]_SCALE

	pip_add_bus_if [ipx::current_core] S[set i]_DST [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
	}] [subst {
		LEFT    s[set i]_dst_left
		WIDTH   s[set i]_dst_width
		TOP     s[set i]_dst_top
		HEIGHT  s[set i]_dst_height
	}]
	append_associate_busif o_clk_busif S[set i]_DST

	pip_add_bus_if [ipx::current_core] s[set i]_soft_resetn [subst {
		abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
		bus_type_vlnv xilinx.com:signal:reset:1.0
		interface_mode master
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
	}] [subst {
		RST s[set i]_soft_resetn
	}] {
		POLARITY {ACTIVE_LOW}
	}
	append_associate_busif o_clk_reset s[set i]_soft_resetn
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if [ipx::current_core] BR[set i]_INIT_CTL [subst {
		abstraction_type_vlnv {$VENDOR:interface:blockram_init_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:blockram_init_ctl:1.0}
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_BR_INITOR_NBR')) > $i}
	}] [subst {
		INIT  br[set i]_init
		WR_EN br[set i]_wr_en
		DATA  br[set i]_data
	}]
	append_associate_busif o_clk_busif BR[set i]_INIT_CTL
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if [ipx::current_core] MOTOR[set i]_CTL [subst {
		abstraction_type_vlnv {$VENDOR:interface:step_motor_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:step_motor_ctl:1.0}
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MOTOR_NBR')) > $i}
	}] [subst {
		XEN       motor[set i]_xen
		XRST      motor[set i]_xrst
		ZPSIGN    motor[set i]_zpsign
		TPSIGN    motor[set i]_tpsign
		STATE     motor[set i]_state
		STROKE    motor[set i]_stroke
		START     motor[set i]_start
		STOP      motor[set i]_stop
		MICROSTEP motor[set i]_ms
		SPEED     motor[set i]_speed
		STEP      motor[set i]_step
		DIRECTION motor[set i]_dir
	}]
	append_associate_busif o_clk_busif MOTOR[set i]_CTL
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if [ipx::current_core] PWM[set i]_CTL [subst {
		abstraction_type_vlnv $VENDOR:interface:pwm_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:pwm_ctl:1.0
		interface_mode master
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_PWM_NBR')) > $i}
	}] [subst {
		DEF_VAL      pwm[set i]_def
		EN           pwm[set i]_en
		NUMERATOR    pwm[set i]_numerator
		DENOMINATOR  pwm[set i]_denominator
	}]
	append_associate_busif o_clk_busif PWM[set i]_CTL
}

# clock & reset
pip_add_bus_if [ipx::current_core] resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST resetn
} {
	POLARITY {ACTIVE_LOW}
}
append_associate_busif clk_reset resetn

pip_add_bus_if [ipx::current_core] clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} [subst {
	ASSOCIATED_BUSIF [get_associate_busif clk_busif]
	ASSOCIATED_RESET [get_associate_busif clk_reset]
}]

pip_add_bus_if [ipx::current_core] o_resetn {
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
pip_add_bus_if [ipx::current_core] st_soft_resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode master
} {
	RST st_soft_resetn
} {
	POLARITY {ACTIVE_LOW}
}
append_associate_busif o_clk_reset st_soft_resetn

pip_add_bus_if [ipx::current_core] o_clk {
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
pip_add_bus_if [ipx::current_core] intr {
	abstraction_type_vlnv xilinx.com:signal:interrupt_rtl:1.0
	bus_type_vlnv xilinx.com:signal:interrupt:1.0
	interface_mode master
} {
	INTERRUPT intr
}

# parameters
pip_add_usr_par [ipx::current_core] C_CORE_VERSION {
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

pip_add_usr_par [ipx::current_core] {C_DATA_WIDTH} {
	display_name {Data Width}
	tooltip { DATA WIDTH}
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

pip_add_usr_par [ipx::current_core] {C_REG_IDX_WIDTH} {
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
pip_add_usr_par [ipx::current_core] {C_IMG_WBITS} {
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

pip_add_usr_par [ipx::current_core] {C_IMG_HBITS} {
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
pip_add_usr_par [ipx::current_core] {C_IMG_WDEF} {
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

pip_add_usr_par [ipx::current_core] {C_IMG_HDEF} {
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

pip_add_usr_par [ipx::current_core] {C_BUF_ADDR_WIDTH} {
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

pip_add_usr_par [ipx::current_core] {C_STREAM_NBR} {
	display_name {Stream Number}
	tooltip {Stream Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 2
	value_format long
	value_validation_type list
	value_validation_list {0 1 2 3 4 5 6 7}
} {
	value 2
	value_format long
}

pip_add_usr_par [ipx::current_core] C_ST_ADDR {
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

for {set i 0} {$i < 8} {incr i} {
	pip_add_usr_par [ipx::current_core] C_S[set i]_ADDR [subst {
		display_name {stream $i address}
		tooltip {first buffer address of stream $i}
		widget {hexEdit}
	}] [subst {
		enablement_tcl_expr {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
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

	pip_add_usr_par [ipx::current_core] C_S[set i]_SIZE [subst {
		display_name {stream $i size}
		tooltip {single buffer size of stream $i}
		widget {hexEdit}
	}] [subst {
		enablement_tcl_expr {spirit:decode(id('MODELPARAM_VALUE.C_STREAM_NBR')) > $i}
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

pip_add_usr_par [ipx::current_core] {C_BR_INITOR_NBR} {
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
pip_add_usr_par [ipx::current_core] {C_MOTOR_NBR} {
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
pip_add_usr_par [ipx::current_core] {C_PWM_NBR} {
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
pip_add_usr_par [ipx::current_core] {C_PWM_CNT_WIDTH} {
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
pip_add_usr_par [ipx::current_core] {C_ZPD_SEQ} {
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
pip_add_usr_par [ipx::current_core] {C_STEP_NUMBER_WIDTH} {
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
pip_add_usr_par [ipx::current_core] {C_SPEED_DATA_WIDTH} {
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

pip_add_usr_par [ipx::current_core] {C_MICROSTEP_WIDTH} {
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

pip_add_usr_par [ipx::current_core] {C_TEST} {
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

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
