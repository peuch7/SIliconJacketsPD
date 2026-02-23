#!/bin/tcsh

# Check if an argument was provided
if ( $#argv < 1 ) then
    echo "Usage: ./run_lvs.csh <cell_name>"
    exit 1
endif

source ./envsetup

set CELL = $1

set GOLDEN_DIR = "./opt_signoff_outputs/golden"
set PDK_RULES = "./resources/cadence_sky130/sky130_release_0.0.9/Sky130_LVS"

if ( ! -f $GOLDEN_DIR/golden_${CELL}.gds ) then
    gunzip $GOLDEN_DIR/golden_${CELL}.gds.gz
endif
if ( -d ./LVS_signoff ) then
    rm -rf ./LVS_signoff/*
else
		mkdir ./LVS_signoff/
endif
if ( -f $GOLDEN_DIR/golden_${CELL}.cdl ) then
    rm $GOLDEN_DIR/golden_${CELL}.cdl
endif

# Run Verilog to LVS netlist conversion
v2cdl -v $GOLDEN_DIR/golden_${CELL}.v -o $GOLDEN_DIR/golden_${CELL}.cdl

# Run Pegasus
pegasus -lvs \
-source_cdl $GOLDEN_DIR/golden_${CELL}.cdl \
-source_top_cell $CELL \
-layout_top_cell $CELL \
-gds $GOLDEN_DIR/golden_${CELL}.gds \
-run_dir ./LVS_signoff \
$PDK_RULES/sky130.lvs.pvl \
$PDK_RULES/black_box.pvl


exit 0
