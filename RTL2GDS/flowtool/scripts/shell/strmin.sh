#!/bin/bash
CDS="${HOME}/cds.lib"
REF="${HOME}/references.list"
REFPATH="${HOME}/references.list"

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
 echo "Script usage: $0 <module_name> <gds_file_path> <destination_lib_path>"
 exit 1
fi

# Add name of module to be streamed in
MODULE=$1
GDSPATH="$( realpath "$2")"
NEWLIB_DESTINATION_PATH="$( realpath "$3")"

if [[ ! -f "$GDSPATH" ]]; then
  echo "Error: GDS file '$GDSPATH' does not exist."
  exit 1
fi

# cd to $HOME directory to add the definition of the library in the $HOM cds.lib
cd $HOME
touch "$CDS"

grep -q "^DEFINE $MODULE" $CDS && echo "$MODULE already exists"  || strmin -library $MODULE -strmFile $GDSPATH -attachTechFileOfLib 'sky130_fd_pr_main' -topCell $MODULE -logFile 'strmIn.log' -refLibList $REFPATH -runDir $NEWLIB_DESTINATION_PATH
