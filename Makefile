PROJECT := fsref
dir_self := $(shell dirname $(shell readlink -fe $(lastword ${MAKEFILE_LIST})))
dir_main := $(shell readlink -fe ${dir_self})

# TOOLS
dir_xilinx := "/mnt/udatum/sw/xilinx2021.2/"
#dir_xilinx := "/mnt/udatum/sw/xilinx"
XILINX_VER := "2022.2"
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

define IP_template =
.PHONY: ${1}
${1}:
	${VIVADO} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/genall.tcl \
	-tclargs "${dir_main}" "$$@"
endef


.PHONY: project
project: ${XPR_FILE}

.PHONY: bitbin
bitbin: ${BITBIN_FILE}

.PHONY: dts
dts: ${PSINIT_FILES} ${DTS_FILES}

${REG_FILE}:
	${dir_main}/scripts/genregs.py
${dir_out}:
	mkdir -p ${dir_out}

.PHONY: start_vivado
start_vivado: ${XPR_FILE}
	${VIVADO} -journal /tmp/vivado.jou -log /tmp/vivado.log ${XPR_FILE}

# generate all ip and project, omit the argument for generating all
${XPR_FILE}: ${REG_FILE}
	${VIVADO} \
	-nojournal -nolog \
	-mode batch \
	-source ${dir_main}/scripts/aux/genall.tcl \
	-tclargs "${dir_main}"

IP_list := fscmos \
	heater_cfg_ctl \
	fslcd \
	pwm \
	fsmotor \
	axilite2regctl \
	window_broadcaster \
	axis_window \
	axis_interconnector \
	axis_generator \
	axis_blender \
	axis_relay \
	axis_bayer_extractor \
	axis_reshaper \
	axis_reshaper_v2 \
	axis_scaler \
	mutex_buffer \
	s2mm \
	s2mm_adv \
	mm2s \
	mm2s_adv \
	axi_combiner \
	step_motor \
	fsctl \
	timestamper \
	fsa \
	fsa_v2 \
	intr_filter \
	fscpu \
	heater \

$(foreach temp,${IP_list},$(eval $(call IP_template,${temp})))

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
