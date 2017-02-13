
# main ip
startgroup
create_bd_cell -type ip -vlnv user.org:user:yscaler:1.0 yscaler_0
endgroup

# fifo
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 fifo_generator_0
set_property -dict [list \
	CONFIG.Fifo_Implementation {Common_Clock_Builtin_FIFO} \
	CONFIG.INTERFACE_TYPE {Native} \
	CONFIG.Input_Data_Width {10} \
	CONFIG.Input_Depth {4096} \
	CONFIG.Output_Data_Width {10} \
	CONFIG.Output_Depth {4096} \
	CONFIG.Reset_Type {Asynchronous_Reset} \
	CONFIG.Full_Flags_Reset_Value {0} \
	CONFIG.Use_Dout_Reset {false} \
	CONFIG.Data_Count_Width {12} \
	CONFIG.Write_Data_Count_Width {12} \
	CONFIG.Read_Data_Count_Width {12} \
	CONFIG.Full_Threshold_Assert_Value {4094} \
	CONFIG.Full_Threshold_Negate_Value {4093} ] [get_bd_cells fifo_generator_0]
endgroup
copy_bd_objs /  [get_bd_cells {fifo_generator_0}]

# connect
connect_bd_intf_net [get_bd_intf_pins fifo_generator_0/FIFO_WRITE] [get_bd_intf_pins yscaler_0/FIFO0_WRITE]
connect_bd_intf_net [get_bd_intf_pins fifo_generator_0/FIFO_READ] [get_bd_intf_pins yscaler_0/FIFO0_READ]
connect_bd_intf_net [get_bd_intf_pins fifo_generator_1/FIFO_WRITE] [get_bd_intf_pins yscaler_0/FIFO1_WRITE]
connect_bd_intf_net [get_bd_intf_pins fifo_generator_1/FIFO_READ] [get_bd_intf_pins yscaler_0/FIFO1_READ]
connect_bd_net [get_bd_pins yscaler_0/fifo_rst] [get_bd_pins fifo_generator_0/rst]
connect_bd_net [get_bd_pins yscaler_0/fifo_rst] [get_bd_pins fifo_generator_1/rst]

# external
startgroup
create_bd_port -dir I -type rst resetn
connect_bd_net [get_bd_pins /yscaler_0/resetn] [get_bd_ports resetn]
create_bd_port -dir I -type clk clk
connect_bd_net [get_bd_pins /yscaler_0/clk] [get_bd_ports clk]
connect_bd_net [get_bd_ports clk] [get_bd_pins fifo_generator_0/clk]
connect_bd_net [get_bd_ports clk] [get_bd_pins fifo_generator_1/clk]

create_bd_port -dir I fsync
connect_bd_net [get_bd_pins /yscaler_0/fsync] [get_bd_ports fsync]
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS
set_property -dict [list CONFIG.TUSER_WIDTH [get_property CONFIG.TUSER_WIDTH [get_bd_intf_pins yscaler_0/S_AXIS]] CONFIG.HAS_TLAST [get_property CONFIG.HAS_TLAST [get_bd_intf_pins yscaler_0/S_AXIS]]] [get_bd_intf_ports S_AXIS]
connect_bd_intf_net [get_bd_intf_pins yscaler_0/S_AXIS] [get_bd_intf_ports S_AXIS]
create_bd_port -dir I -from 11 -to 0 ori_width
connect_bd_net [get_bd_pins /yscaler_0/ori_width] [get_bd_ports ori_width]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
connect_bd_intf_net [get_bd_intf_pins yscaler_0/M_AXIS] [get_bd_intf_ports M_AXIS]
create_bd_port -dir I -from 11 -to 0 scale_height
connect_bd_net [get_bd_pins /yscaler_0/scale_height] [get_bd_ports scale_height]
create_bd_port -dir I -from 11 -to 0 scale_width
connect_bd_net [get_bd_pins /yscaler_0/scale_width] [get_bd_ports scale_width]
create_bd_port -dir I -from 11 -to 0 ori_height
connect_bd_net [get_bd_pins /yscaler_0/ori_height] [get_bd_ports ori_height]
endgroup

# save
save_bd_design
