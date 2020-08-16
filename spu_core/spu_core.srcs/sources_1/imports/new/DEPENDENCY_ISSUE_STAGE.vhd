--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez

-- Create Date: 05/03-5/2019
-- Design Name: Dependency Issue Stage
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     Checks the Even and Odd Pipes for dependencies for the given
--     Even and Odd Instructions. Stalls the instruction(s) whose dependency
--     cannot be resolved through forwarding.
--     Sends instruction(s) to Register File once ready to be issued.
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.COMPONENTS_PACKAGE.ALL;
use work.SPU_CORE_ISA_PACKAGE.ALL; -- Contains all instructions in ISA
use work.CONSTANTS_PACKAGE.ALL;

entity DEPENDENCY_ISSUE_STAGE is
port (
    -------------------- INPUTS --------------------
    CLK               : in STD_LOGIC;  -- System Wide Synchronous Clock
    PC_IN             : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Current value of the PC 
    INSTR_EVEN_IN     : in INSTR_DATA; -- Even Instruction data from Decode Stage
    INSTR_ODD_IN      : in INSTR_DATA; -- Odd Instruction data from Decode Stage
    RF_IN_EVEN        : in PREV_DATA;  -- Even Register destination from entrence of Register File Stage
    RF_IN_ODD         : in PREV_DATA;  -- Odd Register destination from entrence of Register File Stage
    RF_OUT_EVEN       : in PREV_DATA;  -- Even Register destination from output of Register File Stage
    RF_OUT_ODD        : in PREV_DATA;  -- Odd Register destination from output of Register File Stage
    -------------------- OUTPUTS --------------------
    STALL_DEP_OUT      : out STD_LOGIC  := '0'; -- Stall IF & Decode stage
    INSTR_EVEN_OUT_DEP : out INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    INSTR_ODD_OUT_DEP  : out INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    PC_OUT_DEP         : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0'); -- Current value of the PC
    EVEN_OPCODE_DEP    : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := "00000000001";
    ODD_OPCODE_DEP     : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := "01000000001";
    RA_EVEN_ADDR_DEP   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
    RB_EVEN_ADDR_DEP   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
    RC_EVEN_ADDR_DEP   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
    RA_ODD_ADDR_DEP    : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
    RB_ODD_ADDR_DEP    : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
    RC_ODD_ADDR_DEP    : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
    EVEN_RI7_DEP       : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0');  
    EVEN_RI10_DEP      : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0');
    EVEN_RI16_DEP      : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0');
    ODD_RI7_DEP        : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0'); 
    ODD_RI10_DEP       : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); 
    ODD_RI16_DEP       : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0');
    ODD_RI18_DEP       : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0)   := (others => '0');
    EVEN_REG_DEST_DEP  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
    ODD_REG_DEST_DEP   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0')   
);
end DEPENDENCY_ISSUE_STAGE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of DEPENDENCY_ISSUE_STAGE is
begin
    ----- SEND CURRENT PC TO REGISTER FILE STAGE -----
    PC_OUT_DEP <= PC_IN;
    
    -------------------- DEPENDENCY STAGE PROCESS --------------------
    DEP_PROC : process(CLK)
    variable EVEN_DONE : BOOLEAN := FALSE; -- Even instruction ready to be issued?
    variable ODD_DONE  : BOOLEAN := FALSE; -- Odd instruction ready to be issued?
    begin
        if(rising_edge(CLK)) then
            -------------------- CHECK FOR DEPENDENCIES --------------------
            -------------------- EVEN INSTRUCTION --------------------
            if(check_dependencies(INSTR_EVEN_IN, INSTR_ODD_IN, RF_IN_EVEN, RF_IN_ODD, RF_OUT_EVEN, RF_OUT_ODD, EVEN_PIPE_FC, ODD_PIPE_FC)) then
            -- Stall Even Instruction --
            STALL_DEP_OUT <= '1';
            -- Send Even instruction data back in --
            INSTR_EVEN_OUT_DEP <= INSTR_EVEN_IN;
            -- Send NOPs while stalling --
            EVEN_OPCODE_DEP <= "00000000001";
            ODD_OPCODE_DEP  <= "01000000001";
            else 
                EVEN_DONE := TRUE; -- Even instruction can now be issued
            end if;
            
            -------------------- ODD INSTRUCTION --------------------
            if(check_dependencies(INSTR_ODD_IN, INSTR_EVEN_IN, RF_IN_EVEN, RF_IN_ODD, RF_OUT_EVEN, RF_OUT_ODD, EVEN_PIPE_FC, ODD_PIPE_FC)) then
            -- Stall Odd Instruction --
            STALL_DEP_OUT <= '1';  
            -- Send Odd instruction data back in --
            INSTR_ODD_OUT_DEP <= INSTR_ODD_IN;
            -- Send NOPs while stalling --
            EVEN_OPCODE_DEP <= "00000000001";
            ODD_OPCODE_DEP  <= "01000000001";
            else
                ODD_DONE := TRUE; -- Odd instruction can now be issued
            end if;
            
            ----- Are BOTH instructions ready to be issued? -----
            if(EVEN_DONE AND ODD_DONE) then 
                STALL_DEP_OUT <= '0'; -- Stop stalling
                
                ----- OUTPUT EVEN AND ODD DATA TO REGISTER FILE -----
                EVEN_OPCODE_DEP   <= INSTR_EVEN_IN.OP_CODE;
                ODD_OPCODE_DEP    <= INSTR_ODD_IN.OP_CODE;
                RA_EVEN_ADDR_DEP  <= INSTR_EVEN_IN.RA_ADDR;
                RB_EVEN_ADDR_DEP  <= INSTR_EVEN_IN.RB_ADDR; 
                RC_EVEN_ADDR_DEP  <= INSTR_EVEN_IN.RC_ADDR; 
                RA_ODD_ADDR_DEP   <= INSTR_ODD_IN.RA_ADDR;
                RB_ODD_ADDR_DEP   <= INSTR_ODD_IN.RB_ADDR;
                RC_ODD_ADDR_DEP   <= INSTR_ODD_IN.RC_ADDR;
                EVEN_RI7_DEP      <= INSTR_EVEN_IN.RI7;
                EVEN_RI10_DEP     <= INSTR_EVEN_IN.RI10;
                EVEN_RI16_DEP     <= INSTR_EVEN_IN.RI16;
                ODD_RI7_DEP       <= INSTR_ODD_IN.RI7;
                ODD_RI10_DEP      <= INSTR_ODD_IN.RI10;
                ODD_RI16_DEP      <= INSTR_ODD_IN.RI16;
                ODD_RI18_DEP      <= INSTR_ODD_IN.RI18;
                EVEN_REG_DEST_DEP <= INSTR_EVEN_IN.REG_DEST;
                ODD_REG_DEST_DEP  <= INSTR_ODD_IN.REG_DEST;
            end if;
        end if;
    end process DEP_PROC;
    
end behavioral;
