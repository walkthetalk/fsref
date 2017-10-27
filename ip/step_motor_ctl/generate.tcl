set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]

source $origin_dir/scripts/aux/util.tcl

set bus_name step_motor_ctl
set abs_name step_motor_ctl_rtl

set abs_file ${ip_dir}/${abs_name}.xml
set bus_file ${ip_dir}/${bus_name}.xml

ipx::create_abstraction_definition $VENDOR interface ${abs_name} 1.0
ipx::create_bus_definition $VENDOR interface ${bus_name} 1.0

pip_set_prop [ipx::current_busabs] [subst {
	xml_file_name $abs_file
	bus_type_vlnv $VENDOR:interface:$bus_name:1.0
}]

# zero position sign
pip_add_bus_abstraction_port [ipx::current_busabs] ZPSIGN {
	default_value 0
	master_direction in
	master_width 1
	slave_width 1
	is_data true
}

# terminal position sign
pip_add_bus_abstraction_port [ipx::current_busabs] TPSIGN {
	default_value 0
	master_direction in
	master_width 1
	slave_width 1
	is_data true
}

# stroke
pip_add_bus_abstraction_port [ipx::current_busabs] STROKE {
	default_value 0
	master_direction out
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] SPEED {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] STEP {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] START {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] STOP {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] DIRECTION {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] MICROSTEP {
	default_value 0
	master_direction out
	master_presence required
	slave_presence required
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] STATE {
	default_value 1
	master_direction in
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] XEN {
	default_value 1
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] XRST {
	default_value 1
	master_direction out
	master_width 1
	slave_width 1
	is_data true
}

ipx::save_abstraction_definition [ipx::current_busabs]

pip_set_prop [ipx::current_busdef] [subst {
	xml_file_name $bus_file
}]

ipx::save_bus_definition [ipx::current_busdef]
