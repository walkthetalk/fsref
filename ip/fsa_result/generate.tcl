
pip_add_bus_abstraction_port $busabs DONE {
	default_value 0
	master_direction out
	master_presence required
	is_data true
}

pip_add_bus_abstraction_port $busabs LEFT_VALID {
	default_value 0
	master_presence required
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs LEFT_VERTEX {
	default_value 0
	master_presence required
	master_direction out
	is_data true
}

pip_add_bus_abstraction_port $busabs RIGHT_VALID {
	default_value 0
	master_presence required
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs RIGHT_VERTEX {
	default_value 0
	master_presence required
	master_direction out
	is_data true
}