pip_add_bus_if $core S_CTL [subst {
	abstraction_type_vlnv $VENDOR:interface:pwm_ctl_rtl:1.0
	bus_type_vlnv $VENDOR:interface:pwm_ctl:1.0
	interface_mode slave
}] [subst {
	DEF_VAL      def_val
	EN           en
	NUMERATOR    numerator
	DENOMINATOR  denominator
}]

pip_add_usr_par $core {C_PWM_CNT_WIDTH} {
	display_name {PWM Counter Width}
	tooltip {PWM Counter Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 16
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
} {
	value 16
	value_format long
}
