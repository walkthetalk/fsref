# interface
pip_add_bus_if $core ts {
	abstraction_type_vlnv {xilinx.com:signal:data_rtl:1.0}
	bus_type_vlnv {xilinx.com:signal:data:1.0}
	interface_mode {master}
} {
	DATA ts
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
	ASSOCIATED_RESET {resetn}
}

# parameters
pip_add_usr_par $core {C_TS_WIDTH} {
	display_name {Timestamp Width}
	tooltip {TIMESTAMP WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 64
	value_format long
	value_validation_type list
	value_validation_list {32 64}
} {
	value 64
	value_format long
}
