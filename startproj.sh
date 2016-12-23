#!/usr/bin/env sh
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=setting'

#/mnt/xilinx/Vivado/2016.3/bin/vivado -nolog -nojournal
/mnt/xilinx/Vivado/2016.3/bin/vivado -journal /tmp/vivado.jou -log /tmp/vivado.log
