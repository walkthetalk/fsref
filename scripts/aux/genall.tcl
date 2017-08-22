set origin_dir [lindex $argv 0]
set ip_list [list \
	cmos \
	lcd \
	addr_array \
	window_ctl \
	mutex_buffer_ctl \
	reg_ctl \
	axilite2regctl \
	const_window \
	window_broadcaster \
	axis_window \
	axis_blender \
	mutex_buffer \
	s2mm \
	mm2s \
	axi_combiner \
	fsctl \
	yscaler \
]

if { $argc eq 1 } {
	set dst_list $ip_list
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

foreach i $ip_list {
	if {[lsearch $dst_list $i] >= 0 || [lsearch $dst_list allip] >= 0} {
		puts "generating ip: $i"
		src $origin_dir/ip/$i/generate.tcl $origin_dir
	}
}

if {[lsearch $dst_list project] >= 0} {
	puts "generating project file"
	src $origin_dir/scripts/aux/genproj.tcl $origin_dir
}
