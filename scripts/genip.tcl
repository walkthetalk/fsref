set USERORG "user.org"
set USERNAME "user"
set IPNAME "pvdma"
set IPVER "1.0"
set IPSETDIR /mnt/zynq/ip_repo/
set IPDIR ${IPSETDIR}pvdma_v1.0/
set REGNUM 32
set CORENAME ${USERORG}:${USERNAME}:${IPNAME}:${IPVER}
set FINDCORE [ipx::find_open_core ${CORENAME}]

create_peripheral ${USERORG} ${USERNAME} ${IPNAME} ${IPVER} -dir ${IPSETDIR}

add_peripheral_interface S_AXI_LITE -interface_mode slave -axi_type lite ${FINDCORE}
set_property VALUE ${REGNUM} [ipx::get_bus_parameters WIZ_NUM_REG -of_objects [ipx::get_bus_interfaces S_AXI_LITE -of_objects ${FINDCORE}]]

add_peripheral_interface M_AXI -interface_mode master -axi_type full ${FINDCORE}

generate_peripheral -force ${FINDCORE}

write_peripheral ${FINDCORE}

ipx::edit_ip_in_project -upgrade true -name edit_pvdma_v1_0 -directory ${IPSETDIR} ${IPDIR}component.xml


