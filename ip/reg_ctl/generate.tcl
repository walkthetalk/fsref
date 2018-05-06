pip_add_bus_abstraction_port $busabs RD_EN {
	default_value 0
	master_direction out
	slave_direction in
}
pip_add_bus_abstraction_port $busabs RD_ADDR {
	default_value 0
	master_direction out
	slave_direction in
	is_address true
}
pip_add_bus_abstraction_port $busabs RD_DATA {
	default_value 0
	master_direction in
	slave_direction out
	is_data true
}

pip_add_bus_abstraction_port $busabs WR_EN {
	default_value 0
	master_direction out
	slave_direction in
}

pip_add_bus_abstraction_port $busabs WR_ADDR {
	default_value 0
	master_direction out
	slave_direction in
	is_address true
}

pip_add_bus_abstraction_port $busabs WR_DATA {
	default_value 0
	master_direction out
	slave_direction in
	is_data true
}
