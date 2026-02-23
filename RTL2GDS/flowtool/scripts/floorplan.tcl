# Minimum site dimensions: 0.46 units in X direction, 4.14 units in Y direction
set sitesx 0.46  ;# Set the site width (X dimension) to 0.46
set sitesy 4.14  ;# Set the site height (Y dimension) to 4.14

# Print a message indicating the start of the floorplan script
puts "RUNNING FLOORPLAN.TCL"

# Set the snapping of the floorplan to align with block grid instances
set_db floorplan_snap_block_grid inst

# Create the core area of the floorplan with dimensions based on site sizes
# Assuming we have approximately a 100x100 um box as the placeholder floorplan 
# The floorplan width is calculated as sitesx * 220 and height as sitesy * 25
create_floorplan -core_size [expr {$sitesx*2100}] [expr {$sitesy*300}] 30 30 30 30

# Initialize core rows for placement within the floorplan
init_core_rows

# Retrieve and store the design's bounding box dimensions (dx and dy)
set dx [get_db designs .bbox.dx]  ;# Get the design's X dimension (width)
set dy [get_db designs .bbox.dy]  ;# Get the design's Y dimension (height)

# REQUIRED: Macro Placement (Question 1)

# REQUIRED: Macro Protection (Question 8)

## Add Power Grid
# Source an external script to add a power grid to the design
source ./scripts/add_power.tcl

## Add Pins
# Source an external script to add pins to the design
source ./scripts/add_pins.tcl

# Align all elements in the floorplan to the nearest grid point
snap_floorplan -all

# Conditional block for optional macro placement and optimization (currently disabled)
if {0} {
  # Perform detailed macro placement
  place_macro_detail
  
  # Disable global placement of IO pins during optimization
  set_db place_global_place_io_pins false
  
  # Set a seed for global placement optimization
  set_db place_opt_run_global_place seed
  
  # Run placement optimization on the design
  place_opt_design
}

# Print a message indicating the end of the floorplan script
puts "ENDING FLOORPLAN.TCL"
