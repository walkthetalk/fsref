define_associate_busif clk

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
append_associate_busif clk M_AXIS

pip_add_bus_if $core OUT_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	WIDTH   width
	HEIGHT  height
}
append_associate_busif clk OUT_SIZE

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if $core S[set i]_WIN [subst {
		abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
		bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
		interface_mode {slave}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_WIN_NUM')) > $i}
	}] [subst {
		LEFT    s[set i]_left
		TOP     s[set i]_top
		WIDTH   s[set i]_width
		HEIGHT  s[set i]_height
	}]
	append_associate_busif clk S[set i]_WIN

	pip_add_bus_if $core s[set i]_dst_bmp [subst {
		abstraction_type_vlnv {xilinx.com:signal:data_rtl:1.0}
		bus_type_vlnv {xilinx.com:signal:data:1.0}
		interface_mode {slave}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_WIN_NUM')) > $i}
	}] [subst {
		DATA s[set i]_dst_bmp
	}]
	append_associate_busif clk s[set i]_dst_bmp

	pip_add_bus_if $core s[set i]_dst_bmp_o [subst {
		abstraction_type_vlnv {xilinx.com:signal:data_rtl:1.0}
		bus_type_vlnv {xilinx.com:signal:data:1.0}
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_WIN_NUM')) > $i}
	}] [subst {
		DATA s[set i]_dst_bmp_o
	}]
	append_associate_busif clk s[set i]_dst_bmp_o
}

pip_add_bus_if $core fsync {
	abstraction_type_vlnv xilinx.com:signal:video_frame_sync_rtl:1.0
	bus_type_vlnv xilinx.com:signal:video_frame_sync:1.0
	interface_mode slave
	enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_EXT_FSYNC')) == 1}
} {
	FRAME_SYNC fsync
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
} [subst {
	ASSOCIATED_BUSIF [get_associate_busif clk]
	ASSOCIATED_RESET {resetn}
}]

# parameters

pip_add_usr_par $core {C_WIN_NUM} {
	display_name {Window Number}
	tooltip {Window Number}
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

pip_add_usr_par $core {C_EXT_FSYNC} {
	display_name {External Fsync}
	tooltip {External Fsync}
	widget {checkBox}
} {
	value_resolve_type user
	value false
	value_format bool
} {
	value false
	value_format bool
}

pip_add_usr_par $core {C_IMG_WBITS} {
	display_name {Image Width Bits}
	tooltip {Image Width Bits}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {8 9 10 11 12}
} {
	value 12
	value_format long
}
pip_add_usr_par $core {C_IMG_HBITS} {
display_name {Image Height Bits}
tooltip {Image Height Bits}
widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {8 9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par $core {C_PIXEL_WIDTH} {
	display_name {Pixel Width}
	tooltip {PIXEL WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {8 10 12 16 24 32}
} {
	value 8
	value_format long
}

pip_add_usr_par $core {C_VAR_DATA} {
	display_name {Variable Data}
	tooltip {Variable Data}
	widget {checkBox}
} {
	value_resolve_type user
	value false
	value_format bool
} {
	value false
	value_format bool
}
