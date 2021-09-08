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
    set slack [get_attribute $critical_path slack] 
    while {$slack > $allowed_slack } {
	set cells_critical_path [get_attribute $critical_path points]
	set objs ""
	foreach_in_collection point $cells_critical_path {
        set objs [linsert $objs 0 [get_attribute $point object]]
	}
    set cells [get_cells -of_objects $objs]
    set cell_leackage ""
    set cell_can_be_substitute [get_cells]
    #set cells_name ""
    #foreach cell $cell_can_substitute {
    #    set cells_name [linsert $cells_name 0 [get_attribute $cell ref_name]]
    #    puts $cells_name
    #}
    #set first [lindex $cells_name 0]
    puts " Worst path"
    foreach_in_collection cell $cells {
        set name [get_attribute $cell ref_name]
        puts $name
        #set result [lsearch $cells_name $name]
        #puts $result
        if { [regexp {^HS65_([A-Z]+)_([A-Z0-9]+)X([0-9]*)$} [string trim $name] matchVar dual function dimension] == 1} {
            set leackage [get_attribute $cell leackage_power]
            puts $name $leackage 
            lappend cell_leackage [list $name $leackage]
        }
    }
    puts $cell_leackage
	#order list
	#prendo una lista a parte la ordino lista fatta da ogni cella e la leackage_power
	lsort -index 1 -decreasing $cell_leackage
    #take the first element 
    set cell_swap [lindex [lindex $cell_leackage 0] 0]
    puts $cell_swap
    set critical_path [get_timing_paths]
    set slack [get_attribute $path slack] 
    }
	################### IMPORTANT
	#reducing the sizing the power consumption decrease but the delay increase
	#changing from lvt->hvt reducing th leackage power consumption and increase the delay
	# control the slack 
	#take the best path
	#set paths [get_path_groups]
	#set bestpaths ""
	#foreach path $paths {
	#	lappend bestpaths [list $path [get_attribute time_lent_to_startpoint]]
	#}
	#lsort -index 1 $bestpaths
	#set element [lindex $bestpaths 0]
	#set bestpath [lindex $element 0]
	return
}
define_proc_attributes dualVth \
-info "Post-Synthesis Dual-Vth Cell Assignment and Gate Re-Sizing" \
-define_args \
{
	{-allowed_slack "allowed slack after the optimization (valid range [-OO, 0])" value float required}
}
