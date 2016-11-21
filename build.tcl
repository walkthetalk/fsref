set origin_dir "."

# create project
create_project fsref $origin_dir -part xc7z020clg400-1
set_property simulator_language Verilog [current_project]

# new ip: fslcd
ipx::infer_core -vendor user.org -library user -taxonomy /UserIP $origin_dir/ip/lcd
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory $origin_dir/fsref.tmp $origin_dir/ip/lcd/component.xml
ipx::current_core $origin_dir/ip/lcd/component.xml
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete
set_property  ip_repo_paths  $origin_dir/ip/lcd [current_project]
update_ip_catalog

# create board design
create_bd_design "bd1"
# 1. cpu
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 cpu
endgroup
startgroup
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {75} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {150} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {10} CONFIG.PCW_EN_RST0_PORT {1} CONFIG.PCW_EN_RST1_PORT {1} CONFIG.PCW_EN_RST2_PORT {1} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {0} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} CONFIG.PCW_USE_S_AXI_HP0 {1}] [get_bd_cells cpu]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 cpu_axi_periph
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon
endgroup

# 2. osd
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_osd:6.0 v_osd_0
endgroup
startgroup
set_property -dict [list CONFIG.S_AXIS_VIDEO_FORMAT.VALUE_SRC USER CONFIG.Data_Channel_Width.VALUE_SRC USER] [get_bd_cells v_osd_0]
set_property -dict [list CONFIG.S_AXIS_VIDEO_FORMAT {RGBa} CONFIG.M_AXIS_VIDEO_HEIGHT {240} CONFIG.LAYER3_TYPE {External_AXIS} CONFIG.BG_COLOR0 {0} CONFIG.NUMBER_OF_LAYERS {8} CONFIG.BG_COLOR1 {0} CONFIG.LAYER7_TYPE {Internal_Graphics_Controller} CONFIG.BG_COLOR2 {0} CONFIG.M_AXIS_VIDEO_WIDTH {320} CONFIG.LAYER7_INSTRUCTION_MEMORY_SIZE {64} CONFIG.LAYER7_BOX_INSTRUCTION_ENABLE {true} CONFIG.LAYER7_TEXT_INSTRUCTION_ENABLE {true} CONFIG.LAYER7_COLOR_TABLE_SIZE {256} CONFIG.LAYER7_FONT_CHARACTER_WIDTH {8} CONFIG.LAYER7_FONT_CHARACTER_HEIGHT {8} CONFIG.LAYER7_FONT_BITS_PER_PIXEL {1} CONFIG.LAYER7_TEXT_NUMBER_OF_STRINGS {256} CONFIG.LAYER7_TEXT_MAX_STRING_LENGTH {256} CONFIG.LAYER0_PRIORITY {0} CONFIG.LAYER0_GLOBAL_ALPHA_VALUE {256} CONFIG.LAYER0_HORIZONTAL_START_POSITION {0} CONFIG.LAYER0_VERTICAL_START_POSITION {0} CONFIG.LAYER0_WIDTH {320} CONFIG.LAYER0_HEIGHT {240} CONFIG.LAYER1_GLOBAL_ALPHA_ENABLE {true} CONFIG.LAYER1_PRIORITY {1} CONFIG.LAYER1_GLOBAL_ALPHA_VALUE {256} CONFIG.LAYER1_HORIZONTAL_START_POSITION {0} CONFIG.LAYER1_VERTICAL_START_POSITION {0} CONFIG.LAYER1_WIDTH {320} CONFIG.LAYER1_HEIGHT {240} CONFIG.LAYER2_GLOBAL_ALPHA_ENABLE {true} CONFIG.LAYER2_PRIORITY {2} CONFIG.LAYER2_GLOBAL_ALPHA_VALUE {256} CONFIG.LAYER2_HORIZONTAL_START_POSITION {0} CONFIG.LAYER2_VERTICAL_START_POSITION {0} CONFIG.LAYER2_WIDTH {320} CONFIG.LAYER2_HEIGHT {240} CONFIG.LAYER3_GLOBAL_ALPHA_ENABLE {true} CONFIG.LAYER3_PRIORITY {3} CONFIG.LAYER3_GLOBAL_ALPHA_VALUE {256} CONFIG.LAYER3_HORIZONTAL_START_POSITION {0} CONFIG.LAYER3_VERTICAL_START_POSITION {0} CONFIG.LAYER3_WIDTH {320} CONFIG.LAYER3_HEIGHT {240} CONFIG.LAYER4_GLOBAL_ALPHA_ENABLE {true} CONFIG.LAYER4_PRIORITY {4} CONFIG.LAYER4_GLOBAL_ALPHA_VALUE {256} CONFIG.LAYER4_HORIZONTAL_START_POSITION {0} CONFIG.LAYER4_VERTICAL_START_POSITION {0} CONFIG.LAYER4_WIDTH {320} CONFIG.LAYER4_HEIGHT {240} CONFIG.LAYER5_GLOBAL_ALPHA_ENABLE {true} CONFIG.LAYER5_PRIORITY {5} CONFIG.LAYER5_GLOBAL_ALPHA_VALUE {256} CONFIG.LAYER5_HORIZONTAL_START_POSITION {0} CONFIG.LAYER5_VERTICAL_START_POSITION {0} CONFIG.LAYER5_WIDTH {320} CONFIG.LAYER5_HEIGHT {240} CONFIG.LAYER6_GLOBAL_ALPHA_ENABLE {true} CONFIG.LAYER6_PRIORITY {6} CONFIG.LAYER6_GLOBAL_ALPHA_VALUE {256} CONFIG.LAYER6_HORIZONTAL_START_POSITION {0} CONFIG.LAYER6_VERTICAL_START_POSITION {0} CONFIG.LAYER6_WIDTH {320} CONFIG.LAYER6_HEIGHT {240} CONFIG.LAYER7_GLOBAL_ALPHA_ENABLE {false} CONFIG.LAYER7_PRIORITY {7} CONFIG.LAYER7_GLOBAL_ALPHA_VALUE {256} CONFIG.LAYER7_HORIZONTAL_START_POSITION {0} CONFIG.LAYER7_VERTICAL_START_POSITION {0} CONFIG.LAYER7_WIDTH {320} CONFIG.LAYER7_HEIGHT {240}] [get_bd_cells v_osd_0]
endgroup
# 3. vdma
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.2 axi_vdma_0
endgroup
startgroup
set_property -dict [list CONFIG.c_m_axi_mm2s_data_width {32} CONFIG.c_m_axis_mm2s_tdata_width {32} CONFIG.c_include_s2mm {0} CONFIG.c_s2mm_genlock_mode {0} CONFIG.c_mm2s_max_burst_length {16}] [get_bd_cells axi_vdma_0]
endgroup
# 4. vid_out
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_axi4s_vid_out:4.0 v_axi4s_vid_out_0
endgroup
startgroup
set_property -dict [list CONFIG.C_S_AXIS_VIDEO_FORMAT.VALUE_SRC USER CONFIG.C_S_AXIS_VIDEO_DATA_WIDTH.VALUE_SRC USER] [get_bd_cells v_axi4s_vid_out_0]
set_property -dict [list CONFIG.C_HAS_ASYNC_CLK {1} CONFIG.C_VTG_MASTER_SLAVE {1}] [get_bd_cells v_axi4s_vid_out_0]
endgroup
# 5. vtc
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:v_tc:6.1 v_tc_0
endgroup
startgroup
set_property -dict [list CONFIG.HAS_AXI4_LITE {false} CONFIG.VIDEO_MODE {Custom} CONFIG.GEN_F0_VSYNC_VSTART {250} CONFIG.GEN_HACTIVE_SIZE {320} CONFIG.GEN_HSYNC_END {340} CONFIG.GEN_HFRAME_SIZE {417} CONFIG.GEN_F0_VSYNC_HSTART {320} CONFIG.GEN_F0_VSYNC_HEND {320} CONFIG.GEN_F0_VFRAME_SIZE {263} CONFIG.GEN_F0_VSYNC_VEND {252} CONFIG.GEN_F0_VBLANK_HEND {320} CONFIG.GEN_HSYNC_START {338} CONFIG.GEN_VACTIVE_SIZE {240} CONFIG.GEN_F0_VBLANK_HSTART {320} CONFIG.enable_detection {false}] [get_bd_cells v_tc_0]
endgroup
# 6. lcd
startgroup
create_bd_cell -type ip -vlnv user.org:user:fslcd:1.0 fslcd_0
endgroup
# 7. constant 1
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
endgroup
# reset for fclock
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk0
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk1
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk2
endgroup
# 8. auto connect
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells cpu]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/cpu/M_AXI_GP0" Clk "/cpu/FCLK_CLK0 (76 MHz)" }  [get_bd_intf_pins v_osd_0/ctrl]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/cpu/M_AXI_GP0" Clk "/cpu/FCLK_CLK0 (76 MHz)" }  [get_bd_intf_pins axi_vdma_0/S_AXI_LITE]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axi_vdma_0/M_AXI_MM2S" Clk "/cpu/FCLK_CLK1 (142 MHz)" }  [get_bd_intf_pins cpu/S_AXI_HP0]
endgroup

# connect clocks
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins rst_cpu_fclk0/slowest_sync_clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins axi_vdma_0/s_axi_lite_aclk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins cpu/M_AXI_GP0_ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins cpu_axi_periph/ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins cpu_axi_periph/S00_ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins cpu_axi_periph/M00_ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins cpu_axi_periph/M01_ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK0] [get_bd_pins v_osd_0/s_axi_aclk]

connect_bd_net [get_bd_pins cpu/FCLK_RESET0_N] [get_bd_pins rst_cpu_fclk0/ext_reset_in]
connect_bd_net [get_bd_pins rst_cpu_fclk0/interconnect_aresetn] [get_bd_pins cpu_axi_periph/ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk0/peripheral_aresetn] [get_bd_pins axi_vdma_0/axi_resetn]
connect_bd_net [get_bd_pins rst_cpu_fclk0/peripheral_aresetn] [get_bd_pins cpu_axi_periph/S00_ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk0/peripheral_aresetn] [get_bd_pins cpu_axi_periph/M00_ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk0/peripheral_aresetn] [get_bd_pins cpu_axi_periph/M01_ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk0/peripheral_aresetn] [get_bd_pins v_osd_0/s_axi_aresetn]

connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins rst_cpu_fclk1/slowest_sync_clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins cpu/S_AXI_HP0_ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins axi_vdma_0/m_axi_mm2s_aclk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins axi_vdma_0/m_axis_mm2s_aclk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins axi_mem_intercon/ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins axi_mem_intercon/S00_ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins axi_mem_intercon/M00_ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins axi_mem_intercon/M01_ACLK]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins v_osd_0/aclk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK1] [get_bd_pins v_axi4s_vid_out_0/aclk]

connect_bd_net [get_bd_pins cpu/FCLK_RESET1_N] [get_bd_pins rst_cpu_fclk1/ext_reset_in]
connect_bd_net [get_bd_pins rst_cpu_fclk1/interconnect_aresetn] [get_bd_pins axi_mem_intercon/ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk1/peripheral_aresetn] [get_bd_pins axi_mem_intercon/S00_ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk1/peripheral_aresetn] [get_bd_pins axi_mem_intercon/M00_ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk1/peripheral_aresetn] [get_bd_pins axi_mem_intercon/M01_ARESETN]
connect_bd_net [get_bd_pins rst_cpu_fclk1/peripheral_aresetn] [get_bd_pins v_osd_0/aresetn]
connect_bd_net [get_bd_pins rst_cpu_fclk1/peripheral_aresetn] [get_bd_pins v_axi4s_vid_out_0/aresetn]

connect_bd_net [get_bd_pins cpu/FCLK_CLK2] [get_bd_pins rst_cpu_fclk2/slowest_sync_clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK2] [get_bd_pins v_tc_0/clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK2] [get_bd_pins v_axi4s_vid_out_0/vid_io_out_clk]
connect_bd_net [get_bd_pins cpu/FCLK_CLK2] [get_bd_pins fslcd_0/clk]
connect_bd_net [get_bd_pins cpu/FCLK_RESET2_N] [get_bd_pins rst_cpu_fclk2/ext_reset_in]
connect_bd_net [get_bd_pins rst_cpu_fclk2/peripheral_reset] [get_bd_pins v_axi4s_vid_out_0/vid_io_out_reset]
connect_bd_net [get_bd_pins rst_cpu_fclk2/peripheral_aresetn] [get_bd_pins v_tc_0/resetn]

# connect data
connect_bd_intf_net [get_bd_intf_pins cpu/M_AXI_GP0] -boundary_type upper [get_bd_intf_pins cpu_axi_periph/S00_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins cpu_axi_periph/M00_AXI] [get_bd_intf_pins axi_vdma_0/S_AXI_LITE]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins cpu_axi_periph/M01_AXI] [get_bd_intf_pins v_osd_0/ctrl]

connect_bd_intf_net [get_bd_intf_pins cpu/S_AXI_HP0] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/M00_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins axi_vdma_0/M_AXI_MM2S]
connect_bd_intf_net [get_bd_intf_pins axi_vdma_0/M_AXIS_MM2S] [get_bd_intf_pins v_osd_0/video_s0_in]
connect_bd_intf_net [get_bd_intf_pins v_osd_0/video_out] [get_bd_intf_pins v_axi4s_vid_out_0/video_in]

# maybe should optimize fslcd
connect_bd_net [get_bd_pins v_axi4s_vid_out_0/vid_active_video] [get_bd_pins fslcd_0/vid_active]
connect_bd_net [get_bd_pins v_axi4s_vid_out_0/vid_data] [get_bd_pins fslcd_0/vid_data]
connect_bd_net [get_bd_pins v_axi4s_vid_out_0/vid_hsync] [get_bd_pins fslcd_0/hsync]
connect_bd_net [get_bd_pins v_axi4s_vid_out_0/vid_vsync] [get_bd_pins fslcd_0/vsync]

connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_tc_0/clken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_tc_0/gen_clken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_osd_0/aclken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_osd_0/s_axi_aclken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_axi4s_vid_out_0/aclken]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins v_axi4s_vid_out_0/vid_io_out_ce]

connect_bd_intf_net [get_bd_intf_pins v_tc_0/vtiming_out] [get_bd_intf_pins v_axi4s_vid_out_0/vtiming_in]

# output
startgroup
create_bd_port -dir O lcd_clk
connect_bd_net [get_bd_pins /fslcd_0/clk_out] [get_bd_ports lcd_clk]
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
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {cpu/S_AXI_HP0/HP0_DDR_LOWOCM }]
set_property -dict [list offset {0x43000000} range {64K}] [get_bd_addr_segs {axi_vdma_0/S_AXI_LITE/Reg }]
set_property -dict [list offset {0x43C10000} range {64K}] [get_bd_addr_segs {cpu/Data/SEG_v_osd_0_Reg}]

save_bd_design
