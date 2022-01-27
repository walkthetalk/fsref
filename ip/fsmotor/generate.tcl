for {set i 0} {$i < 6} {incr i} {
	pip_add_bus_if $core S[set i] [subst {
		abstraction_type_vlnv $VENDOR:interface:motor_ic_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:motor_ic_ctl:1.0
		interface_mode slave
	}] [subst {
		ZPD       s[set i]_zpd
		DRIVE     s[set i]_drive
		DIRECTION s[set i]_dir
		MICROSTEP s[set i]_ms
		XEN       s[set i]_xen
		XRST      s[set i]_xrst
	}]
}

pip_add_usr_par $core {C_MICROSTEP_WIDTH} {
	display_name {MicroStep Width}
	tooltip {MicroStep Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 3
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4}
} {
	value 3
	value_format long
}

pip_add_usr_par $core {C_INVERT_DIR} {
	display_name {invert direction}
	tooltip {Invert Direction}
	widget {checkBox}
} {
	value_resolve_type user
	value false
	value_format bool
} {
	value false
	value_format bool
}
