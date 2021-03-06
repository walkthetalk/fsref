pip_add_bus_if $core M_AXIS {
	abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:axis:1.0}
	interface_mode {master}
} {
	TVALID	m_axis_tvalid
	TDATA	m_axis_tdata
	TUSER	m_axis_tuser
	TLAST	m_axis_tlast
	TREADY	m_axis_tready
}

pip_add_bus_if $core S0_AXIS {
	abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:axis:1.0}
	interface_mode {slave}
} {
	TVALID	s0_axis_tvalid
	TDATA	s0_axis_tdata
	TUSER	s0_axis_tuser
	TLAST	s0_axis_tlast
	TREADY	s0_axis_tready
}

pip_add_bus_if $core S1_AXIS {
	abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:axis:1.0}
	interface_mode {slave}
} {
	TVALID	s1_axis_tvalid
	TDATA	s1_axis_tdata
	TUSER	s1_axis_tuser
	TLAST	s1_axis_tlast
	TREADY	s1_axis_tready
}

pip_add_bus_if $core s1_enable {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
	enablement_dependency {$C_S1_ENABLE}
} {
	RST s1_enable
} {
	POLARITY {ACTIVE_LOW}
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

pip_add_bus_if $core clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} {
	ASSOCIATED_BUSIF {S0_AXIS:S1_AXIS:M_AXIS}
	ASSOCIATED_RESET {resetn}
}

# parameters

pip_add_usr_par $core {C_CHN_WIDTH} {
	display_name {Channel Width}
	tooltip {Channel WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {4 6 8 10}
} {
	value 8
	value_format long
}

pip_add_usr_par $core {C_S0_CHN_NUM} {
	display_name {S0 Channel Number}
	tooltip {S0 Channel Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 1
	value_format long
	value_validation_type list
	value_validation_list {1 2 3}
} {
	value 1
	value_format long
}

pip_add_usr_par $core {C_S1_CHN_NUM} {
	display_name {S1 Channel Number}
	tooltip {S1 Channel Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 1
	value_format long
	value_validation_type list
	value_validation_list {1 2 3}
} {
	value 1
	value_format long
}

pip_add_usr_par $core {C_ALPHA_WIDTH} {
	display_name {S1 Alpha Channel Width}
	tooltip {S1 Alpha Channel Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {0 1 2 3 4 5 6 7 8}
} {
	value 8
	value_format long
}

pip_add_usr_par $core C_FIXED_ALPHA {
	display_name {Fixed Alpha}
	tooltip {if 0, then use input alpha, or use the fixed alpha value.}
	widget {hexEdit}
} {
	value_bit_string_length 32
	value_resolve_type user
	value {0}
	value_format bitString
	value_validation_type none
	enablement_tcl_expr {$C_ALPHA_WIDTH > 0}
} {
	value_bit_string_length 32
	value {0}
	value_format bitString
}

pip_add_usr_par $core {C_M_WIDTH} {
	display_name {M_AXIS DATA Width}
	tooltip {M_AXIS DATA Width}
	widget {textEdit}
} {
	enablement_value false
	value_resolve_type user
	value 8
	value_format long
	value_tcl_expr {expr max($C_S0_CHN_NUM,$C_S1_CHN_NUM) * $C_CHN_WIDTH}
} {
	value 8
	value_format long
}

pip_add_usr_par $core {C_S1_ENABLE} {
	display_name {Seperate Enable Signal for S1}
	tooltip {Seperate Enable Signal for S1}
	widget {checkBox}
} {
	value_resolve_type user
	value false
	value_format bool
} {
	value false
	value_format bool
}

pip_add_usr_par $core {C_IN_NEED_WIDTH} {
	display_name {Input Need Width}
	tooltip {merged with s0_axis_tuser}
	widget {comboBox}
} {
	value_resolve_type user
	value 0
	value_format long
	value_validation_type list
	value_validation_list {0 1 2 3 4 5 6 7 8}
} {
	value 0
	value_format long
}

pip_add_usr_par $core {C_OUT_NEED_WIDTH} {
	display_name {Output Need Width}
	tooltip {merged with m_axis_tuser}
	widget {textEdit}
} {
	enablement_value false
	value_resolve_type user
	value 0
	value_format long
	value_tcl_expr {expr max(($C_IN_NEED_WIDTH - 1), 0)}
} {
	value 0
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
