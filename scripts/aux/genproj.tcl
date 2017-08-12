set origin_dir [lindex $argv 0]

source $origin_dir/scripts/util.tcl
source $origin_dir/ip/pvdma/create.tcl

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

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 cpu_axi_periph
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {7}] [get_bd_cells cpu_axi_periph]
endgroup

# 2. osd
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_osd:6.0 v_osd
endgroup
startgroup
set_property -dict [list \
    CONFIG.S_AXIS_VIDEO_FORMAT.VALUE_SRC USER \
    CONFIG.Data_Channel_Width.VALUE_SRC USER] [get_bd_cells v_osd]
set_property -dict [list \
    CONFIG.S_AXIS_VIDEO_FORMAT {RGBa} \
    CONFIG.M_AXIS_VIDEO_WIDTH {320} \
    CONFIG.M_AXIS_VIDEO_HEIGHT {240} \
    CONFIG.BG_COLOR0 {0} \
    CONFIG.BG_COLOR1 {0} \
    CONFIG.BG_COLOR2 {0} \
    CONFIG.NUMBER_OF_LAYERS {3} \
    CONFIG.LAYER0_TYPE {External_AXIS} \
    CONFIG.LAYER1_TYPE {External_AXIS} \
    CONFIG.LAYER2_TYPE {External_AXIS} \
    CONFIG.LAYER0_PRIORITY {0} \
    CONFIG.LAYER0_GLOBAL_ALPHA_VALUE {256} \
    CONFIG.LAYER0_HORIZONTAL_START_POSITION {0} \
    CONFIG.LAYER0_VERTICAL_START_POSITION {0} \
    CONFIG.LAYER0_WIDTH {320} \
    CONFIG.LAYER0_HEIGHT {240} \
    CONFIG.LAYER1_GLOBAL_ALPHA_ENABLE {true} \
    CONFIG.LAYER1_PRIORITY {1} \
    CONFIG.LAYER1_GLOBAL_ALPHA_VALUE {256} \
    CONFIG.LAYER1_HORIZONTAL_START_POSITION {0} \
    CONFIG.LAYER1_VERTICAL_START_POSITION {0} \
    CONFIG.LAYER1_WIDTH {320} \
    CONFIG.LAYER1_HEIGHT {240} \
    CONFIG.LAYER2_GLOBAL_ALPHA_ENABLE {true} \
    CONFIG.LAYER2_PRIORITY {2} \
    CONFIG.LAYER2_GLOBAL_ALPHA_VALUE {256} \
    CONFIG.LAYER2_HORIZONTAL_START_POSITION {0} \
    CONFIG.LAYER2_VERTICAL_START_POSITION {0} \
    CONFIG.LAYER2_WIDTH {320} \
    CONFIG.LAYER2_HEIGHT {240} \
    ] [get_bd_cells v_osd]
endgroup

# 3. vdma
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.3 axi_vdma_0
endgroup
startgroup
set_property -dict [list \
    CONFIG.c_num_fstores {1} \
    CONFIG.c_m_axi_mm2s_data_width {64} \
    CONFIG.c_m_axis_mm2s_tdata_width {32} \
    CONFIG.c_include_s2mm {0} \
    CONFIG.c_s2mm_genlock_mode {0} \
    CONFIG.c_mm2s_max_burst_length {16}] [get_bd_cells {axi_vdma_0}]
endgroup

# 4. vid_out
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_axi4s_vid_out:4.0 v_axi4s_vid_out_0
endgroup
startgroup
set_property -dict [list \
    CONFIG.C_S_AXIS_VIDEO_FORMAT.VALUE_SRC USER \
    CONFIG.C_S_AXIS_VIDEO_DATA_WIDTH.VALUE_SRC USER] [get_bd_cells v_axi4s_vid_out_0]
set_property -dict [list CONFIG.C_HAS_ASYNC_CLK {1} \
    CONFIG.C_VTG_MASTER_SLAVE {1}] [get_bd_cells v_axi4s_vid_out_0]
endgroup
# 5. vtc
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_tc:6.1 v_tc_0
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
    CONFIG.enable_detection {false}] [get_bd_cells v_tc_0]
endgroup
# 6. lcd
startgroup
create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fslcd:$VERSION fslcd_0
set_property -dict [list \
    CONFIG.C_IN_COMP_WIDTH {8} \
    CONFIG.C_OUT_COMP_WIDTH {6} \
] [get_bd_cells fslcd_0]
endgroup

# 7. cmos
startgroup
create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fscmos:$VERSION fscmos_0
endgroup
copy_bd_objs /  [get_bd_cells {fscmos_0}]

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_vid_in_axi4s:4.0 v_vid_in_axi4s_1
endgroup
startgroup
set_property -dict [list \
    CONFIG.C_PIXELS_PER_CLOCK {1} \
    CONFIG.C_M_AXIS_VIDEO_FORMAT {12} \
    CONFIG.C_M_AXIS_VIDEO_DATA_WIDTH {8} \
    CONFIG.C_NATIVE_COMPONENT_WIDTH {8} \
    CONFIG.C_HAS_ASYNC_CLK {1}] [get_bd_cells v_vid_in_axi4s_1]
endgroup
copy_bd_objs /  [get_bd_cells {v_vid_in_axi4s_1}]

create_pvdma pvdma_1
copy_bd_objs /  [get_bd_cells {pvdma_1}]

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon
set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {4}] [get_bd_cells axi_mem_intercon]
endgroup

# 7. constant 1
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
endgroup
# 8. reset for fclock
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk0
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk1
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk2
endgroup

# auto connect
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells cpu]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/cpu/M_AXI_GP0" Clk "/cpu/FCLK_CLK0 (76 MHz)" }  [get_bd_intf_pins v_osd/ctrl]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/cpu/M_AXI_GP0" Clk "/cpu/FCLK_CLK0 (76 MHz)" }  [get_bd_intf_pins axi_vdma_0/S_AXI_LITE]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axi_vdma_0/M_AXI_MM2S" Clk "/cpu/FCLK_CLK1 (142 MHz)" }  [get_bd_intf_pins cpu/S_AXI_HP0]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
set_property -dict [list CONFIG.NUM_PORTS {3}] [get_bd_cells xlconcat_0]
endgroup
# connect interrupt
connect_bd_net [get_bd_pins cpu/IRQ_F2P] [get_bd_pins xlconcat_0/dout]
connect_bd_net [get_bd_pins axi_vdma_0/mm2s_introut] [get_bd_pins xlconcat_0/In0]

# connect clocks
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins rst_cpu_fclk0/slowest_sync_clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins {axi_vdma_0/s_axi_lite_aclk}]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins cpu/M_AXI_GP0_ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins {cpu_axi_periph/*ACLK}]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins v_osd/s_axi_aclk]

connect_bd_net [get_bd_pins cpu/FCLK_RESET0_N] [get_bd_pins rst_cpu_fclk0/ext_reset_in]
connect_bd_net [get_bd_pins rst_cpu_fclk0/interconnect_aresetn] [get_bd_pins cpu_axi_periph/ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk0/peripheral_aresetn] [get_bd_pins {axi_vdma_0/axi_resetn}]
connect_bd_net [get_bd_pins rst_cpu_fclk0/peripheral_aresetn] [get_bd_pins {cpu_axi_periph/*_ARESETN}]
connect_bd_net [get_bd_pins rst_cpu_fclk0/peripheral_aresetn] [get_bd_pins v_osd/s_axi_aresetn]

connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins rst_cpu_fclk1/slowest_sync_clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins {cpu/S_AXI_HP*_ACLK}]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins {axi_vdma_0/*_mm2s_aclk}]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins {axi_mem_intercon/*ACLK}]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins v_osd/aclk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins v_axi4s_vid_out_0/aclk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins v_vid_in_axi4s_*/aclk]

connect_bd_net [get_bd_pins cpu/FCLK_RESET1_N] [get_bd_pins rst_cpu_fclk1/ext_reset_in]

connect_bd_net [get_bd_pins rst_cpu_fclk1/interconnect_aresetn] [get_bd_pins axi_mem_intercon/ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk1/peripheral_aresetn] [get_bd_pins {axi_mem_intercon/*_ARESETN}]
connect_bd_net [get_bd_pins rst_cpu_fclk1/peripheral_aresetn] [get_bd_pins v_osd/aresetn]
connect_bd_net [get_bd_pins rst_cpu_fclk1/peripheral_aresetn] [get_bd_pins v_axi4s_vid_out_0/aresetn]
connect_bd_net [get_bd_pins rst_cpu_fclk1/peripheral_aresetn] [get_bd_pins v_vid_in_axi4s_*/aresetn]

connect_bd_net [get_bd_pins cpu/FCLK_CLK2] [get_bd_pins rst_cpu_fclk2/slowest_sync_clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK2] [get_bd_pins v_tc_0/clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK2] [get_bd_pins v_axi4s_vid_out_0/vid_io_out_clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK2] [get_bd_pins fslcd_0/vid_io_in_clk]
connect_bd_net [get_bd_pins cpu/FCLK_RESET2_N] [get_bd_pins rst_cpu_fclk2/ext_reset_in]
connect_bd_net [get_bd_pins rst_cpu_fclk2/peripheral_reset] [get_bd_pins v_axi4s_vid_out_0/vid_io_out_reset]
connect_bd_net [get_bd_pins rst_cpu_fclk2/peripheral_aresetn] [get_bd_pins v_tc_0/resetn]

# connect data

# connect data: cpu -> lcd
connect_bd_intf_net [get_bd_intf_pins cpu/M_AXI_GP0] -boundary_type upper [get_bd_intf_pins cpu_axi_periph/S00_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins cpu_axi_periph/M00_AXI] [get_bd_intf_pins axi_vdma_0/S_AXI_LITE]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins cpu_axi_periph/M06_AXI] [get_bd_intf_pins v_osd/ctrl]

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins axi_vdma_0/M_AXI_MM2S]
connect_bd_intf_net [get_bd_intf_pins axi_vdma_0/M_AXIS_MM2S] [get_bd_intf_pins v_osd/video_s0_in]
connect_bd_intf_net [get_bd_intf_pins v_osd/video_out] [get_bd_intf_pins v_axi4s_vid_out_0/video_in]

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins v_axi4s_vid_out_0/vid_io_out] [get_bd_intf_pins fslcd_0/vid_io_in]

# connect data: cmos -> osd & cpu
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins fscmos_0/vid_io_out] [get_bd_intf_pins v_vid_in_axi4s_1/vid_io_in]
connect_bd_net [get_bd_pins fscmos_0/vid_io_out_clk] [get_bd_pins v_vid_in_axi4s_1/vid_io_in_clk]

for {set i 1} {$i < 3} {incr i} {
	connect_bd_net [get_bd_pins pvdma_$i/clk] [get_bd_pins cpu/FCLK_CLK1]
	connect_bd_net [get_bd_pins pvdma_$i/resetn] [get_bd_pins rst_cpu_fclk1/peripheral_aresetn]
	connect_bd_intf_net [get_bd_intf_pins v_vid_in_axi4s_$i/video_out] [get_bd_intf_pins pvdma_$i/S_AXIS]
	connect_bd_intf_net -boundary_type upper [get_bd_intf_pins pvdma_$i/M_AXI] [get_bd_intf_pins axi_mem_intercon/S0[set i]_AXI]
	connect_bd_intf_net -boundary_type upper [get_bd_intf_pins pvdma_$i/M_AXIS] [get_bd_intf_pins v_osd/video_s[set i]_in]
	connect_bd_net [get_bd_pins pvdma_$i/intr] [get_bd_pins xlconcat_0/In$i]
	connect_bd_net [get_bd_pins v_tc_0/fsync_out] [get_bd_pins pvdma_$i/fsync]
}

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins cpu/S_AXI_HP0]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon/M01_AXI] [get_bd_intf_pins cpu/S_AXI_HP1]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon/M02_AXI] [get_bd_intf_pins cpu/S_AXI_HP2]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon/M03_AXI] [get_bd_intf_pins cpu/S_AXI_HP3]

# connect data: cmos1 -> osd & cpu
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins fscmos_1/vid_io_out] [get_bd_intf_pins v_vid_in_axi4s_2/vid_io_in]
connect_bd_net [get_bd_pins fscmos_1/vid_io_out_clk]   [get_bd_pins v_vid_in_axi4s_2/vid_io_in_clk]

connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_osd/aclken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_osd/s_axi_aclken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_tc_0/clken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_tc_0/gen_clken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_axi4s_vid_out_0/aclken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_axi4s_vid_out_0/vid_io_out_ce]

connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_vid_in_axi4s_*/aclken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_vid_in_axi4s_*/axis_enable]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_vid_in_axi4s_*/vid_io_in_ce]

connect_bd_intf_net [get_bd_intf_pins v_tc_0/vtiming_out] [get_bd_intf_pins v_axi4s_vid_out_0/vtiming_in]

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
connect_bd_net [get_bd_pins /fslcd_0/r] [get_bd_ports lcd_R]
create_bd_port -dir O -from 5 -to 0 lcd_G
connect_bd_net [get_bd_pins /fslcd_0/g] [get_bd_ports lcd_G]
create_bd_port -dir O -from 5 -to 0 lcd_B
connect_bd_net [get_bd_pins /fslcd_0/b] [get_bd_ports lcd_B]

create_bd_port -dir O lcd_hsync
connect_bd_net [get_bd_pins /fslcd_0/hsync_out] [get_bd_ports lcd_hsync]
create_bd_port -dir O lcd_vsync
connect_bd_net [get_bd_pins /fslcd_0/vsync_out] [get_bd_ports lcd_vsync]
create_bd_port -dir O -from 3 -to 0 lcd_ctrl
connect_bd_net [get_bd_pins /fslcd_0/ctrl_out] [get_bd_ports lcd_ctrl]
endgroup

# 9. address
# auto assign all addresses
assign_bd_address
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {*/SEG_cpu_HP*_DDR_LOWOCM}]
set_property -dict [list offset {0x43000000} range {64K}] [get_bd_addr_segs {cpu/Data/SEG_axi_vdma_0_Reg}]
set_property -dict [list offset {0x43C00000} range {64K}] [get_bd_addr_segs {cpu/Data/SEG_v_osd_Reg}]

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