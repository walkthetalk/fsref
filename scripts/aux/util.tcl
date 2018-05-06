config_webtalk -user off

global VENDOR
set VENDOR ocfb
global LIBRARY
set LIBRARY pvip
global VERSION
set VERSION 1.0.9
global TAXONOMY
set TAXONOMY /UserIP
global COMPANYURL
set COMPANYURL https://github.com/walkthetalk
global VENDORDISPNAME
set VENDORDISPNAME OCFB

proc log2 {
	val
} {
	set ret 0
	set curv 1
	while {$curv <= $val} {
		set ret [expr {$ret+1}]
		set curv [expr {$curv*2}]
	}

	return $ret
}

proc rglobf {{dir ./} {pattern *}} {
	set result {}
	lappend result {*}[glob -nocomplain -directory $dir -type f -- $pattern]
	foreach subdir [glob -nocomplain -directory $dir -type d -- *] {
		lappend result {*}[rglobf $subdir $pattern]
	}

	return $result
}

proc pip_clr_def_if_par_memmap {
	core_inst
} {
	ipx::remove_all_bus_interface $core_inst
	ipx::remove_all_user_parameter $core_inst
	ipx::remove_all_address_space $core_inst
	ipx::remove_all_memory_map $core_inst
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
	__pip_set_prop $core_inst $prop_set
}

proc pip_set_prop_of_port {
	core_inst
	port_set
	prop_set
} {
	foreach p $port_set {
		pip_set_prop [ipx::get_ports $p -of_objects $core_inst] $prop_set
	}
}

proc pip_add_bus_if {
	core_inst
	bus_name
	bus_prop
	{port_map {}}
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

proc pip_add_bus_ifa {
	core_inst
	bus_name_fp
	bus_num
	bus_enadep
	bus_prop
	{port_map {}}
	{para_set {}}
} {
	for {set idx 0} {$idx < $bus_num} {incr idx} {
		set bus_name [$bus_name_fp $idx]
		ipx::add_bus_interface $bus_name $core_inst
		set bus_inst [ipx::get_bus_interfaces $bus_name -of_objects $core_inst]

		pip_set_prop $bus_inst $bus_prop
		pip_set_prop $bus_inst [subst {enablement_dependency {$bus_enadep > $idx}}]

		foreach {i j k} $port_map {
			ipx::add_port_map $i $bus_inst

			set_property physical_name $j [ipx::get_port_maps $i -of_objects $bus_inst]
			set_property physical_left_resolve_type dependent [ipx::get_port_maps $i -of_objects $bus_inst]
			set_property physical_right_dependency [subst {($idx * $k)}]           [ipx::get_port_maps $i -of_objects $bus_inst]
			set_property physical_right_resolve_type dependent [ipx::get_port_maps $i -of_objects $bus_inst]
			set_property physical_left_dependency  [subst {(([expr $idx + 1] * $k) - 1)}] [ipx::get_port_maps $i -of_objects $bus_inst]
		}

		foreach {i j} $para_set {
			ipx::add_bus_parameter $i $bus_inst
			set_property value $j [ipx::get_bus_parameters $i -of_objects $bus_inst]
		}
	}
}

proc pip_add_usr_par {
	core_inst
	par_name
	gui_par
	usr_par
	{hdl_par {}}
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
	pip_set_prop [ipx::get_bus_abstraction_ports $port_name -of_objects $busabs_inst] $port_prop
}

proc pip_add_memory_map {
	core_inst
	mm_name
	block_name
	bus_name
	{para_set {}}
} {
	ipx::add_memory_map $mm_name $core_inst
	set_property slave_memory_map_ref $mm_name [ipx::get_bus_interfaces $bus_name -of_objects $core_inst]
	ipx::add_address_block $block_name [ipx::get_memory_maps $mm_name -of_objects [ipx::current_core]]
	foreach {i j} $para_set {
		set_property $i $j [ipx::get_address_blocks $block_name -of_objects [ipx::get_memory_maps $mm_name -of_objects $core_inst]]
	}
}

proc pip_connect_intf_net {
	intf_pairs
} {
	foreach {i j} $intf_pairs {
		connect_bd_intf_net [get_bd_intf_pins $i] [get_bd_intf_pins $j]
	}
}

proc pip_connect_net {
	pin_pairs
} {
	foreach {i j} $pin_pairs {
		connect_bd_net [get_bd_pins $i] [get_bd_pins $j]
	}
}

proc pip_connect_pin {
	src_pin
	dst_pins
} {
	foreach {i} $dst_pins {
		connect_bd_net [get_bd_pins $src_pin] [get_bd_pins $i]
	}
}

proc define_associate_busif {
	clk_name
} {
	upvar [set clk_name]_ASSOCIATED_BUSIF locvar
	set locvar ""
}

proc append_associate_busif {
	clk_name
	busif_name
} {
	upvar [set clk_name]_ASSOCIATED_BUSIF locvar
	if {$locvar == ""} {
		append locvar $busif_name
	} else {
		append locvar :$busif_name
	}
}

proc append_associate_busifa {
	clk_name
	busif_name_fp
	num
} {
	upvar [set clk_name]_ASSOCIATED_BUSIF locvar
	for {set i 0} {$i < $num} {incr i} {
		set busif_name [$busif_name_fp $i]
		if {$locvar == ""} {
			append locvar $busif_name
		} else {
			append locvar :$busif_name
		}
	}
}

proc get_associate_busif {
	clk_name
} {
	upvar [set clk_name]_ASSOCIATED_BUSIF locvar
	return $locvar
}

proc NEW_CORE {
	root_dir
	{disp_name ""}
	{desc_str ""}
} {
	global VENDOR
	global LIBRARY
	global TAXONOMY
	global VENDORDISPNAME
	global VERSION
	global COMPANYURL

	set core_name [file tail $root_dir]

	if {$disp_name eq ""} {
		set disp_name $core_name
	}

	if {$desc_str eq ""} {
		set desc_str $disp_name
	}

	set core [ipx::create_core $VENDOR $LIBRARY $core_name $VERSION]
	#set_property core_revision $Revision $core

	pip_set_prop $core [subst {
		root_directory $root_dir
		display_name {$disp_name}
		description {$desc_str}
		taxonomy $TAXONOMY
		vendor_display_name $VENDORDISPNAME
		version $VERSION
		company_url $COMPANYURL
		supported_families {zynq Production}
	}]

	set fg_syn [ipx::add_file_group -type verilog:synthesis {} $core]
	#set fg_sim [ipx::add_file_group -type verilog:simulation {} $core]

	cd $root_dir
	foreach src_file [rglobf src] {
		ipx::add_file $src_file $fg_syn
	}
	set_property model_name $core_name $fg_syn

	ipx::import_top_level_hdl \
		-top_level_hdl_file src/$core_name.v \
		-include_dirs src/include \
		$core

	return $core
}

proc SAVE_CORE {
	core_inst
} {
	ipx::create_xgui_files $core_inst
	#ipx::check_integrity $core_inst
	ipx::update_checksums $core_inst
	ipx::save_core $core_inst

	set core_root_dir [get_property root_directory $core_inst]
	pip_clr_dir $core_root_dir/.Xil
}

proc NEW_BUS {
	root_dir
} {
	global VENDOR

	set bus_name [file tail $root_dir]

	cd $root_dir
	set bus_def [ipx::create_bus_definition $VENDOR interface ${bus_name} 1.0]
	pip_set_prop $bus_def [subst {
		xml_file_name ${bus_name}.xml
	}]
	ipx::save_bus_definition $bus_def

	set bus_abs [ipx::create_abstraction_definition $VENDOR interface ${bus_name}_rtl 1.0]

	pip_set_prop $bus_abs [subst {
		xml_file_name ${bus_name}_rtl.xml
		bus_type_vlnv $VENDOR:interface:$bus_name:1.0
	}]

	return $bus_abs
}

proc SAVE_BUS {
	bus_abs
} {
	ipx::save_abstraction_definition $bus_abs

	pip_clr_dir ./.Xil
}
