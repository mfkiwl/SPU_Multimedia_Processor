#############################################################
# This script tests the machine code output by the assembler.
# Demonstrates the Local Store is being filled with the 
# test instrucints.
#############################################################

#################### OPEN PROJECT ####################
open_project C:/spu_core/spu_core.xpr -quiet

#################### RUN SIMULATION ####################
# Change Simulation Top Module #
set_property top ls_fill_test_TB [get_filesets sim_1] -quiet
set_property top_lib xil_defaultlib [get_filesets sim_1] -quiet
# Launch Simulation #
launch_simulation -quiet
# Remove Non Relevant Signals #
remove_wave { {WE_LS} {RIB_LS} {FILL} {ADDR_LS} {DATA_IN_LS} {PC_LS} {DATA_OUT_LS} {INSTR_BLOCK_OUT_LS} {CLK_PERIOD} }
# Allow for Local Store bit size #
set_property display_limit 262144 [current_wave_config] -quiet
# Add Local Store SRAM to Wave Viewer #
add_wave_divider LOCAL_STORE -color magenta -quiet
add_wave {{/ls_fill_test_TB/ls/SRAM}} -color magenta -quiet
# Restart Simulation #
restart -quiet
run 2000 ns -quiet

#################### VIEW LOCAL STORE WAVEFORM ####################
start_gui
