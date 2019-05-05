#############################################################
# This test shows the Instruction cache getting filled
# on a Cache miss.
#############################################################

#################### OPEN PROJECT ####################
open_project C:/spu_core/spu_core.xpr -quiet

#################### RUN SIMULATION ####################
# Change Simulation Top Module #
set_property top SPU_CORE_TOP_MODULE_TB [get_filesets sim_1] -quiet
set_property top_lib xil_defaultlib [get_filesets sim_1] -quiet
# Launch Simulation #
launch_simulation -quiet
# Remove Non Relevant Signals #
remove_wave { {FILL} {DATA_OUT_LS} {INSTR_BLOCK_OUT_LS} {RESULT_PACKET_EVEN_OUT} {LS_PC_OUT_EXE} {LS_WE_OUT_EOP} {LS_DATA_OUT_EOP} {LS_ADDR_OUT_EOP} {CLK_PERIOD} }
# Add Local Store SRAM to Wave Viewer #
add_wave_divider CACHE -color magenta -quiet
add_wave {{/SPU_CORE_TOP_MODULE_TB/UUT/IF_STAGE/ic/CACHE}} -color magenta -quiet
add_wave {{/SPU_CORE_TOP_MODULE_TB/UUT/IF_STAGE/ic/HIT}}
# Restart Simulation #
restart -quiet
run 130 ns -quiet

#################### VIEW LOCAL STORE WAVEFORM ####################
start_gui
