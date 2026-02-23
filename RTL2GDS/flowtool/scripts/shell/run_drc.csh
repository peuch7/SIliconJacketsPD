#!/bin/tcsh -f


if ( $#argv < 1 ) then
    echo "Usage: ./run_drc.csh <cell_name>"
    exit 1
endif

source ./envsetup


set CELL = $1

# 1. Define Relative Paths
set GOLDEN_DIR = "./opt_signoff_outputs/golden"
set DRC_RULES_DIR = "./resources/cadence_sky130/sky130_release_0.0.9/Sky130_DRC/Sky130_DRC_rev_0.0_2.9"
setenv PEGASUS_DRC "$DRC_RULES_DIR"

# 2. Check if the unzipped GDS exists; if not, check for the .gz and unzip it
if ( ! -f $GOLDEN_DIR/golden_${CELL}.gds ) then
    gunzip $GOLDEN_DIR/golden_${CELL}.gds.gz
endif
if ( -d ./DRC_signoff ) then
    rm -rf ./DRC_signoff/*
else
		mkdir ./DRC_signoff/
endif

# 3. Run Pegasus DRC
pegasus -drc \
-gds $GOLDEN_DIR/golden_${CELL}.gds \
-top_cell $CELL \
-run_dir ./DRC_signoff \
$DRC_RULES_DIR/sky130_rev_0.0_2.9.drc.pvl
