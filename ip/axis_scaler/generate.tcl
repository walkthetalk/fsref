pip_add_bus_if $core S_AXIS {
	abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:axis:1.0}
	interface_mode {slave}
} {
	TVALID	s_axis_tvalid
	TDATA	s_axis_tdata
	TUSER	s_axis_tuser
	TLAST	s_axis_tlast
	TREADY	s_axis_tready
}

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

pip_add_bus_if $core SCALE_CTL [subst {
	abstraction_type_vlnv {$VENDOR:interface:scale_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:scale_ctl:1.0}
	interface_mode {slave}
}] {
	SRC_WIDTH   s_width
	SRC_HEIGHT  s_height
	DST_WIDTH   m_width
	DST_HEIGHT  m_height
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
} {
	ASSOCIATED_BUSIF {S_AXIS:M_AXIS:SCALE_CTL}
	ASSOCIATED_RESET {resetn}
}

# parameters
pip_add_usr_par $core {C_CH0_WIDTH} {
	display_name {Pixel Channel 0 Width}
	tooltip {PIXEL Channel 0 WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {5 6 8 10 12}
} {
	value 8
	value_format long
}
pip_add_usr_par $core {C_CH1_WIDTH} {
	display_name {Pixel Channel 1 Width}
	tooltip {PIXEL Channel 1 WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 0
	value_format long
	value_validation_type list
	value_validation_list {0 5 6 8 10 12}
} {
	value 0
	value_format long
}
pip_add_usr_par $core {C_CH2_WIDTH} {
	display_name {Pixel Channel 2 Width}
	tooltip {PIXEL Channel 2 WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 0
	value_format long
	value_validation_type list
	value_validation_list {0 5 6 8 10 12}
} {
	value 0
	value_format long
}

pip_add_usr_par $core {C_PIXEL_WIDTH} {
	display_name {Pixel Width}
	tooltip {PIXEL WIDTH}
	widget {textEdit}
} {
	value_resolve_type user
	enablement_value false
	value_tcl_expr {expr ($C_CH0_WIDTH + $C_CH1_WIDTH + $C_CH2_WIDTH)}
	value 8
	value_format long
} {
	value 8
	value_format long
}

pip_add_usr_par $core {C_SH_WIDTH} {
	display_name {SAXIS Height Width}
	tooltip {SAXIS Height Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par $core {C_SW_WIDTH} {
	display_name {SAXIS Width Width}
	tooltip {SAXIS Width Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par $core {C_MH_WIDTH} {
	display_name {MAXIS Height Width}
	tooltip {MAXIS Height Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par $core {C_MW_WIDTH} {
	display_name {MAXIS Width Width}
	tooltip {MAXIS Width Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par $core {C_OUT_RELAY} {
	display_name {Enable out relay}
	tooltip {Enable out relay}
	widget {checkBox}
} {
	value_resolve_type user
	value true
	value_format bool
} {
	value true
	value_format bool
}
