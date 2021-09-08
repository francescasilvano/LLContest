proc dualVth {args} {
	parse_proc_arguments -args $args results
	set allowed_slack $results(-allowed_slack)

	#################################
	### INSERT YOUR COMMANDS HERE ###
	#################################
	
	#check if the slack is ok!
	if {$allowed_slack >0} {
   		return
  	}
	#take the critical path
	set critical_path [get_timing_paths]
	set cells_critical_path [get_attribute $critical_path points]
	set objs ""
	foreach_in_collection point $cells_critical_path {
		lappend objs [get_attribute $point object]
	}
    set cells [get_cells -of_objects $objs]
    set cell_leackage ""
    puts "Worst path"
    foreach cell $cells {
        set name [get_attribute $cell ref_name]
        puts $name
        lappend cell_leackage [list $cell [get_attribute $cell leackage_power]]
    }

	#order list
	#prendo una lista a parte la ordino lista fatta da ogni cella e la leackage_power
	lsort -index 1 $cell_leackage
	set cells_to_control ""
	foreach element cell_leackage {
		set element [lreplace $element 1 1]
		lappend cells_to_control $element
	}
	#take each cell and swap it from hvt in lvt
	foreach cell $cells_to_control {
	################### IMPORTANT
	#reducing the sizing the power consumption decrease but the delay increase
	#changing from lvt->hvt reducing th leackage power consumption and increase the delay
	# control the slack 
	}
	#take the best path
	set paths [get_path_groups]
	set bestpaths ""
	foreach path $paths {
		lappend bestpaths [list $path [get_attribute time_lent_to_startpoint]]
	}
	lsort -index 1 $bestpaths
	set element [lindex $bestpaths 0]
	set bestpath [lindex $element 0]
	return
}
proc control {allowed_slack} {
	set path [get_timing_paths] 
  	set slack [get_attribute $path slack] 
	if {$slack < $allowed_slack}
		return -1
	else return 0
}
define_proc_attributes dualVth \
-info "Post-Synthesis Dual-Vth Cell Assignment and Gate Re-Sizing" \
-define_args \
{
	{-allowed_slack "allowed slack after the optimization (valid range [-OO, 0])" value float required}
}
