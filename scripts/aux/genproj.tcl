set origin_dir [lindex $argv 0]

source $origin_dir/scripts/aux/util.tcl
source $origin_dir/ip/fscore/create.tcl

# create project
create_project fsref $origin_dir -part xc7z020clg400-1
set_property simulator_language Verilog [current_project]

# update ips
# @note: must use [list xx yy]. the {xx yy} form cannot extent $ rightly.
set_property ip_repo_paths $origin_dir/ip [current_project]
update_ip_catalog

# create board design
create_bd_design "bd1"

# 1. cpu
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 cpu
endgroup

# @note: if using hp as 32bit, you should set the cpu register in software
startgroup
set_property -dict [list \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_EN_CLK1_PORT {1} \
    CONFIG.PCW_EN_CLK2_PORT {1} \
    CONFIG.PCW_EN_CLK3_PORT {1} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {75} \
    CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {150} \
    CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {10} \
    CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {24} \
    CONFIG.PCW_EN_RST0_PORT {1} \
    CONFIG.PCW_EN_RST1_PORT {1} \
    CONFIG.PCW_EN_RST2_PORT {1} \
    CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
    CONFIG.PCW_IRQ_F2P_INTR {1} \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} \
    CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
    CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {0} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
    CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} \
    CONFIG.PCW_USE_S_AXI_HP1 {1} \
    CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
    CONFIG.PCW_USE_S_AXI_HP2 {1} \
    CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
    CONFIG.PCW_USE_S_AXI_HP3 {1} \
    CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64}] [get_bd_cells cpu]
endgroup

# interconnection for control
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ic_ctl
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1}] [get_bd_cells ic_ctl]
endgroup

# 4. vid_out
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_axi4s_vid_out:4.0 videoout
endgroup
# @note: must use slave timing mode. for we have not enough time for processing
#        extra unused pixels in 'axis_window'.
startgroup
set_property -dict [list \
    CONFIG.C_S_AXIS_VIDEO_FORMAT.VALUE_SRC USER \
    CONFIG.C_S_AXIS_VIDEO_DATA_WIDTH.VALUE_SRC USER \
    CONFIG.C_HAS_ASYNC_CLK {1} \
    CONFIG.C_VTG_MASTER_SLAVE {0} \
] [get_bd_cells videoout]
endgroup
# 5. vtc
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_tc:6.1 vtc
endgroup
startgroup
set_property -dict [list \
    CONFIG.HAS_AXI4_LITE {false} \
    CONFIG.HAS_INTC_IF {false} \
    CONFIG.VIDEO_MODE {Custom} \
    CONFIG.GEN_F0_VSYNC_VSTART {250} \
    CONFIG.GEN_HACTIVE_SIZE {320} \
    CONFIG.GEN_HSYNC_END {340} \
    CONFIG.GEN_HFRAME_SIZE {417} \
    CONFIG.GEN_F0_VSYNC_HSTART {320} \
    CONFIG.GEN_F0_VSYNC_HEND {320} \
    CONFIG.GEN_F0_VFRAME_SIZE {263} \
    CONFIG.GEN_F0_VSYNC_VEND {252} \
    CONFIG.GEN_F0_VBLANK_HEND {320} \
    CONFIG.GEN_HSYNC_START {338} \
    CONFIG.GEN_VACTIVE_SIZE {240} \
    CONFIG.GEN_F0_VBLANK_HSTART {320} \
    CONFIG.FSYNC_HSTART0 {320} \
    CONFIG.FSYNC_VSTART0 {240} \
    CONFIG.enable_detection {false}] [get_bd_cells vtc]
endgroup
# 6. lcd
startgroup
create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fslcd:$VERSION fslcd
set_property -dict [list \
    CONFIG.C_IN_COMP_WIDTH {8} \
    CONFIG.C_OUT_COMP_WIDTH {6} \
] [get_bd_cells fslcd]
endgroup

# 7. cmos
startgroup
create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fscmos:$VERSION fscmos_0
endgroup
copy_bd_objs /  [get_bd_cells {fscmos_0}]

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_vid_in_axi4s:4.0 videoin_0
endgroup
startgroup
set_property -dict [list \
    CONFIG.C_PIXELS_PER_CLOCK {1} \
    CONFIG.C_M_AXIS_VIDEO_FORMAT {12} \
    CONFIG.C_M_AXIS_VIDEO_DATA_WIDTH {8} \
    CONFIG.C_NATIVE_COMPONENT_WIDTH {8} \
    CONFIG.C_HAS_ASYNC_CLK {1}] [get_bd_cells videoin_0]
endgroup
copy_bd_objs /  [get_bd_cells videoin_0]

# X. fusion splicer core
create_fscore fscore

# interconnection of data
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ic_data_0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1}] [get_bd_cells ic_data_0]
endgroup
copy_bd_objs /  [get_bd_cells ic_data_0]
copy_bd_objs /  [get_bd_cells ic_data_1]

# 7. constant 1
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
endgroup
# 8. reset for fclock
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk0
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk1
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk2
# fclk3 is only used for output, do not need reset
endgroup

# auto connect
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells cpu]
endgroup

# connect clocks
#     fclk0
pip_connect_pin cpu/FCLK_CLK0 {
	rst_cpu_fclk0/slowest_sync_clk
	cpu/M_AXI_GP0_ACLK
	ic_ctl/*ACLK
	fscore/s_axi_clk
}
pip_connect_pin cpu/FCLK_RESET0_N rst_cpu_fclk0/ext_reset_in
pip_connect_pin rst_cpu_fclk0/interconnect_aresetn {
	ic_ctl/*ARESETN
	fscore/s_axi_resetn
}

#     fclk1
pip_connect_pin cpu/FCLK_CLK1 {
	rst_cpu_fclk1/slowest_sync_clk
	cpu/S_AXI_HP*_ACLK
	ic_data_*/*ACLK
	fscore/clk
	videoout/aclk
	videoin_*/aclk
}
pip_connect_pin cpu/FCLK_RESET1_N rst_cpu_fclk1/ext_reset_in
pip_connect_pin rst_cpu_fclk1/interconnect_aresetn ic_data_*/ARESETN
pip_connect_pin rst_cpu_fclk1/peripheral_aresetn {
	ic_data_*/*_ARESETN
	fscore/resetn
	videoout/aresetn
	videoin_*/aresetn
}

#     fclk2
pip_connect_pin cpu/FCLK_CLK2 {
	rst_cpu_fclk2/slowest_sync_clk
	vtc/clk
	videoout/vid_io_out_clk
	fslcd/vid_io_in_clk
}
pip_connect_pin cpu/FCLK_RESET2_N rst_cpu_fclk2/ext_reset_in
pip_connect_pin rst_cpu_fclk2/peripheral_reset videoout/vid_io_out_reset
pip_connect_pin rst_cpu_fclk2/peripheral_aresetn vtc/resetn

# connect data

# connect data: cpu -> lcd
pip_connect_intf_net {
	ic_data_0/M00_AXI        cpu/S_AXI_HP0
	ic_data_1/M00_AXI        cpu/S_AXI_HP1
	ic_data_2/M00_AXI        cpu/S_AXI_HP2
	ic_data_0/S00_AXI        fscore/M0_AXI
	ic_data_1/S00_AXI        fscore/M1_AXI
	ic_data_2/S00_AXI        fscore/M2_AXI
	cpu/M_AXI_GP0            ic_ctl/S00_AXI
	ic_ctl/M00_AXI           fscore/S_AXI_LITE
	fscore/M_AXIS            videoout/video_in
	videoout/vid_io_out      fslcd/vid_io_in
	fscmos_0/vid_io_out      videoin_0/vid_io_in
	videoin_0/video_out      fscore/S0_AXIS
	fscmos_1/vid_io_out      videoin_1/vid_io_in
	videoin_1/video_out      fscore/S1_AXIS
	vtc/vtiming_out          videoout/vtiming_in
}

# connect data: cmos -> osd & cpu
pip_connect_net [subst {
	fscmos_0/vid_io_out_clk   videoin_0/vid_io_in_clk
	fscmos_1/vid_io_out_clk   videoin_1/vid_io_in_clk
	vtc/fsync_out             fscore/fsync
}]

pip_connect_pin xlconstant_0/dout {
	vtc/clken
	vtc/gen_clken
	videoin_*/aclken
	videoin_*/axis_enable
	videoin_*/vid_io_in_ce
	videoout/aclken
	videoout/vid_io_out_ce
}

# connect from/to external cmos
startgroup
create_bd_port -type clk -dir O cmos0_xclk
connect_bd_net [get_bd_pins cpu/FCLK_CLK3] [get_bd_ports cmos0_xclk]
create_bd_port -dir I cmos0_pclk
connect_bd_net [get_bd_pins /fscmos_0/cmos_pclk] [get_bd_ports cmos0_pclk]
create_bd_port -dir I cmos0_href
connect_bd_net [get_bd_pins /fscmos_0/cmos_href] [get_bd_ports cmos0_href]
create_bd_port -dir I cmos0_vsync
connect_bd_net [get_bd_pins /fscmos_0/cmos_vsync] [get_bd_ports cmos0_vsync]
create_bd_port -dir I -from 7 -to 0 cmos0_data
connect_bd_net [get_bd_pins /fscmos_0/cmos_data] [get_bd_ports cmos0_data]
endgroup
startgroup
create_bd_port -type clk -dir O cmos1_xclk
connect_bd_net [get_bd_pins cpu/FCLK_CLK3] [get_bd_ports cmos1_xclk]
create_bd_port -dir I cmos1_pclk
connect_bd_net [get_bd_pins /fscmos_1/cmos_pclk] [get_bd_ports cmos1_pclk]
create_bd_port -dir I cmos1_href
connect_bd_net [get_bd_pins /fscmos_1/cmos_href] [get_bd_ports cmos1_href]
create_bd_port -dir I cmos1_vsync
connect_bd_net [get_bd_pins /fscmos_1/cmos_vsync] [get_bd_ports cmos1_vsync]
create_bd_port -dir I -from 7 -to 0 cmos1_data
connect_bd_net [get_bd_pins /fscmos_1/cmos_data] [get_bd_ports cmos1_data]
endgroup

# connect from/to external lcd
startgroup
create_bd_port -dir O lcd_clk
connect_bd_net [get_bd_pins cpu/FCLK_CLK2] [get_bd_ports lcd_clk]
create_bd_port -dir O -from 5 -to 0 lcd_R
connect_bd_net [get_bd_pins /fslcd/r] [get_bd_ports lcd_R]
create_bd_port -dir O -from 5 -to 0 lcd_G
connect_bd_net [get_bd_pins /fslcd/g] [get_bd_ports lcd_G]
create_bd_port -dir O -from 5 -to 0 lcd_B
connect_bd_net [get_bd_pins /fslcd/b] [get_bd_ports lcd_B]

create_bd_port -dir O lcd_hsync
connect_bd_net [get_bd_pins /fslcd/hsync_out] [get_bd_ports lcd_hsync]
create_bd_port -dir O lcd_vsync
connect_bd_net [get_bd_pins /fslcd/vsync_out] [get_bd_ports lcd_vsync]
create_bd_port -dir O -from 3 -to 0 lcd_ctrl
connect_bd_net [get_bd_pins /fslcd/ctrl_out] [get_bd_ports lcd_ctrl]
endgroup

# 9. address
# auto assign all addresses
assign_bd_address
set_property -dict [list offset {0x43C00000} range {64K}] [get_bd_addr_segs {fscore/axilite2regctl/S_AXI_LITE/S_AXI_LITE_reg}]
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/pvdma_0/mm2s/M_AXI_REG/SEG_cpu_HP0_DDR_LOWOCM}]

set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/pvdma_1/mm2s/M_AXI_REG/SEG_axi_combiner_Reg}]
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/pvdma_1/s2mm/M_AXI_REG/SEG_axi_combiner_Reg}]
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/pvdma_1/axi_combiner/M_AXI_REG/SEG_cpu_HP1_DDR_LOWOCM}]

set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/pvdma_2/mm2s/M_AXI_REG/SEG_axi_combiner_Reg}]
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/pvdma_2/s2mm/M_AXI_REG/SEG_axi_combiner_Reg}]
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/pvdma_2/axi_combiner/M_AXI_REG/SEG_cpu_HP2_DDR_LOWOCM}]

# save board design
save_bd_design

# create wrapper
make_wrapper -files [get_files $origin_dir/fsref.srcs/sources_1/bd/bd1/bd1.bd] -top
add_files -norecurse $origin_dir/fsref.srcs/sources_1/bd/bd1/hdl/bd1_wrapper.v

# set property of bd1
set_property used_in_simulation false [get_files  $origin_dir/fsref.srcs/sources_1/bd/bd1/bd1.bd]
set_property used_in_simulation false [get_files  $origin_dir/fsref.srcs/sources_1/bd/bd1/hdl/bd1_wrapper.v]


update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# xdc
set xdc_file $origin_dir/ip/top.xdc
add_files -fileset constrs_1 $xdc_file
set_property target_constrs_file $xdc_file [current_fileset -constrset]

#################################################### simlate ############################################
create_fileset -simset sim_yscaler
create_bd_design -srcset sim_yscaler "test_yscaler"
update_compile_order -fileset sim_yscaler
source $origin_dir/ip/yscaler/sim.tcl
make_wrapper -files [get_files $origin_dir/fsref.srcs/sim_yscaler/bd/test_yscaler/test_yscaler.bd] -top
add_files -fileset sim_yscaler -norecurse $origin_dir/fsref.srcs/sim_yscaler/bd/test_yscaler/hdl/test_yscaler_wrapper.v
add_files -fileset sim_yscaler $origin_dir/ip/yscaler/test
