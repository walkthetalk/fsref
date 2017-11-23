set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]

source $origin_dir/scripts/aux/util.tcl

set bus_name window_ctl
set abs_name window_ctl_rtl

set abs_file ${ip_dir}/${abs_name}.xml
set bus_file ${ip_dir}/${bus_name}.xml

ipx::create_abstraction_definition $VENDOR interface ${abs_name} 1.0
ipx::create_bus_definition $VENDOR interface ${bus_name} 1.0

pip_set_prop [ipx::current_busabs] [subst {
	xml_file_name $abs_file
	bus_type_vlnv $VENDOR:interface:$bus_name:1.0
}]

pip_add_bus_abstraction_port [ipx::current_busabs] LEFT {
	default_value 0
	master_direction out
	slave_direction in
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] TOP {
	default_value 0
	master_direction out
	slave_direction in
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] WIDTH {
	default_value 0
	master_direction out
	slave_direction in
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] RIGHTE {
	default_value 0
	master_direction out
	slave_direction in
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] HEIGHT {
	default_value 0
	master_direction out
	slave_direction in
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] BOTTOME {
	default_value 0
	master_direction out
	slave_direction in
	is_data true
}

ipx::save_abstraction_definition [ipx::current_busabs]

pip_set_prop [ipx::current_busdef] [subst {
	xml_file_name $bus_file
}]

ipx::save_bus_definition [ipx::current_busdef]
