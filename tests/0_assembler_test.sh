#!/bin/bash

###############################################################
# This script tests the output of the assembler.
# Uses the test assembler file in the assembler/rsrc directory.
###############################################################

# Makefile Directory #
makedir="/c/Users/Wilmer Suarez/Desktop/SPU_Multimedia_Processor/assembler";
# Executable Directory #
exedir="/c/Users/Wilmer Suarez/Desktop/SPU_Multimedia_Processor/assembler/bin/assembler"; 
# Resource Directory #
rsrcdir="/c/Users/Wilmer Suarez/Desktop/SPU_Multimedia_Processor/assembler/rsrc";
# Output Directory #
outdir="/c/Users/Wilmer Suarez/Desktop/SPU_Multimedia_Processor/assembler/output";

#################### COMPILE ASSEMBLER ####################
make clean all -s -C "$makedir"; # &> /dev/null

#################### EXECUTE TEST ####################
"$exedir" < "$rsrcdir/test.asm" > "$outdir/data";

#################### OPEN TEST RESULTS ####################
code -n "$rsrcdir/test.asm" "$outdir/data";
