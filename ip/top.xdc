
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J20} [get_ports lcd_clk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN E17} [get_ports {lcd_ctrl[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN B20} [get_ports {lcd_ctrl[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN C20} [get_ports {lcd_ctrl[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN D18} [get_ports {lcd_ctrl[0]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN H20} [get_ports lcd_hsync]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN H15} [get_ports lcd_vsync]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN E18} [get_ports {lcd_B[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN E19} [get_ports {lcd_B[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN L19} [get_ports {lcd_B[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN L20} [get_ports {lcd_B[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN M17} [get_ports {lcd_B[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN M18} [get_ports {lcd_B[0]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN L16} [get_ports {lcd_G[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN L17} [get_ports {lcd_G[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN H16} [get_ports {lcd_G[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN H17} [get_ports {lcd_G[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G17} [get_ports {lcd_G[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G18} [get_ports {lcd_G[0]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G19} [get_ports {lcd_R[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G20} [get_ports {lcd_R[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K14} [get_ports {lcd_R[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J14} [get_ports {lcd_R[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN N15} [get_ports {lcd_R[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G15} [get_ports {lcd_R[0]}]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y16} [get_ports cmos0_xclk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U17} [get_ports cmos0_pclk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y17} [get_ports cmos0_vsync]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN T16} [get_ports cmos0_href]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U14} [get_ports {cmos0_data[7]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U15} [get_ports {cmos0_data[6]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN N18} [get_ports {cmos0_data[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN P19} [get_ports {cmos0_data[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN T20} [get_ports {cmos0_data[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U20} [get_ports {cmos0_data[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y18} [get_ports {cmos0_data[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y19} [get_ports {cmos0_data[0]}]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN F19} [get_ports cmos1_xclk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K18} [get_ports cmos1_pclk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN H18} [get_ports cmos1_vsync]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J18} [get_ports cmos1_href]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K17} [get_ports {cmos1_data[7]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J19} [get_ports {cmos1_data[6]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K19} [get_ports {cmos1_data[5]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN M20} [get_ports {cmos1_data[4]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN M19} [get_ports {cmos1_data[3]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN F17} [get_ports {cmos1_data[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN F16} [get_ports {cmos1_data[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN D20} [get_ports {cmos1_data[0]}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cmos0_pclk_IBUF]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cmos1_pclk_IBUF]

create_clock -period 20.000 -name cmos0_pclk -waveform {0.000 10.000} [get_ports cmos0_pclk]
create_clock -period 20.000 -name cmos1_pclk -waveform {0.000 10.000} [get_ports cmos1_pclk]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K16} [get_ports {cmos0_light}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J16} [get_ports {cmos1_light}]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN P20} [get_ports {pm_ms[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN N20} [get_ports {pm_ms[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U19} [get_ports {pm_ms[0]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W15} [get_ports {pm_xen}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN T11} [get_ports {pm0_zpd}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN U18} [get_ports {pm0_drive}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V15} [get_ports {pm0_dir}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G14} [get_ports {pm1_zpd}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN P16} [get_ports {pm1_drive}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN P15} [get_ports {pm1_dir}]

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W19} [get_ports {am_ms[2]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W18} [get_ports {am_ms[1]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN R18} [get_ports {am_ms[0]}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W16} [get_ports {am_xen}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W20} [get_ports {am0_drive}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V20} [get_ports {am0_dir}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN T17} [get_ports {am1_drive}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V16} [get_ports {am1_dir}]

set_clock_groups -asynchronous -group clk_fpga_0 -group clk_fpga_1
set_clock_groups -asynchronous -group clk_fpga_2 -group clk_fpga_1
