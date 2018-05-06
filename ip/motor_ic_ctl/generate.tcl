pip_add_bus_abstraction_port $busabs ZPD {
	default_value 0
	master_direction in
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs DRIVE {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs DIRECTION {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs MICROSTEP {
	default_value 0
	master_direction out
	is_data true
}

pip_add_bus_abstraction_port $busabs XEN {
	default_value 1
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port $busabs XRST {
	default_value 1
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}
