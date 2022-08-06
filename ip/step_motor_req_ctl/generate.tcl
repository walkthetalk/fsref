# negative terminal position sign
pip_add_bus_abstraction_port $busabs NTSIGN {
	default_value 0
	master_direction in
	master_width 1
	slave_width 1
	is_data true
}

# zero position sign
pip_add_bus_abstraction_port $busabs ZPSIGN {
	default_value 0
	master_direction in
	master_width 1
	slave_width 1
	is_data true
}

# positive terminal position sign
pip_add_bus_abstraction_port $busabs PTSIGN {
	default_value 0
	master_direction in
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs STATE {
	default_value 1
	master_direction in
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs RT_SPEED {
	default_value 0
	master_direction in
	is_data true
}

pip_add_bus_abstraction_port $busabs RT_DIR {
	default_value 0
	master_direction in
	is_data true
}

pip_add_bus_abstraction_port $busabs POSITION {
	default_value 0
	master_direction in
	is_data true
}

pip_add_bus_abstraction_port $busabs START {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs STOP {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs SPEED {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port $busabs STEP {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port $busabs ABSOLUTE {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	master_width 1
	slave_width 1
	is_data true
}

# modify remain step
pip_add_bus_abstraction_port $busabs MOD_REMAIN {
	default_value 0
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}

# new remain step (reference MOD_REMAIN)
pip_add_bus_abstraction_port $busabs NEW_REMAIN {
	default_value 0
	master_direction out
	is_data true
}
