define_associate_busif clk

foreach i {bpm bam} {
	pip_add_bus_if $core [string toupper $i]_INIT [subst {
		abstraction_type_vlnv {$VENDOR:interface:blockram_init_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:blockram_init_ctl:1.0}
		interface_mode {slave}
	}] [subst {
		INIT  [set i]_init
		WR_EN [set i]_wr_en
		DATA  [set i]_data
		SIZE  [set i]_size
	}]
	append_associate_busif clk [string toupper $i]_INIT
}

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

foreach i {x y} {
	pip_add_bus_if $core FSA_RESULT_[string toupper $i] [subst {
		abstraction_type_vlnv $VENDOR:interface:fsa_result_rtl:1.0
		bus_type_vlnv $VENDOR:interface:fsa_result:1.0
		interface_mode slave
	}] [subst {
		DONE                     [set i]_ana_done
		LEFT_VALID               [set i]_lft_valid
		LEFT_VERTEX              [set i]_lft_edge
		LEFT_HEADER_OUTER_VALID  [set i]_lft_header_outer_valid
		LEFT_HEADER_OUTER_Y      [set i]_lft_header_outer_y
		LEFT_HEADER_INNER_VALID  [set i]_lft_header_inner_valid
		LEFT_HEADER_INNER_Y      [set i]_lft_header_inner_y
		RIGHT_VALID              [set i]_rt_valid
		RIGHT_VERTEX             [set i]_rt_edge
		RIGHT_HEADER_OUTER_VALID [set i]_rt_header_outer_valid
		RIGHT_HEADER_OUTER_Y     [set i]_rt_header_outer_y
		RIGHT_HEADER_INNER_VALID [set i]_rt_header_inner_valid
		RIGHT_HEADER_INNER_Y     [set i]_rt_header_inner_y
	}]
	append_associate_busif clk FSA_RESULT_[string toupper $i]
}

foreach i {l r x y} {
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
