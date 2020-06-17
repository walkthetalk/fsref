PROJECT := fsref
dir_self := $(shell dirname $(shell readlink -fe $(lastword ${MAKEFILE_LIST})))
dir_main := $(shell readlink -fe ${dir_self})

# TOOLS
dir_xilinx := "/opt/xilinx"
XILINX_VER := "2019.2"
VIVADO := "${dir_xilinx}/Vivado/${XILINX_VER}/bin/vivado"
XSCT := "${dir_xilinx}/Vitis/${XILINX_VER}/bin/xsct"
dir_repodt := "${dir_main}/../device-tree-xlnx"

# RUN ENV
CPU_PHY_CORE_NUM := 6

# DIRECTORY AND FILES
dir_out  := ${dir_main}/output
REG_FILE := ${dir_main}/ip/fsctl/src/fsctl.v
XPR_FILE := ${dir_main}/${PROJECT}.xpr
BIT_FILE := ${dir_main}/${PROJECT}.runs/impl_1/bd1_wrapper.bit

BITBIN_FILE := ${dir_out}/system.bit.bin
XSA_FILE := ${dir_out}/${PROJECT}.xsa
dir_psinit := ${dir_out}/psinit
dir_dts    := ${dir_out}/dts
PSINIT_FILES := ${dir_psinit}/ps7_init_gpl.h ${dir_psinit}/ps7_init_gpl.c
DTS_FILES := ${dir_dts}/system-top.dts


.PHONY: project
project: ${XPR_FILE}

.PHONY: bitbin
bitbin: ${BITBIN_FILE}

.PHONY: dts
dts: ${PSINIT_FILES} ${DTS_FILES}

.PHONY: start_vivado

${REG_FILE}:
	${dir_main}/scripts/genregs.py
${dir_out}:
	mkdir -p ${dir_out}
start_vivado: ${XPR_FILE}
	${VIVADO} -journal /tmp/vivado.jou -log /tmp/vivado.log ${XPR_FILE}

# generate all ip and project, omit the argument for generating all
${XPR_FILE}: ${REG_FILE}
	${VIVADO} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/genall.tcl \
	-tclargs "${dir_main}"

.PHONY: fslcd
fslcd:
	${VIVADO} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/genall.tcl \
	-tclargs "${dir_main}" "fslcd"

${XSA_FILE}: ${BIT_FILE}
	${VIVADO} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/gen_xsa.tcl \
	-tclargs "$@" "${XPR_FILE}"

${BIT_FILE}: ${XPR_FILE}
	${VIVADO} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/gen_bitstream.tcl \
	-tclargs "${XPR_FILE}" "${CPU_PHY_CORE_NUM}"

${BITBIN_FILE}: ${BIT_FILE} ${dir_out}
	gcc "${dir_main}/scripts/bit2bin/zynq_bit2bin.c" -o ${dir_out}/bit2bin
	${dir_out}/bit2bin ${BIT_FILE} ${BITBIN_FILE}
	@echo "#Load the Bitstream Example:"
	@echo "	mkdir -p /lib/firmware"
	@echo "	cp /media/system.bit.bin /lib/firmware/"
	@echo "	echo system.bit.bin > /sys/class/fpga_manager/fpga0/firmware"

${PSINIT_FILES} ${DTS_FILES}: ${XSA_FILE} ${dir_out}
	${XSCT} \
	${dir_main}/scripts/aux/gen_dts.tcl \
	"${dir_dts}" "${dir_psinit}" "${XSA_FILE}" "ps7_cortexa9_0" "${dir_repodt}"

${dir_out}/freertos.boot.bin: ${BIT_FILE} ${dir_out}
	${SDK_BIN_DIR}/bootgen \
		-image ${dir_main}/scripts/freertos.bif -arch zynq -o ${out_file} -w on

.PHONY: cleanall
cleanall:
	${dir_main}/scripts/clean.sh
.PHONY: help
help:
	@echo -e "destination:"
	@echo -e "\tproject"
	@echo -e "\tbitbin"
	@echo -e "\tdts"
	@echo -e "\tcleanall"
