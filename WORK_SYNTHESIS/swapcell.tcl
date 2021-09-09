set wrt_path_collection [get_timing_paths] ; # collection of timing paths - size 1
set allowed_slack -0.5
set flag 1

while {$flag} {

    set leakage_power_swap 0

    # per ogni path prendo ogni singolo timing point, poi prendo il nome della cella 
    # e da esso mi estraggo le cella che andrò a modificare
    foreach_in_collection timing_point [get_attribute $wrt_path_collection points] { ;# scan the collection of timing points belonging to the path
        
        set cell_name [get_attribute [get_attribute $timing_point object] full_name] ;# for each timing point we can extract multiple attributes (e.g. arrival time)
        # set arrival [get_attribute $timing_point arrival]
        #puts "$cell_name -> $arrival"

        # controlla se è una cella [<cell_name>/<A\B\Z\>]
        # set isMatch [regexp {^([A-Z0-9]+)/[A-Z]$} $cell_name matchVar name]
        # puts "$matchVar - $cell_name -  $name - $isMatch"
        if {[regexp {^([A-Z0-9]+)/[AB]$} $cell_name matchVar name] == 1} {
            set cell [get_cell  $name]
            
            if { [regexp {^HS65_([A-Z]+)_[A-Z0-9]+X[0-9]*$} [get_attribute $cell ref_name] matchVar dual] == 1} {
                
                set leakage_power [get_attribute $cell leakage_power]

                # puts "$cell_name - $leakage_power - [get_attribute $cell ref_name] - $dual"

                if { $dual == "LL" || $dual == "LLS"} {
                    if {$leakage_power > $leakage_power_swap} {
                        set cell_to_swap $cell
                        set leakage_power_swap $leakage_power
                    }
                }
            }
        }
    }

    set ref_name [get_attribute $cell_to_swap ref_name]
    set dimension_end 255
    set newcell 0
    if { [regexp {^HS65_([A-Z]+)_([A-Z0-9]+)X([0-9]*)$} $ref_name matchVar dual function dimension] == 1} {
        # puts "$ref_name => $dual - $function - $dimension"

        if { $dual == "LL"} {
            foreach_in_collection alt_cell [get_alternative_lib_cells $cell_to_swap] {
                if {[regexp {^CORE65LPHVT/HS65_LH_([A-Z0-9]+)X([0-9]+)$} [get_attribute $alt_cell full_name] matchVar new_function dimension_app] == 1} {
                    # puts "[get_attribute $alt_cell full_name] => $dimension_app"
                    # puts "$matchVar => $function - $new_function => $dimension_app"
                    if {$function == $new_function && $dimension_app > $dimension && $dimension_app < $dimension_end} {
                        set newcell $matchVar
                        set dimension_end $dimension
                    }
                } 
            } 
        } elseif { $dual == "LLS"} {
            foreach_in_collection alt_cell [get_alternative_lib_cells $cell_to_swap] {
                if {[regexp {^CORE65LPHVT/HS65_LHS_([A-Z0-9]+)X([0-9]+)$} [get_attribute $alt_cell full_name] matchVar new_function dimension_app] == 1} {
                    # puts "[get_attribute $alt_cell full_name] => $dimension_app"
                    # puts "$matchVar => $function - $new_function => $dimension_app"
                    if {$function == $new_function && $dimension_app > $dimension && $dimension_app < $dimension_end} {
                        set newcell $matchVar
                        set dimension_end $dimension
                    }
                } 
            }
        } 

        # se la cella non può essere sostituita
        set lib_cell_name [get_attribute [get_lib_cells -of_object $cell_to_swap] full_name]
        # puts "FIRST: $lib_cell_name -- THEN: $newcell => [get_attribute $cell_to_swap full_name]"
        if { $newcell != 0} {
            size_cell $cell_to_swap $newcell
            set wrt_path_collection [get_timing_paths] 
            if { [get_attribute [get_timing_paths] slack] < $allowed_slack} {
                set flag 0
                size_cell $cell_to_swap $lib_cell_name
            } else {
                puts [get_attribute $wrt_path_collection slack]
            }
        } else {
            set flag 0
        }
    }
}
