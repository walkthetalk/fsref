pip_add_bus_if $core MBUF_R0 [subst {
	abstraction_type_vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:mutex_buffer_ctl:1.0
	interface_mode slave
}] {
	SOF  r0_sof
	ADDR r0_addr
	IDX  r0_idx
	TS   r0_ts
}

pip_add_bus_if $core MBUF_R1 [subst {
	abstraction_type_vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:mutex_buffer_ctl:1.0
	interface_mode slave
}] {
	SOF  r1_sof
	ADDR r1_addr
	IDX  r1_idx
	TS   r1_ts
}

pip_add_bus_if $core MBUF_W [subst {
	abstraction_type_vlnv $VENDOR:interface:mutex_buffer_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:mutex_buffer_ctl:1.0
	interface_mode slave
}] {
	SOF w_sof
	ADDR w_addr
	IDX w_idx
}

pip_add_bus_if $core BUF_ADDR [subst {
	abstraction_type_vlnv $VENDOR:interface:addr_array_rtl:1.0
	bus_type_vlnv $VENDOR:interface:addr_array:1.0
	interface_mode slave
}] {
	ADDR0 buf0_addr
	ADDR1 buf1_addr
	ADDR2 buf2_addr
	ADDR3 buf3_addr
}

pip_add_bus_if $core sys_ts {
	abstraction_type_vlnv {xilinx.com:signal:data_rtl:1.0}
	bus_type_vlnv {xilinx.com:signal:data:1.0}
	interface_mode {slave}
} {
	DATA sys_ts
}

#pip_add_bus_if $core intr {
#	abstraction_type_vlnv xilinx.com:signal:interrupt_rtl:1.0
#	bus_type_vlnv xilinx.com:signal:interrupt:1.0
#	interface_mode master
#} {
#	INTERRUPT intr
#}

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
	ASSOCIATED_BUSIF {MBUF_W:MBUF_R0:MBUF_R1}
	ASSOCIATED_RESET {resetn}
}

pip_add_usr_par $core {C_ADDR_WIDTH} {
	display_name {Address Width}
	tooltip {ADDRESS WIDTH}
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
