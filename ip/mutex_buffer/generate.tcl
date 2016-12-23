set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]

source $origin_dir/scripts/util.tcl

set bus_name mutex_buffer
set abs_name mutex_buffer_rtl

set abs_file ${ip_dir}/${abs_name}.xml
set bus_file ${ip_dir}/${bus_name}.xml

ipx::create_abstraction_definition $VENDOR $LIBRARY ${abs_name} 1.0
ipx::create_bus_definition $VENDOR $LIBRARY ${bus_name} 1.0

pip_set_prop [ipx::current_busabs] {
	xml_file_name $abs_file
	bus_type_vlnv $VENDOR:$LIBRARY:$bus_name:1.0
}

pip_add_bus_abstraction_port [ipx::current_busabs] SOF {
	default_value 0
	master_presence required
	master_direction in
	master_width 1
	slave_presence required
	slave_width 1
	is_data true
}

pip_add_bus_abstraction_port [ipx::current_busabs] ADDR {
	default_value 0
	master_presence required
	master_width 32
	slave_presence required
	slave_direction in
	slave_width 32
	is_address true
}

ipx::save_abstraction_definition [ipx::current_busabs]

pip_set_prop [ipx::current_busdef] {
	xml_file_name $bus_file
}

ipx::save_bus_definition [ipx::current_busdef]
