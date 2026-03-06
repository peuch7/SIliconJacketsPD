proc highlight_block {inst} {
	gui_highlight $inst -auto_color
	gui_dim_foreground -light_level dark
}

proc highlight_path {path} {
	if {[catch { gui_gtd_highlight_timing_report -path $path }]} {
        report_timing -output_format binary > timing_report.btarpt
        read_timing_debug_report timing_report.btarpt
        gui_gtd_highlight_timing_report -path $path
    }
	gui_dim_foreground -light_level dark
}

proc dump_fanouts {} {
    foreach inst [get_db insts] {
        set cell_name 0 ; # TODO: Find a way to obtain the cell name of the inst using get_db

        # TODO: fill out the correct condition to check if the current instance is a clock buffer.
        # You can see the names of the clock buffers used in setup.yaml.
        if {0} {
            set pins 0 ; # Find a way to obtain the pins of the current inst
            set fanout 0 ; # Get the fanout

            # Print the fanout along with the instance it's associated with
        }
    }
}
