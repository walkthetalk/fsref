set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/aux/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -taxonomy $TAXONOMY $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

pip_set_prop [ipx::current_core] [subst {
	display_name {Fusion Splicer Motor}
	description {Motor IC interface on Fusion splicer}
	vendor_display_name $VENDORDISPNAME
	version $VERSION
	company_url $COMPANYURL
	supported_families {zynq Production}
}]

pip_clr_def_if_par_memmap [ipx::current_core]

for {set i 0} {$i < 4} {incr i} {
	pip_add_bus_if [ipx::current_core] S[set i] [subst {
		abstraction_type_vlnv $VENDOR:interface:motor_ic_ctl_rtl:1.0
		bus_type_vlnv $VENDOR:interface:motor_ic_ctl:1.0
		interface_mode slave
	}] [subst {
		ZPD       s[set i]_zpd
		DRIVE     s[set i]_drive
		DIRECTION s[set i]_dir
		MICROSTEP s[set i]_ms
		XEN       s[set i]_xen
		XRST      s[set i]_xrst
	}]
}

pip_add_usr_par [ipx::current_core] {C_MICROSTEP_WIDTH} {
	display_name {MicroStep Width}
	tooltip {MicroStep Width}
	widget {comboBox}
} {
	value_resolve_type user
	value 3
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4}
} {
	value 3
	value_format long
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
