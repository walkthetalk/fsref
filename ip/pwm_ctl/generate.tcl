# zero position detector
pip_add_bus_abstraction_port $busabs DEF_VAL {
	default_value 0
	master_direction in
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs EN {
	default_value 0
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs NUMERATOR {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port $busabs DENOMINATOR {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}
