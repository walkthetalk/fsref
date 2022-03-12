set origin_dir [lindex $argv 0]

set if_list [list \
	addr_array \
	window_ctl \
	mutex_buffer_ctl \
	step_motor_cfg_ctl \
	step_motor_req_ctl \
	motor_ic_ctl \
	blockram_init_ctl \
	pwm_ctl \
	reg_ctl \
	scale_ctl \
	mbr_rd_ctl \
	fsa_ctl \
	fsa_result \
	req_ctl \
]

set ip_list [list \
	fscmos \
		{Fusion Splicer Cmos} \
		{Fusion Splicer Cmos} \
	fslcd \
		{Fusion Splicer Lcd} \
		{Fusion Splicer Lcd} \
	pwm \
		{PWM} \
		{PWM} \
	fsmotor \
		{Fusion Splicer Motor} \
		{Fusion Splicer Motor} \
	axilite2regctl \
		{AxiLite to Reg control} \
		{AxiLite to Reg control} \
	window_broadcaster \
		{Window Broadcaster} \
		{Window Broadcaster} \
	axis_window \
		{AXI Stream Window} \
		{AXI Stream Window} \
	axis_interconnector \
		{AXI Stream InterConnector} \
		{AXI Stream InterConnector} \
	axis_generator \
		{AXI Stream Generator} \
		{AXI Stream Generator} \
	axis_blender \
		{AXI Stream Blender} \
		{AXI Stream Blender} \
	axis_relay \
		{AXI Stream Relay} \
		{AXI Stream Relay} \
	axis_bayer_extractor \
		{Bayer Stream Extractor} \
		{Bayer Stream Extractor} \
	axis_reshaper \
		{AXI Stream Reshaper} \
		{AXI Stream Reshaper} \
	axis_scaler \
		{AXI Stream Scaler} \
		{AXI Stream Scaler} \
	mutex_buffer \
		{Mutex Buffer Controller} \
		{Mutex Buffer Controller} \
	s2mm \
		{AXI Stream to MM} \
		{AXI Stream to MM} \
	s2mm_adv \
		{AXI Stream to MM advance version} \
		{AXI Stream to MM advance version} \
	mm2s \
		{AXI MM to Stream} \
		{AXI MM to Stream} \
	mm2s_adv \
		{AXI MM to Stream Advance} \
		{AXI MM to Stream Advance} \
	axi_combiner \
		{AXI MM Combiner} \
		{Combine read/ra and write/wa channel into one full AXI Bus} \
	step_motor \
		{Step Motor Controller} \
		{Step Motor Controller} \
	fsctl \
		{Fusion Splicer Controller} \
		{Fusion Splicer Controller} \
	timestamper \
		{Timestamp Generator} \
		{Timestamp Generator} \
	fsa \
		{Fusion Splicer Image Analyzer} \
		{Fusion Splicer Image Analyzer} \
	fsa_v2 \
		{Fusion Splicer Image Analyzer Advance version} \
		{Fusion Splicer Image Analyzer Advance version} \
	intr_filter \
		{Interrupt Source Filter} \
		{Interrupt Source Filter} \
	fscpu \
		{Fusion Splicer CPU} \
		{Fusion Splicer CPU} \
]

if { $argc eq 1 } {
	set dst_list $if_list
	lappend dst_list {*}$ip_list
	lappend dst_list project
} else {
	set dst_list [lrange $argv 1 end]
}

proc src {file args} {
  set argv $::argv
  set argc $::argc
  set argv0 $::argv0
  set ::argv $args
  set ::argc [llength $args]
  set ::argv0 $file
  set code [catch {uplevel [list source $file]} return]
  set ::argv $argv
  set ::argc $argc
  set ::argv0 $argv0
  return -code $code $return
}

source $origin_dir/scripts/aux/util.tcl

foreach i $if_list {
	if {[lsearch $dst_list $i] >= 0 || [lsearch $dst_list allip] >= 0} {
		puts "generating ip: $i"
		set ip_dir $origin_dir/ip/$i
		set busabs [NEW_BUS $ip_dir]
		src $ip_dir/generate.tcl
		SAVE_BUS $busabs
	}
}

foreach {i j k} $ip_list {
	if {[lsearch $dst_list $i] >= 0 || [lsearch $dst_list allip] >= 0} {
		puts "generating ip: $i"
		set ip_dir $origin_dir/ip/$i
		set core [NEW_CORE $ip_dir $j $k]
		src $ip_dir/generate.tcl
		SAVE_CORE $core
	}
}

if {[lsearch $dst_list project] >= 0} {
	puts "generating project file"
	src $origin_dir/scripts/aux/genproj.tcl $origin_dir
}
