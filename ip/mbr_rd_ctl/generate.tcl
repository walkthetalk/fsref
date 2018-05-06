pip_add_bus_abstraction_port $busabs SOF {
	default_value 0
	master_presence required
	master_direction out
	master_width 1
	slave_presence required
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs EN {
	default_value 0
	master_presence required
	master_width 1
	master_direction out
	slave_presence required
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs ADDR {
	default_value 0
	master_presence required
	master_direction out
	slave_presence required
	is_address true
}

pip_add_bus_abstraction_port $busabs DATA {
	default_value 0
	master_presence required
	master_direction in
	slave_presence required
	is_data true
}
