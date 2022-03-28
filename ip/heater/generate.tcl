define_associate_busif clk_busif

pip_add_bus_if $core CTL [subst {
	abstraction_type_vlnv $VENDOR:interface:heater_cfg_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:heater_cfg_ctl:1.0
	interface_mode {slave}
}] {
	AUTO_START  auto_start
	AUTO_HOLD   auto_hold
	HOLD_V      holdv
	HEAT_V      keep_value
	HEAT_TIME   keep_time
	FINISH_V    finishv
	START       start
	STOP        stop
	STATE       run_state
	VALUE       run_value
}
append_associate_busif clk_busif CTL

pip_add_bus_if $core S_AXIS {
	abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:axis:1.0}
	interface_mode {slave}
} {
	TVALID	s_axis_tvalid
	TDATA	s_axis_tdata
	TID     s_axis_tid
	TREADY	s_axis_tready
}
append_associate_busif clk_busif S_AXIS

###################################### resetn / clk ###############################
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

##################################### parameter ########################################
pip_add_usr_par $core {C_HEAT_VALUE_WIDTH} {
	display_name {Heater Value Width}
	tooltip {Heater value Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {10 12 14 16}
} {
	value 12
	value_format long
}
pip_add_usr_par $core {C_HEAT_TIME_WIDTH} {
	display_name {Heater Time Width}
	tooltip {Heater Time Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 32
	value_format long
	value_validation_type list
	value_validation_list {16 32 64}
} {
	value 32
	value_format long
}
