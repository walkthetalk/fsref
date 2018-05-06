pip_add_bus_abstraction_port $busabs SRC_WIDTH {
	default_value 0
	master_presence required
	master_direction out
	slave_presence required
	slave_direction in
	is_data true
}

pip_add_bus_abstraction_port $busabs SRC_HEIGHT {
	default_value 0
	master_presence required
	master_direction out
	slave_presence required
	slave_direction in
	is_data true
}

pip_add_bus_abstraction_port $busabs DST_WIDTH {
	default_value 0
	master_presence required
	master_direction out
	slave_presence required
	slave_direction in
	is_data true
}

pip_add_bus_abstraction_port $busabs DST_HEIGHT {
	default_value 0
	master_presence required
	master_direction out
	slave_presence required
	slave_direction in
	is_data true
}
