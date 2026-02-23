#!/bin/bash

# Target file to append lines to
CDS="${HOME}/cds.lib"
REF="${HOME}/references.list"
REFPATH="${HOME}/references.list"
libraries# Lines to add
CDS_LINES=("DEFINE sky130_fd_pr_main ${PWD}/../../resources/cadence_sky130/sky130_release_0.0.9/libs/sky130_fd_pr_main"
       "DEFINE sky130_std_cells  ${PWD}/../../resources/cadence_sky130/sky130_scl_9T_0.0.8/sky130_scl_9T/oa/sky130_scl_9T/"
      )

REF_LINES=("sky130_std_cells")

# Function to check and add lines
add_lines_if_missing() {
    for line in "${CDS_LINES[@]}"; do
        # Check if the line already exists in the file
        if ! grep -Fxq "$line" "$CDS"; then
            echo "$line" >> "$CDS"
            echo "Added: $line"
        else
            echo "Skipped (already exists): $line"
        fi
    done
}

# Ensure target file exists
touch "$CDS"

# Run the function
add_lines_if_missing
sed -i '/^#Remove/d' "$CDS"

touch "$REF"
if ! grep -q "^sky130_std_cells$" "$REF" 2>/dev/null; then
    echo "sky130_std_cells" >> "$REF"
else
    echo "Text already exists"
fi

echo "Setup Complete"
