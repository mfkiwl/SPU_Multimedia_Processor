#!/bin/bash

###################################################
# This script is used to select which tests to run
# USAGE : ./tests <test>
#     <test> :
#         all : Executes all tests
#         0   : Executes assembler_test
#         1   : Executes cache_miss_test
#         2   : Executes all_instruction_test
#         3   : Executes ls_fill_test
#         4   : Executes dual_instruction_test
#         5   : Executes struct_hazard_test
#         6   : Executes data_hazard_no_stall_test
#         7   : Executes data_hazard_stall_test
#         8   : Executes control_hazard_test
###################################################

### CLEAR SCREEN ###
clear

# TEXT COLORS #
grn=$'\e[1;32m';
red=$'\e[1;31m';
mag=$'\e[1;35m';
end=$'\e[0m';

#################### VALIDATE ARGUMENTS ####################
# One argument at a time #
# There are 9 test. Numbered : {0 - 8} or all (executes all tests) #
main() {
    # Only allowed 1 argument #
    if (( (( $# == 0 )) || (( $# > 1 )) ))
    then
        # Invalid Argument(s) #
        print_error $@;
        exit 1;
    fi

    # Test All Instructions #
    if [ "${1,,}" == "all" ] 
    then
        test_all;
    fi

    # Test Single Instruction #
    if (( (( $1 > 8 )) || (( $1 < 0 )) ))
    then 
        # Invalid Argument(s) #
        print_error $@;
        exit 1;
        
    else 
        select_test $@;
        exit 0;
    fi    
}

print_error() {
    printf "${red}Invalid Arugument(s): ${end}";
    while [[ $# > 0 ]]
    do
        echo -n "$1 " # Print next argument
        shift         # Shift argument left by 1
    done
}

#################### SELECT TEST ####################
select_test() {
    case $1 in
        0)  # ASSEMBLER TEST #
            assembler_test;
            ;;
        1)  # CACHE MISS TEST #
            cache_miss_test;
            ;;
        2)  # ALL INSTRUCTION TEST #
            all_instruction_test;
            ;;
        3)  # LS FILL TEST #
            ls_fill_test;
            ;;
        4)  # DUAL INSTRUCTION TEST #
            dual_instruction_test;
            ;;
        5)  # STRUCTURAL HAZARD RESOLUTION TEST #
            struct_hazard_test;
            ;;
        6)  # DATA HAZARD RESOLUTION (NO STALLING) TEST #
            data_hazard_no_stall_test;
            ;;
        7)  # DATA HAZARD RESOLUTION (STALLING) TEST #
            data_hazard_stall_test;
            ;;
        8)  # CONTROL HAZARD RESOLUTION TEST #
            control_hazard_test;
            ;;
    esac
}

#################### RUN ALL TESTS ####################
test_all() {
    assembler_test;
    cache_miss_test;
    all_instruction_test;
    ls_fill_test;
    dual_instruction_test;
    struct_hazard_test;
    data_hazard_no_stall_test;
    data_hazard_stall_test;
    control_hazard_test;
    exit 0;
}

#################### ASSEMBLER TEST - 0 ####################
assembler_test() {
    # Test Input Directory #
    rsrcdir="/c/Users/Wilmer Suarez/Desktop/SPU_Multimedia_Processor/assembler/rsrc";
    # Test Results Directory #
    outdir="/c/Users/Wilmer Suarez/Desktop/SPU_Multimedia_Processor/assembler/output";

    printf "Running ${mag}assembler_test${end}...\n";

    # RUN TEST #
    bash "tests/0_assembler_test.sh" 2>/dev/null &
    pid=$! # Process ID of test process

    # WAIT FOR TEST PROCESS TO FINISH #
    spin $pid;
}

#################### CACHE MISS TEST - 1 ####################
cache_miss_test() {
    printf "Running ${mag}cache_miss_test${end}...\n";
}

#################### ALL INSTRUCTION TEST - 2 ####################
all_instruction_test() {
    printf "Running ${mag}all_instruction_test${end}...\n";
}

#################### LS FILL TEST - 3 ####################
ls_fill_test() {
    printf "Running ${mag}ls_fill_test${end}...\n";
}

#################### DUAL INSTRUCTION TEST - 4 ####################
dual_instruction_test() {
    printf "Running ${mag}dual_instruction_test${end}...\n";
}

#################### STRUCTURAL HAZARD RESOLUTION TEST - 5 ####################
struct_hazard_test() {
    printf "Running ${mag}struct_hazard_test${end}...\n";
}

#################### DATA HAZARD RESOLUTION (NO STALLING) TEST - 6 ####################
data_hazard_no_stall_test() {
    printf "Running ${mag}data_hazard_no_stall_test${end}...\n";
}

#################### DATA HAZARD RESOLUTION (STALLING) TEST - 7 ####################
data_hazard_stall_test() {
    printf "Running ${mag}data_hazard_stall_test${end}...\n";
}

#################### CONTROL HAZARD RESOLUTION TEST - 8 ####################
control_hazard_test() {
    printf "Running ${mag}control_hazard_test${end}...\n";
}

spin() {
    # Characters of progress spinner #
    spin='-\|/';

    local i=0;
    # Spin while until process is finished # 
    while kill -0 $1 2>/dev/null 
    do
    i=$(( (i+1) % 4 ));
    printf "\r${mag}${spin:$i:1}${end}";
    sleep .1;
    done
    printf "\r${grn}Done${end}\n";
}

main "$@";
