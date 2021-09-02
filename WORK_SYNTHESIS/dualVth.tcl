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
	#take all the cell and delete the cell of the critical path
	set all_cells [get_cells]
	######### DA MODIFICARE QUANDO ARRIVERà LA PARTE DI NICO########
	set worst_path 0
	foreach cell $worst_path {
		set index [lsearch $all_cells $cell]
		set $all_cells [lreplace $all_cell $index $index]
	}
	################################################################
	#order list
	#prendo una lista a parte la ordino lista fatta da ogni cella e la leackage_power
	foreach cell $all_cells {
		lappend order_cells [list $cell [get_attribute $cell leackage_power]]
	}
	lsort -index 1 $order_cells
	foreach element $order_cells {
		set element [lreplace $element 1 1]
		lappend cells_to_control $element
	}
	#take each cell and swap it from hvt in lvt
	foreach cell $cells_to_control {
	################### IMPORTANT
	#changing the sizing the power consumption decrease but the delay increase
	#changing from lvt->hvt reducing th leackage power consumption and increase the delay
	# control the slack 
	}
	return
}

define_proc_attributes dualVth \
-info "Post-Synthesis Dual-Vth Cell Assignment and Gate Re-Sizing" \
-define_args \
{
	{-allowed_slack "allowed slack after the optimization (valid range [-OO, 0])" value float required}
}
