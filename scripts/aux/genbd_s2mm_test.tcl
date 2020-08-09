create_bd_cell -type ip -vlnv ocfb:pvip:s2mm_adv:1.0.9 s2mm_adv_0
set_property -dict [list \
	CONFIG.C_PIXEL_WIDTH 8 \
	CONFIG.C_IMG_WBITS 12 \
	CONFIG.C_IMG_HBITS 12 \
	CONFIG.C_M_AXI_BURST_LEN 16 \
	CONFIG.C_M_AXI_ADDR_WIDTH 32 \
	CONFIG.C_M_AXI_DATA_WIDTH 64 \
	CONFIG.C_DATACOUNT_BITS 8 \
] [get_bd_cells s2mm_adv_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_0
set_property -dict [list \
	CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
	CONFIG.Input_Data_Width {10} \
	CONFIG.Output_Data_Width {80} \
	CONFIG.Output_Depth {128} \
	CONFIG.Read_Data_Count {true} \
	CONFIG.Reset_Type {Synchronous_Reset} \
	CONFIG.Almost_Full_Flag {true} \
] [get_bd_cells fifo_generator_0]

connect_bd_intf_net [get_bd_intf_pins s2mm_adv_0/FIFO_WRITE] [get_bd_intf_pins fifo_generator_0/FIFO_WRITE]
connect_bd_intf_net [get_bd_intf_pins s2mm_adv_0/FIFO_READ] [get_bd_intf_pins fifo_generator_0/FIFO_READ]
connect_bd_net [get_bd_pins s2mm_adv_0/resetting] [get_bd_pins fifo_generator_0/srst]
connect_bd_net [get_bd_pins fifo_generator_0/clk] [get_bd_pins s2mm_adv_0/clk]
connect_bd_net [get_bd_pins fifo_generator_0/rd_data_count] [get_bd_pins s2mm_adv_0/s2mm_rd_data_count]

make_bd_intf_pins_external \
	[get_bd_intf_pins s2mm_adv_0/S_AXIS] \
	[get_bd_intf_pins s2mm_adv_0/IMG_SIZE] \
	[get_bd_intf_pins s2mm_adv_0/M_AXI] \
	[get_bd_intf_pins s2mm_adv_0/MBUF_W]
set_property name S_AXIS [get_bd_intf_ports S_AXIS_0]
set_property name IMG_SIZE [get_bd_intf_ports IMG_SIZE_0]
set_property name M_AXI [get_bd_intf_ports M_AXI_0]
set_property name MBUF_W [get_bd_intf_ports MBUF_W_0]

create_bd_port -dir I -type clk -freq_hz 150000000 clk
connect_bd_net [get_bd_ports clk] [get_bd_pins s2mm_adv_0/clk]

create_bd_port -dir I -type rst resetn
connect_bd_net [get_bd_ports resetn] [get_bd_pins s2mm_adv_0/resetn]

make_bd_pins_external  [get_bd_pins s2mm_adv_0/soft_resetn]
set_property name soft_resetn [get_bd_ports soft_resetn_0]

# address
assign_bd_address [get_bd_addr_segs {M_AXI/Reg }]
set_property offset 0x00000000 [get_bd_addr_segs {s2mm_adv_0/M_AXI_REG/SEG_M_AXI_Reg}]
set_property range 4G [get_bd_addr_segs {s2mm_adv_0/M_AXI_REG/SEG_M_AXI_Reg}]
