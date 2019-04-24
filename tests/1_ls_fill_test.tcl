#############################################################
# This script tests the machine code output by the assembler.
# Making sure the Local Store is being filled with the 
# proper instrucints.
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
remove_wave { {EVEN_OPCODE} {RA_EVEN_ADDR} {RB_EVEN_ADDR} {RC_EVEN_ADDR} {EVEN_REG_DEST} {EVEN_RI7} {EVEN_RI10} {EVEN_RI16} {ODD_OPCODE} {RA_ODD_ADDR} {RB_ODD_ADDR} {RC_ODD_ADDR} {ODD_REG_DEST} {ODD_RI7} {ODD_RI10} {ODD_RI16} {ODD_RI18} {LS_DATA_IN} {LS_WE_OUT_EOP} {LS_RIB_OUT_EOP} {LS_DATA_OUT_EOP} {LS_ADDR_OUT_EOP} {INSTR_BLOCK_OUT_LS} {FILL} {RESULT_PACKET_EVEN_OUT} {RESULT_PACKET_ODD_OUT} {INSTR_WIDTH} {LINE_WIDTH} {INSTR_COUNT_MAX} {CLK_PERIOD} }
# Allow for Local Store bit size #
set_property display_limit 262144 [current_wave_config] -quiet
# Add Local Store SRAM to Wave Viewer #
add_wave_divider LOCAL_STORE -quiet
add_wave {{/ls_fill_test_TB/ls/SRAM}} -quiet
# Restart Simulation #
restart -quiet
run 1000 ns -quiet
relaunch_sim

#################### VIEW LOCAL STORE WAVEFORM ####################
start_gui
