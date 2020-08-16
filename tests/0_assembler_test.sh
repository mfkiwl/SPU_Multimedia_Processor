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
outdir="C:\Users\Wilmer Suarez\Desktop\SPU_Multimedia_Processor\assembler\output";

#################### COMPILE ASSEMBLER ####################
make clean all -s -C "$makedir";

#################### EXECUTE TEST ####################
case $1 in
    1)  # LS FILL TEST #
        "$exedir" < "$rsrcdir/0_assembler_test.asm" > "$outdir\data";
        ;;
    2)  # CACHE MISS TEST #
        "$exedir" < "$rsrcdir/0_assembler_test.asm" > "$outdir\data";
        ;; 
    3)  # DUAL INSTRUCTION TEST #
        "$exedir" < "$rsrcdir/3_NO_HAZARD_dual_fetch-decode-issue-execute_test.asm" > "$outdir\data";
        ;;
    4)  # STRUCTURAL HAZARD RESOLUTION TEST #
        "$exedir" < "$rsrcdir/4_structural_hazard_resolution_test.asm" > "$outdir\data";
        ;;
    5)  # DATA HAZARD RESOLUTION (NO STALLING) TEST #
        "$exedir" < "$rsrcdir/5_NO_STALL_data_hazard_resolution_by_forwarding_test.asm" > "$outdir\data";
        ;;
    6)  # DATA HAZARD RESOLUTION (STALLING) TEST #
        "$exedir" < "$rsrcdir/6_data_hazard_resolution_by_stalling_and_forwarding_test.asm" > "$outdir\data";
        ;;
    7)  # CONTROL HAZARD RESOLUTION TEST #
        "$exedir" < "$rsrcdir/7_control_hazard_resolution_for_branches_test.asm" > "$outdir\data";
        ;;
    8)  # ALL INSTRUCTION TEST #
        "$exedir" < "$rsrcdir/8_all_instr_test.asm" > "$outdir\data";
        ;;
    *) 
        "$exedir" < "$rsrcdir/0_assembler_test.asm" > "$outdir\data";
        ;;
esac
