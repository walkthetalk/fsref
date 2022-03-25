# 0. global config
set cfg_tm043 [dict create \
	lcd_clk_freqmhz 9 \
	lcd_max_clocks_per_line 1024 \
	lcd_max_lines_per_frame 512 \
	lcd_hactive_size 480 \
	lcd_hframe_size 525 \
	lcd_hsync_start 482 \
	lcd_hsync_end 523 \
	lcd_vactive_size 272 \
	lcd_f0_vframe_size 286 \
	lcd_f0_vsync_start 274 \
	lcd_f0_vsync_end 284 \
	lcd_f0_vsync_hstart 485 \
	lcd_f0_vsync_hend 520 \
	lcd_f0_vblank_hstart 485 \
	lcd_f0_vblank_hend 520 \
	lcd_fsync_hstart0 480 \
	lcd_fsync_vstart0 272 \
	lcd_hsync_polarity Low \
	lcd_vsync_polarity Low \
]
set cfg_tm050 [dict create \
	lcd_clk_freqmhz 30 \
	lcd_max_clocks_per_line 1024 \
	lcd_max_lines_per_frame 1024 \
	lcd_hactive_size 800 \
	lcd_hframe_size 928 \
	lcd_hsync_start 840 \
	lcd_hsync_end 888 \
	lcd_vactive_size 480 \
	lcd_f0_vframe_size 525 \
	lcd_f0_vsync_start 493 \
	lcd_f0_vsync_end 496 \
	lcd_f0_vsync_hstart 848 \
	lcd_f0_vsync_hend 880 \
	lcd_f0_vblank_hstart 848 \
	lcd_f0_vblank_hend 880 \
	lcd_fsync_hstart0 800 \
	lcd_fsync_vstart0 480 \
	lcd_hsync_polarity Low \
	lcd_vsync_polarity Low \
]

set cfg_common [dict create \
	stream_pixel_width 8 \
	stream_w_width 12 \
	stream_h_width 12 \
	vdma_addr_width 32 \
	vdma_data_width 64 \
	vdma_burst_length 16 \
	vdma_fifo_depth 128 \
	vdma_timestamp_width 64 \
	vdma_stride_size 1024 \
	stream_bypass_bayer_extractor 0 \
	motor_num 6 \
	motor_step_width 32 \
	motor_speed_width 32 \
	motor_br_addr_width 12 \
	motor_ms_width 3 \
	pwm_num 8 \
]

set dic [dict merge \
	$cfg_tm050 \
	$cfg_common \
]

# 1. cpu
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 cpu

# @note: if using hp as 32bit, you should set the cpu register in software
# @note: frame sync should be center of interspace between frames to adapting
#        different window control

set_property -dict [list \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_EN_CLK1_PORT {1} \
    CONFIG.PCW_EN_CLK2_PORT {1} \
    CONFIG.PCW_EN_CLK3_PORT {1} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {75} \
    CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {150} \
    CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ [dict get $dic lcd_clk_freqmhz] \
    CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {24} \
    CONFIG.PCW_EN_RST0_PORT {1} \
    CONFIG.PCW_EN_RST1_PORT {1} \
    CONFIG.PCW_EN_RST2_PORT {1} \
    CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
    CONFIG.PCW_IRQ_F2P_INTR {1} \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
    CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
    CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
    CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
    CONFIG.PCW_ENET0_RESET_ENABLE {1} \
    CONFIG.PCW_ENET0_RESET_IO {MIO 7} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
    CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
    CONFIG.PCW_SD0_GRP_CD_IO {MIO 10} \
    CONFIG.PCW_SD1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SD1_SD1_IO {MIO 46 .. 51} \
    CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
    CONFIG.PCW_USB_RESET_ENABLE {1} \
    CONFIG.PCW_USB0_RESET_ENABLE {1} \
    CONFIG.PCW_USB0_RESET_IO {MIO 8} \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
    CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} \
    CONFIG.PCW_USE_S_AXI_HP1 {1} \
    CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
    CONFIG.PCW_USE_S_AXI_HP2 {1} \
    CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
    CONFIG.PCW_USE_S_AXI_HP3 {1} \
    CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64}] [get_bd_cells cpu]

# interconnection for control
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ic_ctl
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1}] [get_bd_cells ic_ctl]

# 4. vid_out
create_bd_cell -type ip -vlnv xilinx.com:ip:v_axi4s_vid_out:4.0 videoout
# @note: use mast mode, don't allow auto adjust phase between in/out
set_property -dict [list \
    CONFIG.C_S_AXIS_VIDEO_FORMAT.VALUE_SRC USER \
    CONFIG.C_S_AXIS_VIDEO_DATA_WIDTH.VALUE_SRC USER \
    CONFIG.C_HAS_ASYNC_CLK {1} \
    CONFIG.C_VTG_MASTER_SLAVE {1} \
] [get_bd_cells videoout]
# 5. vtc
# @note blank generation must be true, axis2videoout need it
create_bd_cell -type ip -vlnv xilinx.com:ip:v_tc:6.2 vtc
set_property -dict [list \
    CONFIG.max_clocks_per_line [dict get $dic lcd_max_clocks_per_line] \
    CONFIG.max_lines_per_frame [dict get $dic lcd_max_lines_per_frame] \
    CONFIG.HAS_AXI4_LITE {false} \
    CONFIG.HAS_INTC_IF {false} \
    CONFIG.vertical_blank_generation {true} \
    CONFIG.horizontal_blank_generation {true} \
    CONFIG.VIDEO_MODE {Custom} \
    CONFIG.GEN_HACTIVE_SIZE [dict get $dic lcd_hactive_size] \
    CONFIG.GEN_HFRAME_SIZE [dict get $dic lcd_hframe_size] \
    CONFIG.GEN_HSYNC_START [dict get $dic lcd_hsync_start] \
    CONFIG.GEN_HSYNC_END [dict get $dic lcd_hsync_end] \
    CONFIG.GEN_VACTIVE_SIZE [dict get $dic lcd_vactive_size] \
    CONFIG.GEN_F0_VFRAME_SIZE [dict get $dic lcd_f0_vframe_size] \
    CONFIG.GEN_F0_VSYNC_VSTART [dict get $dic lcd_f0_vsync_start] \
    CONFIG.GEN_F0_VSYNC_VEND [dict get $dic lcd_f0_vsync_end] \
    CONFIG.FSYNC_HSTART0 [dict get $dic lcd_fsync_hstart0] \
    CONFIG.FSYNC_VSTART0 [dict get $dic lcd_fsync_vstart0] \
    CONFIG.GEN_F0_VSYNC_HSTART [dict get $dic lcd_f0_vsync_hstart] \
    CONFIG.GEN_F0_VSYNC_HEND [dict get $dic lcd_f0_vsync_hend] \
    CONFIG.GEN_F0_VBLANK_HSTART [dict get $dic lcd_f0_vblank_hstart] \
    CONFIG.GEN_F0_VBLANK_HEND [dict get $dic lcd_f0_vblank_hend] \
    CONFIG.GEN_HSYNC_POLARITY [dict get $dic lcd_hsync_polarity] \
    CONFIG.GEN_VSYNC_POLARITY [dict get $dic lcd_vsync_polarity] \
    CONFIG.enable_detection {false} \
] [get_bd_cells vtc]
# 6. lcd
create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fslcd:$VERSION fslcd
set_property -dict [list \
    CONFIG.C_IN_COMP_WIDTH {8} \
    CONFIG.C_OUT_COMP_WIDTH {8} \
] [get_bd_cells fslcd]

# 7. cmos
create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fscmos:$VERSION fscmos_0
set_property -dict [list \
    CONFIG.C_IN_WIDTH {8} \
    CONFIG.C_OUT_WIDTH {8} \
    ] [get_bd_cells fscmos_0]
copy_bd_objs /  [get_bd_cells {fscmos_0}]

create_bd_cell -type ip -vlnv xilinx.com:ip:v_vid_in_axi4s:5.0 videoin_0
set_property -dict [list \
    CONFIG.C_PIXELS_PER_CLOCK {1} \
    CONFIG.C_M_AXIS_VIDEO_FORMAT {12} \
    CONFIG.C_M_AXIS_VIDEO_DATA_WIDTH {8} \
    CONFIG.C_NATIVE_COMPONENT_WIDTH {8} \
    CONFIG.C_HAS_ASYNC_CLK {1}] [get_bd_cells videoin_0]
copy_bd_objs /  [get_bd_cells videoin_0]

# 8. fsmotor
create_bd_cell -type ip -vlnv $VENDOR:$LIBRARY:fsmotor:$VERSION fsmotor
set_property -dict [list \
    CONFIG.C_INVERT_DIR {1} \
    ] [get_bd_cells fsmotor]

# X. fusion splicer core
create_fscore_v2 /fscore $dic

# Y. xadc
create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.3 xadc
set_property -dict [list \
    CONFIG.INTERFACE_SELECTION {None} \
    CONFIG.XADC_STARUP_SELECTION {channel_sequencer} \
    CONFIG.ENABLE_AXI4STREAM {false} \
    CONFIG.ENABLE_DCLK {false} \
    CONFIG.ENABLE_CALIBRATION_AVERAGING {true} \
    CONFIG.ENABLE_RESET {false} \
    CONFIG.OT_ALARM {false} \
    CONFIG.USER_TEMP_ALARM {false} \
    CONFIG.VCCINT_ALARM {false} \
    CONFIG.VCCAUX_ALARM {false} \
    CONFIG.ENABLE_VBRAM_ALARM {false} \
    CONFIG.ENABLE_VCCPINT_ALARM {false} \
    CONFIG.ENABLE_VCCPAUX_ALARM {false} \
    CONFIG.ENABLE_VCCDDRO_ALARM {false} \
    CONFIG.CHANNEL_AVERAGING {None} \
    CONFIG.CHANNEL_ENABLE_VP_VN {false} \
    CONFIG.CHANNEL_ENABLE_VREFP {false} \
    CONFIG.CHANNEL_ENABLE_VREFN {false} \
    CONFIG.CHANNEL_ENABLE_VAUXP0_VAUXN0 {true} \
    CONFIG.CHANNEL_ENABLE_VAUXP1_VAUXN1 {true} \
    CONFIG.ENABLE_JTAG_ARBITER {false} \
    CONFIG.SEQUENCER_MODE {Continuous} \
    CONFIG.ENABLE_DRP {false} \
    CONFIG.EXTERNAL_MUX_CHANNEL {VP_VN} \
    CONFIG.SINGLE_CHANNEL_SELECTION \
    {TEMPERATURE}\
] [get_bd_cells xadc]


# interconnection of data
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ic_data_0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1}] [get_bd_cells ic_data_0]
copy_bd_objs /  [get_bd_cells ic_data_0]
copy_bd_objs /  [get_bd_cells ic_data_1]

# 7. constant 1
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
set_property -dict [list CONFIG.CONST_WIDTH {1} CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1
set_property -dict [list CONFIG.CONST_WIDTH {1} CONFIG.CONST_VAL {1}] [get_bd_cells xlconstant_1]
# 8. reset for fclock
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk0
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk1
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_cpu_fclk2
# fclk3 is only used for output, do not need reset

# auto connect
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells cpu]

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
}

pip_connect_pin fscore/s0_in_resetn {
	videoin_0/aresetn
}

pip_connect_pin fscore/s1_in_resetn {
	videoin_1/aresetn
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
pip_connect_pin fscore/st_out_resetn videoout/aresetn

# connect data

# connect interface
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
        fscore/PUSH_MOTOR0_IC_CTL   fsmotor/S0
        fscore/PUSH_MOTOR1_IC_CTL   fsmotor/S1
        fscore/ALIGN_MOTOR0_IC_CTL  fsmotor/S2
        fscore/ALIGN_MOTOR1_IC_CTL  fsmotor/S3
        fscore/ROTATE_MOTOR0_IC_CTL fsmotor/S4
        fscore/ROTATE_MOTOR1_IC_CTL fsmotor/S5
}

# connect signal
pip_connect_net [subst {
	vtc/fsync_out             fscore/fsync
}]

pip_connect_pin xlconstant_1/dout {
	vtc/clken
	vtc/gen_clken
	videoin_*/aclken
	videoin_*/axis_enable
	videoin_*/vid_io_in_ce
	videoout/aclken
	videoout/vid_io_out_ce
}

# external osc clock 50MHZ
create_bd_port -dir I -type clk -freq_hz 50000000 osc_clk

# connect from/to external cmos
create_bd_port -dir O cmos0_resetn
pip_connect_pin xlconstant_1/dout { cmos0_resetn }
create_bd_port -dir O -type ce cmos0_pwdn
pip_connect_pin xlconstant_0/dout { cmos0_pwdn }
create_bd_port -type clk -dir O cmos0_xclk
connect_bd_net [get_bd_pins cpu/FCLK_CLK3] [get_bd_ports cmos0_xclk]
create_bd_port -dir I cmos0_pclk
connect_bd_net [get_bd_pins /fscmos_0/cmos_pclk]      [get_bd_ports cmos0_pclk]
connect_bd_net [get_bd_pins /videoin_0/vid_io_in_clk] [get_bd_ports cmos0_pclk]
create_bd_port -dir I cmos0_href
connect_bd_net [get_bd_pins /fscmos_0/cmos_href] [get_bd_ports cmos0_href]
create_bd_port -dir I cmos0_vsync
connect_bd_net [get_bd_pins /fscmos_0/cmos_vsync] [get_bd_ports cmos0_vsync]
create_bd_port -dir I -from 7 -to 0 cmos0_data
connect_bd_net [get_bd_pins /fscmos_0/cmos_data] [get_bd_ports cmos0_data]

# @note use same resetn/powerdown/xclk with cmos0
create_bd_port -dir O cmos1_resetn
pip_connect_pin xlconstant_1/dout { cmos1_resetn }
create_bd_port -dir O -type ce cmos1_pwdn
pip_connect_pin xlconstant_0/dout { cmos1_pwdn }
create_bd_port -type clk -dir O cmos1_xclk
connect_bd_net [get_bd_pins cpu/FCLK_CLK3] [get_bd_ports cmos1_xclk]
create_bd_port -dir I cmos1_pclk
connect_bd_net [get_bd_pins /fscmos_1/cmos_pclk]      [get_bd_ports cmos1_pclk]
connect_bd_net [get_bd_pins /videoin_1/vid_io_in_clk] [get_bd_ports cmos1_pclk]
create_bd_port -dir I cmos1_href
connect_bd_net [get_bd_pins /fscmos_1/cmos_href] [get_bd_ports cmos1_href]
create_bd_port -dir I cmos1_vsync
connect_bd_net [get_bd_pins /fscmos_1/cmos_vsync] [get_bd_ports cmos1_vsync]
create_bd_port -dir I -from 7 -to 0 cmos1_data
connect_bd_net [get_bd_pins /fscmos_1/cmos_data] [get_bd_ports cmos1_data]

# cmos i2c
set_property -dict [list \
    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {1} \
    ] [get_bd_cells cpu]
make_bd_intf_pins_external -name cmos0_i2c [get_bd_intf_pins cpu/IIC_0]
make_bd_intf_pins_external -name cmos1_i2c [get_bd_intf_pins cpu/IIC_1]

# connect from/to external lcd
create_bd_port -dir O lcd_reset
connect_bd_net [get_bd_ports lcd_reset] [get_bd_pins xlconstant_1/dout]
create_bd_port -dir O lcd_power
connect_bd_net [get_bd_ports lcd_power] [get_bd_pins xlconstant_1/dout]

create_bd_port -dir O lcd_clk
connect_bd_net [get_bd_pins fslcd/out_clk] [get_bd_ports lcd_clk]
create_bd_port -dir O -from 7 -to 0 lcd_R
connect_bd_net [get_bd_pins /fslcd/r] [get_bd_ports lcd_R]
create_bd_port -dir O -from 7 -to 0 lcd_G
connect_bd_net [get_bd_pins /fslcd/g] [get_bd_ports lcd_G]
create_bd_port -dir O -from 7 -to 0 lcd_B
connect_bd_net [get_bd_pins /fslcd/b] [get_bd_ports lcd_B]

create_bd_port -dir O lcd_hsync
connect_bd_net [get_bd_pins /fslcd/hsync_out] [get_bd_ports lcd_hsync]
create_bd_port -dir O lcd_vsync
connect_bd_net [get_bd_pins /fslcd/vsync_out] [get_bd_ports lcd_vsync]
create_bd_port -dir O lcd_de
connect_bd_net [get_bd_pins /fslcd/active_data] [get_bd_ports lcd_de]
create_bd_port -dir O lcd_lum
connect_bd_net [get_bd_pins /fscore/lcd_lum] [get_bd_ports lcd_lum]

# connect from/to external motor ic
create_bd_port -dir O -from 2 -to 0 pm_ms
create_bd_port -dir I pm0_zpd
create_bd_port -dir I pm1_zpd
create_bd_port -dir O pm0_xen
create_bd_port -dir O pm0_xrst
create_bd_port -dir O pm0_drive
create_bd_port -dir O pm0_dir
create_bd_port -dir O pm1_xen
create_bd_port -dir O pm1_xrst
create_bd_port -dir O pm1_drive
create_bd_port -dir O pm1_dir
create_bd_port -dir O -from 2 -to 0 am_ms
create_bd_port -dir O am0_xen
create_bd_port -dir O am0_xrst
create_bd_port -dir O am0_drive
create_bd_port -dir O am0_dir
create_bd_port -dir O am1_xen
create_bd_port -dir O am1_xrst
create_bd_port -dir O am1_drive
create_bd_port -dir O am1_dir
create_bd_port -dir O -from 2 -to 0 rm_ms
create_bd_port -dir I rm0_zpd
create_bd_port -dir I rm1_zpd
create_bd_port -dir O rm0_xen
create_bd_port -dir O rm0_xrst
create_bd_port -dir O rm0_drive
create_bd_port -dir O rm0_dir
create_bd_port -dir O rm1_xen
create_bd_port -dir O rm1_xrst
create_bd_port -dir O rm1_drive
create_bd_port -dir O rm1_dir
foreach i {pm0_zpd pm1_zpd rm0_zpd rm1_zpd
	pm_ms pm0_xen pm0_xrst pm0_drive pm0_dir pm1_xen pm1_xrst pm1_drive pm1_dir
	am_ms am0_xen am0_xrst am0_drive am0_dir am1_xen am1_xrst am1_drive am1_dir
	rm_ms rm0_xen rm0_xrst rm0_drive rm0_dir rm1_xen rm1_xrst rm1_drive rm1_dir} {
        connect_bd_net [get_bd_pins /fsmotor/$i] [get_bd_ports $i]
}

create_bd_port -dir O pm_decay
create_bd_port -dir O am_decay
create_bd_port -dir O rm_decay
connect_bd_net [get_bd_ports pm_decay] [get_bd_pins xlconstant_1/dout]
connect_bd_net [get_bd_ports am_decay] [get_bd_pins xlconstant_1/dout]
connect_bd_net [get_bd_ports rm_decay] [get_bd_pins xlconstant_1/dout]


# connect from/to external cmoslight
create_bd_port -dir O cmos0_light
create_bd_port -dir O cmos1_light
foreach i {cmos0_light cmos1_light} {
        connect_bd_net [get_bd_pins /fscore/$i] [get_bd_ports $i]
}

# connect from/to external discharge
create_bd_port -dir O discharge_resetn
connect_bd_net [get_bd_ports discharge_resetn] [get_bd_pins fscore/discharge_resetn]
#create_bd_port -dir O discharge_drive
#connect_bd_net [get_bd_ports discharge_drive] [get_bd_pins fscore/discharge_drive]
create_bd_port -dir O discharge_power
connect_bd_net [get_bd_ports discharge_power] [get_bd_pins fscore/discharge_power]
create_bd_port -dir O fan_en
connect_bd_net [get_bd_ports fan_en] [get_bd_pins fscore/fan_en]
create_bd_port -dir O heater_power
connect_bd_net [get_bd_ports heater_power] [get_bd_pins fscore/heater_power]
create_bd_port -dir O buzz_en
connect_bd_net [get_bd_ports buzz_en] [get_bd_pins fscore/beeper_en]
create_bd_port -dir O heater_en
connect_bd_net [get_bd_ports heater_en] [get_bd_pins fscore/heater_en]

# connect from external keyboard
set_property -dict [list \
	CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
	CONFIG.PCW_GPIO_EMIO_GPIO_IO {16}] [get_bd_cells cpu]
make_bd_intf_pins_external -name gpio_key [get_bd_intf_pins cpu/GPIO_0]

# connect xadc
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 power_volt
connect_bd_intf_net [get_bd_intf_ports power_volt] [get_bd_intf_pins xadc/Vaux0]
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 heater_temp
connect_bd_intf_net [get_bd_intf_ports heater_temp] [get_bd_intf_pins xadc/Vaux1]

# NOTE: pcb is not connect xx_N, so we connect it to low level directly
# pip_connect_pin xlconstant_0/dout {
#	xadc/vauxn0
#	xadc/vauxn1
# }

# connect interrupt
connect_bd_net [get_bd_pins fscore/intr] [get_bd_pins cpu/IRQ_F2P]
create_bd_port -dir I fs_cover
create_bd_port -dir I heat_cover
connect_bd_net [get_bd_ports fs_cover] [get_bd_pins fscore/FS_COVER]
connect_bd_net [get_bd_ports heat_cover] [get_bd_pins fscore/HEAT_COVER]

# 9. address
# auto assign all addresses
assign_bd_address
set_property -dict [list offset {0x43C00000} range {64K}] [get_bd_addr_segs {cpu/Data/SEG_axilite2regctl_S_AXI_LITE_reg}]

set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/pvdma_T/mm2s/M_AXI_REG/SEG_cpu_HP0_DDR_LOWOCM}]

set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/stream0/pvdma/mm2s/M_AXI_REG/SEG_axi_combiner_Reg}]
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/stream0/pvdma/s2mm/M_AXI_REG/SEG_axi_combiner_Reg}]
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/stream0/pvdma/axi_combiner/M_AXI_REG/SEG_cpu_HP1_DDR_LOWOCM}]

set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/stream1/pvdma/mm2s/M_AXI_REG/SEG_axi_combiner_Reg}]
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/stream1/pvdma/s2mm/M_AXI_REG/SEG_axi_combiner_Reg}]
set_property -dict [list offset {0x00000000} range {1G}] [get_bd_addr_segs {fscore/stream1/pvdma/axi_combiner/M_AXI_REG/SEG_cpu_HP2_DDR_LOWOCM}]

# modify for alinx board: light lcd by default
set_property -dict [list CONFIG.C_DEFAULT_VALUE {1}] [get_bd_cells fscore/pwm2]

# modify for fsref
set_property -dict [list CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_IO {MIO 9}] [get_bd_cells cpu]
