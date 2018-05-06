pip_add_bus_abstraction_port $busabs INIT {
	default_value 0
	master_presence required
	master_direction out
	master_width 1
	slave_presence required
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs WR_EN {
	default_value 0
	master_presence required
	master_width 1
	slave_presence required
	slave_direction in
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs DATA {
	master_presence required
	slave_presence required
	slave_direction in
	is_data true
}

pip_add_bus_abstraction_port $busabs SIZE {
	master_presence required
	slave_presence required
	master_direction in
	is_data true
}
