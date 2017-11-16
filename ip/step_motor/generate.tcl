set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -taxonomy $TAXONOMY $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_set_prop [ipx::current_core] [subst {
	display_name {Step Motor Controller}
	description {Step Motor controller}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}]

pip_clr_def_if_par_memmap [ipx::current_core]

pip_add_bus_if [ipx::current_core] BR_INIT [subst {
	abstraction_type_vlnv $VENDOR:interface:blockram_init_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:blockram_init_ctl:1.0
	interface_mode {slave}
}] {
	INIT  br_init
	WR_EN br_wr_en
	DATA  br_data
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if [ipx::current_core] M[set i] [subst {
		abstraction_type_vlnv $VENDOR:interface:motor_ic_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:motor_ic_ctl:1.0
		interface_mode master
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MOTOR_NBR')) > $i}
	}] [subst {
		ZPD       m[set i]_zpd
		DRIVE     m[set i]_drive
		DIRECTION m[set i]_dir
		MICROSTEP m[set i]_ms
		XEN       m[set i]_xen
		XRST      m[set i]_xrst
	}]

	pip_add_bus_if [ipx::current_core] S[set i] [subst {
		abstraction_type_vlnv $VENDOR:interface:step_motor_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:step_motor_ctl:1.0
		interface_mode slave
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MOTOR_NBR')) > $i}
	}] [subst {
		XEN       s[set i]_xen
		XRST      s[set i]_xrst
		ZPSIGN    s[set i]_zpsign
		TPSIGN    s[set i]_tpsign
		STATE     s[set i]_state
		STROKE    s[set i]_stroke
		START     s[set i]_start
		STOP      s[set i]_stop
		MICROSTEP s[set i]_ms
		SPEED     s[set i]_speed
		STEP      s[set i]_step
		DIRECTION s[set i]_dir
	}]
}

pip_add_bus_if [ipx::current_core] resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST resetn
} {
	POLARITY {ACTIVE_LOW}
}

pip_add_bus_if [ipx::current_core] clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} {
	ASSOCIATED_BUSIF {BR_INIT:
		M0_MOTOR_IC_CTL:M1_MOTOR_IC_CTL:M2_MOTOR_IC_CTL:M3_MOTOR_IC_CTL:
		M4_MOTOR_IC_CTL:M5_MOTOR_IC_CTL:M6_MOTOR_IC_CTL:M7_MOTOR_IC_CTL:
		S0_STEP_MOTOR_CTL:S1_STEP_MOTOR_CTL:S2_STEP_MOTOR_CTL:S3_STEP_MOTOR_CTL:
		S4_STEP_MOTOR_CTL:S5_STEP_MOTOR_CTL:S6_STEP_MOTOR_CTL:S7_STEP_MOTOR_CTL}
	ASSOCIATED_RESET {resetn}
}

pip_add_usr_par [ipx::current_core] {C_CLK_DIV_NBR} {
	display_name {Clock Division Number}
	tooltip {Clock Division Number, must bigger than 4 for block ram reading delay}
	widget {comboBox}
} {
	value_resolve_type user
	value 32
	value_format long
	value_validation_type list
	value_validation_list {4 8 16 32}
} {
	value 32
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
	value_validation_list {1 2 3 4 5 6 7 8}
} {
	value 4
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

pip_add_usr_par [ipx::current_core] {C_MICROSTEP_PASSTHOUGH_SEQ} {
	display_name {MicroStep Passthrough}
	tooltip {MicroStep Passthrough}
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
pip_add_usr_par [ipx::current_core] {C_SPEED_ADDRESS_WIDTH} {
	display_name {Speed Address Width}
	tooltip {Speed Address WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 10
	value_format long
	value_validation_type list
	value_validation_list {5 6 7 8 9 10}
} {
	value 10
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

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
