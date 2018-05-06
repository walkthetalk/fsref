
for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_abstraction_port $busabs ADDR[set i] {
		default_value 0
		master_direction out
		slave_direction in
		is_address true
	}
}
