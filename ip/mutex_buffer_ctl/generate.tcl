pip_add_bus_abstraction_port $busabs SOF {
	default_value 0
	master_presence required
	master_direction out
	master_width 1
	slave_presence required
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs ADDR {
	default_value 0
	master_direction in
	is_address true
}

pip_add_bus_abstraction_port $busabs IDX {
	default_value 0
	master_direction in
	is_address true
}

pip_add_bus_abstraction_port $busabs TS {
	default_value 0
	master_direction in
	is_data true
}
