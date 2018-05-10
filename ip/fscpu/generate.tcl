define_associate_busif clk

pip_add_bus_if $core BPM_INIT [subst {
	abstraction_type_vlnv {$VENDOR:interface:blockram_init_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:blockram_init_ctl:1.0}
	interface_mode {slave}
}] [subst {
	INIT  bpm_init
	WR_EN bpm_wr_en
	DATA  bpm_data
	SIZE  bpm_size
}]
append_associate_busif clk BPM_INIT

pip_add_bus_if $core REQ_CTL [subst {
	abstraction_type_vlnv {$VENDOR:interface:req_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:req_ctl:1.0}
	interface_mode {slave}
}] [subst {
	EN    req_en
	CMD   req_cmd
	PARAM req_param
	DONE  req_done
	ERR   req_err
}]
append_associate_busif clk REQ_CTL

pip_add_bus_if $core FSA_RESULT [subst {
	abstraction_type_vlnv $VENDOR:interface:fsa_result_rtl:1.0
	bus_type_vlnv $VENDOR:interface:fsa_result:1.0
	interface_mode slave
}] {
	DONE         ana_done
	LEFT_VALID   lft_valid
	LEFT_VERTEX  lft_edge
	RIGHT_VALID  rt_valid
	RIGHT_VERTEX rt_edge
}
append_associate_busif clk FSA_RESULT


foreach i {l r} {
	pip_add_bus_if $core M[set i]_REQ [subst {
		abstraction_type_vlnv $VENDOR:interface:step_motor_req_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:step_motor_req_ctl:1.0
		interface_mode master
	}] [subst {
		ZPSIGN     m[set i]_zpsign
		TPSIGN     m[set i]_tpsign
		STATE      m[set i]_state
		RT_SPEED   m[set i]_rt_speed
		POSITION   m[set i]_position
		START      m[set i]_start
		STOP       m[set i]_stop
		SPEED      m[set i]_speed
		STEP       m[set i]_step
		DIRECTION  m[set i]_dir
		MOD_REMAIN m[set i]_mod_remain
		NEW_REMAIN m[set i]_new_remain
	}]
	append_associate_busif clk M[set i]_REQ
}
######################################################################## clock & reset

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
	ASSOCIATED_BUSIF [get_associate_busif clk]
	ASSOCIATED_RESET {resetn}
}]

#################################################################### parameters
pip_add_usr_par $core {C_IMG_WW} {
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

pip_add_usr_par $core {C_IMG_HW} {
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
