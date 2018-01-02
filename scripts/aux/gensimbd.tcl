startgroup
delete_bd_objs [get_bd_intf_nets S00_AXI_3] [get_bd_intf_nets cpu_M_AXI_GP0] [get_bd_intf_nets ic_ctl_M00_AXI] [get_bd_intf_nets S00_AXI_1] [get_bd_intf_nets S00_AXI_2] [get_bd_nets rst_cpu_fclk1_interconnect_aresetn] [get_bd_intf_nets ic_data_2_M00_AXI] [get_bd_intf_nets ic_data_0_M00_AXI] [get_bd_intf_nets ic_data_1_M00_AXI] [get_bd_cells ic_data_2] [get_bd_cells ic_ctl] [get_bd_cells ic_data_0] [get_bd_cells ic_data_1]
delete_bd_objs [get_bd_intf_nets videoin_0_video_out] [get_bd_intf_nets fscmos_0_vid_io_out] [get_bd_intf_nets videoin_1_video_out] [get_bd_intf_nets fscmos_1_vid_io_out] [get_bd_intf_nets fscore_PUSH_MOTOR0_IC_CTL] [get_bd_intf_nets fscore_PUSH_MOTOR1_IC_CTL] [get_bd_intf_nets fscore_ALIGN_MOTOR0_IC_CTL] [get_bd_intf_nets fscore_ALIGN_MOTOR1_IC_CTL] [get_bd_nets cpu_FCLK_RESET1_N] [get_bd_nets fscmos_0_vid_io_out_clk] [get_bd_nets rst_cpu_fclk2_peripheral_reset] [get_bd_nets fscmos_1_vid_io_out_clk] [get_bd_nets cpu_FCLK_CLK0] [get_bd_nets rst_cpu_fclk0_interconnect_aresetn] [get_bd_nets cpu_FCLK_RESET2_N] [get_bd_nets rst_cpu_fclk2_peripheral_aresetn] [get_bd_nets fsmotor_pm0_dir] [get_bd_nets cmos0_data_1] [get_bd_nets cmos0_pclk_1] [get_bd_nets cmos1_pclk_1] [get_bd_nets cmos0_vsync_1] [get_bd_nets cmos0_href_1] [get_bd_nets fsmotor_pm_xen] [get_bd_nets cmos1_vsync_1] [get_bd_nets cmos1_href_1] [get_bd_nets cmos1_data_1] [get_bd_nets fsmotor_pm_ms] [get_bd_nets pm0_zpd_1] [get_bd_nets pm1_zpd_1] [get_bd_nets fsmotor_pm1_dir] [get_bd_nets fsmotor_am_ms] [get_bd_nets fsmotor_am0_drive] [get_bd_nets fsmotor_am1_dir] [get_bd_nets fscore_intr] [get_bd_nets fsmotor_am0_dir] [get_bd_nets fsmotor_am1_drive] [get_bd_nets fsmotor_am_xen] [get_bd_nets fsmotor_pm1_drive] [get_bd_nets fsmotor_pm0_drive] [get_bd_nets cpu_FCLK_RESET0_N] [get_bd_intf_nets cpu_DDR] [get_bd_intf_nets cpu_FIXED_IO] [get_bd_cells videoin_0] [get_bd_cells videoin_1] [get_bd_cells fscmos_0] [get_bd_cells rst_cpu_fclk0] [get_bd_cells rst_cpu_fclk1] [get_bd_cells rst_cpu_fclk2] [get_bd_cells fsmotor] [get_bd_cells cpu] [get_bd_cells fscmos_1]
delete_bd_objs [get_bd_nets fscore_cmos1_light] [get_bd_nets fscore_cmos0_light] [get_bd_nets cpu_FCLK_CLK3] [get_bd_ports cmos0_data] [get_bd_ports pm_xen] [get_bd_ports cmos1_data] [get_bd_ports lcd_clk] [get_bd_ports cmos1_light] [get_bd_ports cmos0_light] [get_bd_ports cmos1_href] [get_bd_ports am_ms] [get_bd_ports cmos1_xclk] [get_bd_ports cmos0_href] [get_bd_ports pm1_dir] [get_bd_ports pm_ms] [get_bd_ports cmos0_vsync] [get_bd_ports am1_dir] [get_bd_ports pm1_drive] [get_bd_ports cmos1_pclk] [get_bd_ports cmos1_vsync] [get_bd_ports pm0_dir] [get_bd_ports cmos0_xclk] [get_bd_ports am1_drive] [get_bd_ports am0_drive] [get_bd_ports pm0_zpd] [get_bd_ports am0_dir] [get_bd_ports am_xen] [get_bd_ports cmos0_pclk] [get_bd_ports pm1_zpd] [get_bd_ports pm0_drive]
delete_bd_objs [get_bd_intf_ports DDR] [get_bd_intf_ports FIXED_IO]
endgroup

# create clk/resetn
create_bd_port -dir I -type clk clk
create_bd_port -dir I -type rst resetn
connect_bd_net [get_bd_ports clk] [get_bd_pins fscore/clk]
connect_bd_net [get_bd_ports resetn] [get_bd_pins fscore/resetn]

create_bd_port -dir I -type clk clk_lcd
create_bd_port -dir I -type rst resetn_lcd
connect_bd_net [get_bd_ports clk_lcd] [get_bd_pins vtc/clk]
connect_bd_net [get_bd_ports resetn_lcd] [get_bd_pins vtc/resetn]
create_bd_port -dir I -type rst reset_lcd
set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports /reset_lcd]
connect_bd_net [get_bd_ports reset_lcd] [get_bd_pins videoout/vid_io_out_reset]

create_bd_port -dir I -type clk clk_reg
create_bd_port -dir I -type rst resetn_reg
connect_bd_net [get_bd_ports clk_reg] [get_bd_pins fscore/s_axi_clk]
connect_bd_net [get_bd_ports resetn_reg] [get_bd_pins fscore/s_axi_resetn]

# delete from fscore
startgroup
delete_bd_objs [get_bd_intf_nets fscore/S_AXI_LITE_1] [get_bd_intf_nets fscore/S0_AXIS_1] [get_bd_intf_nets fscore/push_motor_M1] [get_bd_intf_nets fscore/align_motor_M1] [get_bd_intf_nets fscore/align_motor_M0] [get_bd_intf_nets fscore/push_motor_M0] [get_bd_intf_nets fscore/S1_AXIS_1] [get_bd_intf_pins fscore/S0_AXIS] [get_bd_intf_pins fscore/PUSH_MOTOR1_IC_CTL] [get_bd_intf_pins fscore/ALIGN_MOTOR1_IC_CTL] [get_bd_intf_pins fscore/ALIGN_MOTOR0_IC_CTL] [get_bd_intf_pins fscore/PUSH_MOTOR0_IC_CTL] [get_bd_intf_pins fscore/S1_AXIS] [get_bd_intf_pins fscore/S_AXI_LITE]
delete_bd_objs [get_bd_intf_nets fscore/axilite2regctl_M_REG_CTL] [get_bd_intf_nets fscore/axis_reshaper_0_M_AXIS] [get_bd_intf_nets fscore/axis_bayer_extractor_0_M_AXIS] [get_bd_intf_nets fscore/axis_reshaper_1_M_AXIS] [get_bd_intf_nets fscore/axis_bayer_extractor_1_M_AXIS] [get_bd_intf_nets fscore/fsctl_BR0_INIT_CTL] [get_bd_intf_nets fscore/fsctl_MOTOR0_CTL] [get_bd_intf_nets fscore/fsctl_MOTOR1_CTL] [get_bd_intf_nets fscore/fsctl_PWM0_CTL] [get_bd_intf_nets fscore/fsctl_BR1_INIT_CTL] [get_bd_intf_nets fscore/fsctl_MOTOR2_CTL] [get_bd_intf_nets fscore/fsctl_MOTOR3_CTL] [get_bd_intf_nets fscore/fsctl_PWM1_CTL] [get_bd_nets fscore/pwm0_drive] [get_bd_nets fscore/pwm1_drive] [get_bd_cells fscore/axilite2regctl] [get_bd_cells fscore/push_motor] [get_bd_cells fscore/axis_bayer_extractor_0] [get_bd_cells fscore/pwm0] [get_bd_cells fscore/align_motor] [get_bd_cells fscore/axis_bayer_extractor_1] [get_bd_cells fscore/pwm1] [get_bd_cells fscore/axis_reshaper_0] [get_bd_cells fscore/axis_reshaper_1]
delete_bd_objs [get_bd_pins fscore/cmos0_light] [get_bd_pins fscore/cmos1_light]
endgroup

create_bd_intf_pin -mode Slave -vlnv ocfb:interface:reg_ctl_rtl:1.0 fscore/S_REG_CTL
connect_bd_intf_net [get_bd_intf_pins fscore/S_REG_CTL] [get_bd_intf_pins fscore/fsctl/S_REG_CTL]
create_bd_intf_port -mode Slave -vlnv ocfb:interface:reg_ctl_rtl:1.0 S_REG_CTL
connect_bd_intf_net [get_bd_intf_ports S_REG_CTL] -boundary_type upper [get_bd_intf_pins fscore/S_REG_CTL]

# block ram
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0
set_property -dict [list CONFIG.DATA_WIDTH {64} CONFIG.ECC_TYPE {0} CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells axi_bram_ctrl_0]
endgroup
copy_bd_objs /  [get_bd_cells {axi_bram_ctrl_0}]
copy_bd_objs /  [get_bd_cells {axi_bram_ctrl_0}]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins fscore/M0_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins fscore/M1_AXI] [get_bd_intf_pins axi_bram_ctrl_1/S_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins fscore/M2_AXI] [get_bd_intf_pins axi_bram_ctrl_2/S_AXI]

connect_bd_net [get_bd_ports clk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
connect_bd_net [get_bd_ports clk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk]
connect_bd_net [get_bd_ports clk] [get_bd_pins axi_bram_ctrl_2/s_axi_aclk]