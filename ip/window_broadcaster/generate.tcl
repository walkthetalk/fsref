pip_add_bus_if $core S_WIN [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	LEFT    s_left
	TOP     s_top
	WIDTH   s_width
	HEIGHT  s_height
	STRIDE  s_stride
}
pip_set_prop_of_port $core {s_left s_top} {
	enablement_dependency {spirit:decode(id('PARAM_VALUE.C_HAS_POSITION'))}
}
pip_set_prop_of_port $core {s_stride} {
	enablement_dependency {spirit:decode(id('PARAM_VALUE.C_HAS_STRIDE'))}
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if $core M[set i]_WIN [subst {
		abstraction_type_vlnv $VENDOR:interface:window_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:window_ctl:1.0
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MASTER_NUM')) > $i}
	}] [subst {
		LEFT   m[set i]_left
		TOP    m[set i]_top
		WIDTH  m[set i]_width
		HEIGHT m[set i]_height
		STRIDE m[set i]_stride
	}]

	pip_set_prop_of_port $core [subst {m[set i]_left m[set i]_top}] [subst {
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MASTER_NUM')) > $i && spirit:decode(id('PARAM_VALUE.C_HAS_POSITION'))}
	}]

	pip_set_prop_of_port $core [subst {m[set i]_stride}] [subst {
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MASTER_NUM')) > $i && spirit:decode(id('PARAM_VALUE.C_HAS_STRIDE'))}
	}]
}

# parameters
pip_add_usr_par $core {C_WBITS} {
	display_name {Image Width (PIXEL) Bit Width}
	tooltip {IMAGE WIDTH/HEIGHT BIT WIDTH}
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

pip_add_usr_par $core {C_HBITS} {
	display_name {Image Height (PIXEL) Bit Width}
	tooltip {IMAGE WIDTH/HEIGHT BIT WIDTH}
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

pip_add_usr_par $core {C_SBITS} {
	display_name {Image Stride Bit Width}
	tooltip {IMAGE Stride BIT WIDTH}
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

pip_add_usr_par $core {C_MASTER_NUM} {
	display_name {Number Of Master}
	tooltip {Number Of Master}
	widget {comboBox}
} {
	value_resolve_type user
	value 2
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4 5 6 7 8}
} {
	value 2
	value_format long
}

pip_add_usr_par $core {C_HAS_POSITION} {
	display_name {Has Position}
	tooltip {Has Position}
	widget {checkBox}
} {
	value_resolve_type user
	value true
	value_format bool
}

pip_add_usr_par $core {C_HAS_STRIDE} {
	display_name {Has Stride}
	tooltip {Has Stride}
	widget {checkBox}
} {
	value_resolve_type user
	value false
	value_format bool
}
