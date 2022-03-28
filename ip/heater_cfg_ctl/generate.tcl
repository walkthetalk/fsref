
pip_add_bus_abstraction_port $busabs AUTO_START {
	default_value 0
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs AUTO_HOLD {
	default_value 0
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs HOLD_V {
	default_value 0
	master_direction out
	is_data true
}
pip_add_bus_abstraction_port $busabs HEAT_V {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}
pip_add_bus_abstraction_port $busabs HEAT_TIME {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port $busabs FINISH_V {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
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

pip_add_bus_abstraction_port $busabs STATE {
	default_value 0
	master_direction in
	is_data true
}

pip_add_bus_abstraction_port $busabs VALUE {
	default_value 0
	master_direction in
	is_data true
}
