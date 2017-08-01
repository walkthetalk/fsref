config_webtalk -user off

set VENDOR ocfb
set LIBRARY pvip
set VERSION 1.0.7

proc pip_clr_def_if_par {
	core_inst
} {
	ipx::remove_all_bus_interface $core_inst
	ipx::remove_all_user_parameter $core_inst
	ipx::remove_all_address_space $core_inst
	ipgui::remove_page -component [ipx::current_core] [ipgui::get_pagespec -name "Page 0" -component $core_inst]
}

proc __pip_set_prop {
	core_inst
	prop_set
} {
	foreach {i j} $prop_set {
		set_property $i $j $core_inst
	}
}

proc pip_set_prop {
	core_inst
	prop_set
} {
	__pip_set_prop $core_inst [uplevel subst -nobackslash [list $prop_set]]
}

proc pip_add_bus_if {
	core_inst
	bus_name
	bus_prop
	port_map
	{para_set {}}
} {
	ipx::add_bus_interface $bus_name $core_inst
	set bus_inst [ipx::get_bus_interfaces $bus_name -of_objects $core_inst]

	pip_set_prop $bus_inst $bus_prop

	foreach {i j} $port_map {
		ipx::add_port_map $i $bus_inst
		set_property physical_name $j [ipx::get_port_maps $i -of_objects $bus_inst]
	}

	foreach {i j} $para_set {
		ipx::add_bus_parameter $i $bus_inst
		set_property value $j [ipx::get_bus_parameters $i -of_objects $bus_inst]
	}
}

proc pip_add_usr_par {
	core_inst
	par_name
	gui_par
	usr_par
	hdl_par
} {
	ipx::add_user_parameter $par_name $core_inst
	ipgui::add_param -name $par_name -component $core_inst
	pip_set_prop [ipgui::get_guiparamspec -name $par_name -component $core_inst ] $gui_par
	pip_set_prop [ipx::get_user_parameters $par_name -of_objects $core_inst] $usr_par
	pip_set_prop [ipx::get_hdl_parameters $par_name -of_objects $core_inst] $hdl_par
}

proc pip_add_address_space {
	core_inst
	if_inst
	as_name
	{para_set {}}
} {
	ipx::add_address_space $as_name $core_inst

	set_property master_address_space_ref $as_name [ipx::get_bus_interfaces $if_inst -of_objects $core_inst]

	foreach {i j} $para_set {
		set_property $i $j [ipx::get_address_spaces $as_name -of_objects $core_inst]
	}
}

proc pip_clr_dir {dir} {
	exec rm -rf $dir
}

proc pip_add_bus_abstraction_port {
	busabs_inst
	port_name
	port_prop
} {
	ipx::add_bus_abstraction_port $port_name $busabs_inst
	pip_set_prop [ipx::get_bus_abstraction_ports $port_name -of_objects $busabs_inst] [uplevel subst -nobackslash [list $port_prop]]
}
