set origin_dir [lindex $argv 0]

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

foreach i [list \
	cmos \
	lcd \
	mutex_buffer \
	mutex_buffer_ctl \
	s2mm \
	mm2s \
	axi_combiner \
	yscaler \
] {
	src $origin_dir/ip/$i/generate.tcl $origin_dir
}
src $origin_dir/scripts/genproj.tcl $origin_dir
