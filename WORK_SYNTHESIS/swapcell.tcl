set wrt_path_collection [get_timing_paths] ; # collection of timing paths - size 1

# per ogni path prendo ogni singolo timing point, poi prendo il nome della cella 
# e da esso mi estraggo le cella che andrò a modificare
foreach_in_collection timing_point [get_attribute $wrt_path_collection points] { ;# scan the collection of timing points belonging to the path
    
    set cell_name [get_attribute [get_attribute $timing_point object] full_name] ;# for each timing point we can extract multiple attributes (e.g. arrival time)
    # set arrival [get_attribute $timing_point arrival]
    # puts "$cell_name -> $arrival"

    # controlla se è una cella [<cell_name>/<A\B\Z\>]
    # set isMatch [regexp {^([A-Z0-9]+)/[A-Z]$} $cell_name matchVar name]
    # puts "$matchVar - $cell_name -  $name - $isMatch"
    if {[regexp {^([A-Z0-9]+)/[A-Z]$} $cell_name matchVar name] == 1} {
        set cell [get_cell  $name]
        set ref_name [get_attribute $cell ref_name]
        set lib_cell_name [get_attribute [get_lib_cells -of_object $cell] full_name]

        # puts "$name - $ref_name - $lib_cell_name - $dual"
        
        set dimension_end 255
        set newcell 0
        if { [regexp {^HS65_([A-Z]+)_([A-Z0-9]+)X([0-9]*)$} [string trim $ref_name] matchVar dual function dimension] == 1} {
            # puts "$ref_name => $dual - $function - $dimension"

            if { $dual == "LL" || $dual == "LH" } {
                foreach_in_collection alt_cell [get_alternative_lib_cells $cell] {
                    if {[regexp {^CORE65LPHVT/HS65_LH_([A-Z0-9]+)X([0-9]+)$} [get_attribute $alt_cell full_name] matchVar new_function dimension_app] == 1} {
                        # puts "[get_attribute $alt_cell full_name] => $dimension_app"
                        # puts "$matchVar => $function - $new_function => $dimension_app"
                        if {$function == $new_function && $dimension_app > $dimension && $dimension_app < $dimension_end} {
                            set newcell $matchVar
                            set dimension_end $dimension
                        }
                    } 
                } 
            } elseif { $dual == "LHS" || $dual == "LLS" } {
                foreach_in_collection alt_cell [get_alternative_lib_cells $cell] {
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
            puts "FIRST: $lib_cell_name -- THEN: $newcell => [get_attribute $cell full_name]"
            if { $newcell != 0} {
                size_cell $cell $newcell
            } 
            # else {
            #    puts uguale
            # }
        } 
    }
}
