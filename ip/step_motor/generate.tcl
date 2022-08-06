define_associate_busif clk_busif

pip_add_bus_if $core BR_INIT [subst {
	abstraction_type_vlnv $VENDOR:interface:blockram_init_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:blockram_init_ctl:1.0
	interface_mode {slave}
}] {
	INIT  br_init
	WR_EN br_wr_en
	DATA  br_data
	SIZE  br_size
}
append_associate_busif clk_busif BR_INIT

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if $core M[set i] [subst {
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
	append_associate_busif clk_busif M[set i]

	pip_add_bus_if $core S[set i]_CFG [subst {
		abstraction_type_vlnv $VENDOR:interface:step_motor_cfg_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:step_motor_cfg_ctl:1.0
		interface_mode slave
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MOTOR_NBR')) > $i}
	}] [subst {
		XEN             s[set i]_xen
		XRST            s[set i]_xrst
		MIN_POSITION    s[set i]_min_pos
		MAX_POSITION    s[set i]_max_pos
		MICROSTEP       s[set i]_ms
	}]
	append_associate_busif clk_busif S[set i]_CFG

	pip_add_bus_if $core S[set i]_REQ [subst {
		abstraction_type_vlnv $VENDOR:interface:step_motor_req_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:step_motor_req_ctl:1.0
		interface_mode slave
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MOTOR_NBR')) > $i}
	}] [subst {
		NTSIGN    s[set i]_ntsign
		ZPSIGN    s[set i]_zpsign
		PTSIGN    s[set i]_ptsign
		STATE     s[set i]_state
		RT_SPEED  s[set i]_rt_speed
		RT_DIR    s[set i]_rt_speed
		POSITION  s[set i]_position
		START     s[set i]_start
		STOP      s[set i]_stop
		SPEED     s[set i]_speed
		STEP      s[set i]_step
		ABSOLUTE  s[set i]_abs
	}]
	append_associate_busif clk_busif S[set i]_REQ

	pip_add_bus_if $core S[set i]_EXT_REQ [subst {
		abstraction_type_vlnv $VENDOR:interface:step_motor_req_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:step_motor_req_ctl:1.0
		interface_mode slave
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MOTOR_NBR')) > $i}
	}] [subst {
		NTSIGN     s[set i]_ext_ntsign
		ZPSIGN     s[set i]_ext_zpsign
		PTSIGN     s[set i]_ext_ptsign
		STATE      s[set i]_ext_state
		RT_SPEED   s[set i]_ext_rt_speed
		RT_DIR     s[set i]_ext_rt_dir
		POSITION   s[set i]_ext_position
		START      s[set i]_ext_start
		STOP       s[set i]_ext_stop
		SPEED      s[set i]_ext_speed
		STEP       s[set i]_ext_step
		ABSOLUTE   s[set i]_ext_abs
		MOD_REMAIN s[set i]_ext_mod_remain
		NEW_REMAIN s[set i]_ext_new_remain
	}]
	append_associate_busif clk_busif S[set i]_EXT_REQ

	pip_add_bus_if $core s[set i]_ext_sel [subst {
		abstraction_type_vlnv xilinx.com:signal:data_rtl:1.0
		bus_type_vlnv xilinx.com:signal:data:1.0
		interface_mode slave
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MOTOR_NBR')) > $i}
	}] [subst {
		DATA s[set i]_ext_sel
	}]
	append_associate_busif clk_busif s[set i]_ext_sel
}

pip_add_bus_if $core resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST resetn
} {
	POLARITY {ACTIVE_LOW}
}

pip_add_bus_if $core clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} [subst {
	ASSOCIATED_BUSIF [get_associate_busif clk_busif]
	ASSOCIATED_RESET {resetn}
}]

pip_add_usr_par $core {C_CLK_DIV_NBR} {
	display_name {Clock Division Number}
	tooltip {Clock Division Number, must bigger than 9 for block ram reading delay, I don't know if it can be 8 when enable OPT_BR_TIME.}
	widget {comboBox}
} {
	value_resolve_type user
	value 32
	value_format long
	value_validation_type list
	value_validation_list {16 32}
} {
	value 32
	value_format long
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
	value_validation_list {1 2 3 4 5 6 7 8}
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

pip_add_usr_par $core {C_MICROSTEP_PASSTHOUGH_SEQ} {
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
pip_add_usr_par $core {C_SPEED_ADDRESS_WIDTH} {
	display_name {Speed Address Width}
	tooltip {Speed Address WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 10
	value_format long
	value_validation_type list
	value_validation_list {5 6 7 8 9 10 11 12}
} {
	value 10
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

pip_add_usr_par $core {C_OPT_BR_TIME} {
	display_name {Optimize for blockram timing}
	tooltip {Optimize for timing of reading blockram， which will use more resource.}
	widget {checkBox}
} {
	value_resolve_type user
	value false
	value_format bool
} {
	value false
	value_format bool
}
