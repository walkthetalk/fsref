define_associate_busif clk

pip_add_bus_if $core IMG_SIZE [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	WIDTH  width
	HEIGHT height
}
append_associate_busif clk IMG_SIZE

pip_add_bus_if $core S_WIN_CTL [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	LEFT    win_left
	TOP     win_top
	WIDTH   win_width
	HEIGHT  win_height
}
append_associate_busif clk S_WIN_CTL

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
append_associate_busif clk S_AXIS

pip_add_bus_if $core MBR_RD [subst {
	abstraction_type_vlnv $VENDOR:interface:mbr_rd_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:mbr_rd_ctl:1.0
	interface_mode slave
}] {
	SOF       r_sof
	EN        r_en
	ADDR      r_addr
	DATA      r_data
}

append_associate_busif clk MBR_RD

pip_add_bus_if $core FSA_CTL [subst {
	abstraction_type_vlnv $VENDOR:interface:fsa_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:fsa_ctl:1.0
	interface_mode slave
}] {
	REF_DATA    ref_data
}

for {set i 0} {$i < 3} {incr i} {
	pip_add_bus_if $core RESULT[set i] [subst {
		abstraction_type_vlnv $VENDOR:interface:fsa_result_rtl:1.0
		bus_type_vlnv $VENDOR:interface:fsa_result:1.0
		interface_mode master
	}] {
		DONE                     ana_done
		LEFT_VALID               lft_valid
		LEFT_VERTEX              lft_edge
		LEFT_HEADER_OUTER_VALID  lft_header_outer_valid
		LEFT_HEADER_OUTER_X      lft_header_outer_x
		LEFT_HEADER_OUTER_Y      lft_header_outer_y
		LEFT_HEADER_INNER_VALID  lft_header_inner_valid
		LEFT_HEADER_INNER_X      lft_header_inner_x
		LEFT_HEADER_INNER_Y      lft_header_inner_y
		LEFT_CORNER_VALID        lft_corner_valid
		LEFT_CORNER_TOP_X        lft_corner_top_x
		LEFT_CORNER_TOP_Y        lft_corner_top_y
		LEFT_CORNER_BOT_X        lft_corner_bot_x
		LEFT_CORNER_BOT_Y        lft_corner_bot_y
		RIGHT_VALID              rt_valid
		RIGHT_VERTEX             rt_edge
		RIGHT_HEADER_OUTER_VALID rt_header_outer_valid
		RIGHT_HEADER_OUTER_X     rt_header_outer_x
		RIGHT_HEADER_OUTER_Y     rt_header_outer_y
		RIGHT_HEADER_INNER_VALID rt_header_inner_valid
		RIGHT_HEADER_INNER_X     rt_header_inner_x
		RIGHT_HEADER_INNER_Y     rt_header_inner_y
		RIGHT_CORNER_VALID       rt_corner_valid
		RIGHT_CORNER_TOP_X       rt_corner_top_x
		RIGHT_CORNER_TOP_Y       rt_corner_top_y
		RIGHT_CORNER_BOT_X       rt_corner_bot_x
		RIGHT_CORNER_BOT_Y       rt_corner_bot_y
	}
}

pip_add_bus_if $core m_axis_fsync {
	abstraction_type_vlnv xilinx.com:signal:video_frame_sync_rtl:1.0
	bus_type_vlnv xilinx.com:signal:video_frame_sync:1.0
	interface_mode slave
	enablement_dependency {$C_OUT_DW > 0}
} {
	FRAME_SYNC m_axis_fsync
}
append_associate_busif clk m_axis_fsync

pip_add_bus_if $core M_AXIS {
	abstraction_type_vlnv {xilinx.com:interface:axis_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:axis:1.0}
	interface_mode {master}
	enablement_dependency {$C_OUT_DW > 0}
} {
	TVALID	m_axis_tvalid
	TDATA	m_axis_tdata
	TUSER	m_axis_tuser
	TLAST	m_axis_tlast
	TREADY	m_axis_tready
}
append_associate_busif clk M_AXIS

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

pip_add_bus_if $core m_axis_resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
	enablement_dependency {$C_OUT_DW > 0}
} {
	RST m_axis_resetn
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
	ASSOCIATED_RESET {resetn m_axis_resetn}
}]

# parameters

pip_add_usr_par $core {C_PIXEL_WIDTH} {
	display_name {Stream Data Width}
	tooltip {Stream Data Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {8 10 12}
} {
	value 8
	value_format long
}

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

pip_add_usr_par $core {BR_AW} {
	display_name {Blockram Address Width}
	tooltip {Blockram Address Width}
	widget {textEdit}
} {
	value_resolve_type user
	enablement_value false
	value_tcl_expr {$C_IMG_WW}
	value 12
	value_format long
} {
	value 12
	value_format long
}

pip_add_usr_par $core {BR_DW} {
	display_name {Blockram Data Width}
	tooltip {Blockram Data Width}
	widget {comboBox}
} {
	value_resolve_type user
	enablement_value false
	value_tcl_expr {$C_IMG_WW * 4 + 3}
	value 51
	value_format long
} {
	value 51
	value_format long
}

pip_add_usr_par $core {C_OUT_DW} {
	display_name {MAXIS Data Width}
	tooltip {MAXIS Data Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {0 1 6 8 10 12 16 24 32}
} {
	value 8
	value_format long
}

pip_add_usr_par $core {C_OUT_DV} {
	display_name {MAXIS Data Value}
	tooltip {MAXIS Data Value}
	widget {hexEdit}
} {
	value_bit_string_length 32
	value_resolve_type user
	value {0x1}
	value_format bitString
	value_validation_type none
	enablement_tcl_expr {$C_OUT_DW > 0}
} {
	value_bit_string_length 32
	value {0x1}
	value_format bitString
}
