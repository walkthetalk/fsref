# zero position detector
pip_add_bus_abstraction_port $busabs EN {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs CMD {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port $busabs PARAM {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port $busabs DONE {
	default_value 0
	master_direction in
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port $busabs ERR {
	default_value 0
	master_direction in
	slave_presence required
	is_data true
}
