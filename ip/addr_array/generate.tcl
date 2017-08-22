set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]

source $origin_dir/scripts/aux/util.tcl

set bus_name addr_array
set abs_name addr_array_rtl

set abs_file ${ip_dir}/${abs_name}.xml
set bus_file ${ip_dir}/${bus_name}.xml

ipx::create_abstraction_definition $VENDOR interface ${abs_name} 1.0
ipx::create_bus_definition $VENDOR interface ${bus_name} 1.0

pip_set_prop [ipx::current_busabs] [subst {
	xml_file_name $abs_file
	bus_type_vlnv $VENDOR:interface:$bus_name:1.0
}]

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_abstraction_port [ipx::current_busabs] ADDR[set i] {
		default_value 0
		master_direction out
		slave_direction in
		is_address true
	}
}

ipx::save_abstraction_definition [ipx::current_busabs]

pip_set_prop [ipx::current_busdef] [subst {
	xml_file_name $bus_file
}]

ipx::save_bus_definition [ipx::current_busdef]
