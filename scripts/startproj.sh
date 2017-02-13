#!/usr/bin/env sh
set -e
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=setting'

dir_self=`dirname "$0"`
dir_main="`readlink -fe "${dir_self}/.."`"

source ${dir_main}/scripts/setenv

${VIVADO_BIN} -journal /tmp/vivado.jou -log /tmp/vivado.log
