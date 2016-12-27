set origin_dir [lindex $argv 0]
set ip_dir [file dirname $argv0]
set tmp_dir $ip_dir/tmp

source $origin_dir/scripts/util.tcl

ipx::infer_core -vendor $VENDOR -library $LIBRARY -taxonomy /UserIP $ip_dir
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $tmp_dir $ip_dir/component.xml
ipx::current_core $ip_dir/component.xml

#pip_clr_def_if_par [ipx::current_core]

pip_add_bus_if [ipx::current_core] FIFO_WRITE {
	abstraction_type_vlnv {xilinx.com:interface:fifo_write_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_write:1.0}
	interface_mode {master}
} {
	WR_DATA wr_data
	WR_EN wr_en
	FULL full
}

pip_add_bus_if [ipx::current_core] FIFO_READ {
	abstraction_type_vlnv {xilinx.com:interface:fifo_read_rtl:1.0}
	bus_type_vlnv {xilinx.com:interface:fifo_read:1.0}
	interface_mode {master}
} {
	RD_DATA rd_data
	RD_EN rd_en
	EMPTY empty
}

pip_add_bus_if [ipx::current_core] MBUF_W {
	abstraction_type_vlnv {user.org:user:mutex_buffer_rtl:1.0}
	bus_type_vlnv {user.org:user:mutex_buffer:1.0}
	interface_mode {slave}
} {
	SOF w_sof
	ADDR w_addr
}

pip_add_bus_if [ipx::current_core] MBUF_R {
	abstraction_type_vlnv {user.org:user:mutex_buffer_rtl:1.0}
	bus_type_vlnv {user.org:user:mutex_buffer:1.0}
	interface_mode {slave}
} {
	SOF r_sof
	ADDR r_addr
}

pip_set_prop [ipx::current_core] {
    core_revision 1
    supported_families {zynq Production}
}

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

pip_clr_dir $tmp_dir
