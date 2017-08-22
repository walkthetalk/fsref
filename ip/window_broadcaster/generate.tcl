set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -name window_broadcaster -taxonomy $TAXONOMY $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_set_prop [ipx::current_core] [subst {
	display_name {Window Broadcaster}
	description {Window Broadcaster}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}]

pip_clr_def_if_par_memmap [ipx::current_core]

pip_add_bus_if [ipx::current_core] S_WIN [subst {
	abstraction_type_vlnv {$VENDOR:interface:window_ctl_rtl:1.0}
	bus_type_vlnv {$VENDOR:interface:window_ctl:1.0}
	interface_mode {slave}
}] {
	LEFT    s_left
	TOP     s_top
	WIDTH   s_width
	HEIGHT  s_height
}
pip_set_prop_of_port [ipx::current_core] {s_left s_top} {
	enablement_dependency {spirit:decode(id('PARAM_VALUE.C_HAS_POSITION'))}
}

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if [ipx::current_core] M[set i]_WIN [subst {
		abstraction_type_vlnv $VENDOR:interface:window_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:window_ctl:1.0
		interface_mode {master}
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MASTER_NUM')) > $i}
	}] [subst {
		LEFT   m[set i]_left
		TOP    m[set i]_top
		WIDTH  m[set i]_width
		HEIGHT m[set i]_height
	}]

	pip_set_prop_of_port [ipx::current_core] [subst {m[set i]_left m[set i]_top}] [subst {
		enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.C_MASTER_NUM')) > $i && spirit:decode(id('PARAM_VALUE.C_HAS_POSITION'))}
	}]
}

# parameters
pip_add_usr_par [ipx::current_core] {C_WBITS} {
	display_name {Image Width (PIXEL) Bit Width}
	tooltip {IMAGE WIDTH/HEIGHT BIT WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {5 6 7 8 9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_HBITS} {
	display_name {Image Height (PIXEL) Bit Width}
	tooltip {IMAGE WIDTH/HEIGHT BIT WIDTH}
	widget {comboBox}
} {
	value_resolve_type user
	value 12
	value_format long
	value_validation_type list
	value_validation_list {5 6 7 8 9 10 11 12}
} {
	value 12
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_MASTER_NUM} {
	display_name {Number Of Master}
	tooltip {Number Of Master}
	widget {comboBox}
} {
	value_resolve_type user
	value 2
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4 5 6 7 8}
} {
	value 2
	value_format long
}

pip_add_usr_par [ipx::current_core] {C_HAS_POSITION} {
	display_name {Has Position}
	tooltip {Has Position}
	widget {checkBox}
} {
	value_resolve_type user
	value true
	value_format bool
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
