
define_associate_busif clk_busif
define_associate_busif clk_reset

# clock & reset
pip_add_bus_if $core resetn {
	abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0
	bus_type_vlnv xilinx.com:signal:reset:1.0
	interface_mode slave
} {
	RST resetn
} {
	POLARITY {ACTIVE_LOW}
}
append_associate_busif clk_reset resetn

pip_add_bus_if $core clk {
	abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
	bus_type_vlnv xilinx.com:signal:clock:1.0
	interface_mode slave
} {
	CLK clk
} [subst {
	ASSOCIATED_BUSIF [get_associate_busif clk_busif]
	ASSOCIATED_RESET [get_associate_busif clk_reset]
}]

################################################################## interrupt

for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if $core intr_in[set i] [subst {
		abstraction_type_vlnv xilinx.com:signal:interrupt_rtl:1.0
		bus_type_vlnv xilinx.com:signal:interrupt:1.0
		interface_mode slave
		enablement_dependency {\$C_NUMBER > $i}
	}] [subst {
		INTERRUPT  intr_in[set i]
	}]
	append_associate_busif clk_busif intr_in[set i]
}
for {set i 0} {$i < 8} {incr i} {
	pip_add_bus_if $core intr_out[set i] [subst {
		abstraction_type_vlnv xilinx.com:signal:interrupt_rtl:1.0
		bus_type_vlnv xilinx.com:signal:interrupt:1.0
		interface_mode master
		enablement_dependency {\$C_NUMBER > $i}
	}] [subst {
		INTERRUPT  intr_out[set i]
	}]
	append_associate_busif clk_busif intr_out[set i]
}

###################################################################### parameters

pip_add_usr_par $core {C_NUMBER} {
	display_name {Interrupt Number}
	tooltip {Interrupt Number}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {1 2 3 4 5 6 7 8}
} {
	value 8
	value_format long
}

pip_add_usr_par $core {C_FILTER_CNT} {
	display_name {Filter Count}
	tooltip {Filter Count}
	widget {comboBox}
} {
	value_resolve_type user
	value 8
	value_format long
	value_validation_type list
	value_validation_list {8 16 32}
} {
	value 8
	value_format long
}
