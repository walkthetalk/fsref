set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y9} [get_ports osc_clk]

# lcd
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y6} [get_ports lcd_reset]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN AB21} [get_ports lcd_power]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y5} [get_ports lcd_lum]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y8} [get_ports lcd_clk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U7} [get_ports lcd_hsync]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W7} [get_ports lcd_vsync]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V7} [get_ports lcd_de]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN  M15} [get_ports {lcd_B[7]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN  M16} [get_ports {lcd_B[6]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN  V12} [get_ports {lcd_B[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN  W12} [get_ports {lcd_B[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN AB20} [get_ports {lcd_B[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN AB19} [get_ports {lcd_B[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN  V10} [get_ports {lcd_B[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN  V9 } [get_ports {lcd_B[0]}]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W21} [get_ports {lcd_G[7]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W20} [get_ports {lcd_G[6]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W22} [get_ports {lcd_G[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V22} [get_ports {lcd_G[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U22} [get_ports {lcd_G[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN T22} [get_ports {lcd_G[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U11} [get_ports {lcd_G[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U12} [get_ports {lcd_G[0]}]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U14} [get_ports {lcd_R[7]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN R15} [get_ports {lcd_R[6]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U10} [get_ports {lcd_R[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U9 } [get_ports {lcd_R[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN R6 } [get_ports {lcd_R[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN T6 } [get_ports {lcd_R[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U6 } [get_ports {lcd_R[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U5 } [get_ports {lcd_R[0]}]

# cmos0
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN H18} [get_ports cmos0_resetn]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K21} [get_ports cmos0_pwdn]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN F22} [get_ports cmos0_xclk]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN B22} [get_ports {cmos0_light}]
set_property -dict {IOSTANDARD LVCMOS33 PULLUP true PACKAGE_PIN N19} [get_ports {cmos0_i2c_sda_io}]
set_property -dict {IOSTANDARD LVCMOS33 PULLUP true PACKAGE_PIN N20} [get_ports {cmos0_i2c_scl_io}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cmos0_pclk_IBUF]
create_clock -period 10.000 -name cmos0_pclk -waveform {0.000 5.000} [get_ports cmos0_pclk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y18} [get_ports cmos0_pclk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN T4 } [get_ports cmos0_vsync]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U4 } [get_ports cmos0_href]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN AA6} [get_ports {cmos0_data[7]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN AA7} [get_ports {cmos0_data[6]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W8 } [get_ports {cmos0_data[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V8 } [get_ports {cmos0_data[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W10} [get_ports {cmos0_data[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y10} [get_ports {cmos0_data[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W11} [get_ports {cmos0_data[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y11} [get_ports {cmos0_data[0]}]

# cmos1
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN /**/} [get_ports cmos1_resetn]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN /**/} [get_ports cmos1_pwdn]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN /**/} [get_ports cmos1_xclk]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN B21} [get_ports {cmos1_light}]
set_property -dict {IOSTANDARD LVCMOS33 PULLUP true PACKAGE_PIN R20} [get_ports cmos1_i2c_sda_io]
set_property -dict {IOSTANDARD LVCMOS33 PULLUP true PACKAGE_PIN R21} [get_ports cmos1_i2c_scl_io]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cmos1_pclk_IBUF]
create_clock -period 10.000 -name cmos1_pclk -waveform {0.000 5.000} [get_ports cmos1_pclk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W17} [get_ports cmos1_pclk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN F21} [get_ports cmos1_vsync]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G21} [get_ports cmos1_href]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J20} [get_ports {cmos1_data[7]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN H19} [get_ports {cmos1_data[6]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN H20} [get_ports {cmos1_data[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G19} [get_ports {cmos1_data[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J22} [get_ports {cmos1_data[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN F19} [get_ports {cmos1_data[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G20} [get_ports {cmos1_data[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J21} [get_ports {cmos1_data[0]}]

# motor
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN P20} [get_ports {pm_ms[2]}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN N20} [get_ports {pm_ms[1]}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U19} [get_ports {pm_ms[0]}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W15} [get_ports {pm_xen}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN T11} [get_ports {pm0_zpd}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U18} [get_ports {pm0_drive}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V15} [get_ports {pm0_dir}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G14} [get_ports {pm1_zpd}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN P16} [get_ports {pm1_drive}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN P15} [get_ports {pm1_dir}]

#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W19} [get_ports {am_ms[2]}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W18} [get_ports {am_ms[1]}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN R18} [get_ports {am_ms[0]}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W16} [get_ports {am_xen}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W20} [get_ports {am0_drive}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V20} [get_ports {am0_dir}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN T17} [get_ports {am1_drive}]
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V16} [get_ports {am1_dir}]

# clock
set_clock_groups -asynchronous -group [get_clocks {clk_fpga_0 clk_fpga_1}]
set_clock_groups -asynchronous -group [get_clocks {clk_fpga_2 clk_fpga_1}]


####################### temporarily
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
