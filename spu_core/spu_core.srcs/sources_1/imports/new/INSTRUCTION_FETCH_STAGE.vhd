------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez

-- Create Date: 04/26/2019
-- Design Name: Instruction Fetch Stage
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     Gets the next pair of instructions - from instruction cache -
--     and send them to be decoded.
------------------------------------------------------------------------------
------------------ LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.ALL;
use work.COMPONENTS_PACKAGE.ALL;
use work.CONSTANTS_PACKAGE.ALL;

entity INSTRUCTION_FETCH_STAGE is
    port (
        -------------------- INPUTS --------------------
        CLK               : in STD_LOGIC; -- System Wide Synchronous Clock
        STALL_D           : in STD_LOGIC; -- Stall Flag from Decode Stage
        STALL_DEP         : in STD_LOGIC; -- Stall Flag from Dependency Stage
        BRANCH_FLUSH      : in STD_LOGIC; -- Flush Flag when Branch mispredict
        WRITE_CACHE_IF    : in STD_LOGIC; -- Write to cache, contorl signal (from LS)
        PC_BRNCH          : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Next value of the PC when branching
        INSTR_BLOCK_IN_IF : in STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0);          -- 128-Byte Data Read (32 Instructions) (from LS)
        -------------------- OUTPUTS --------------------
        STALL_RIB         : out STD_LOGIC := '0'; -- Stall Decode Stage when RIB signal 
        INSTR_PAIR_OUT_IF : out STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0) := (others => '0');        -- Instruction pair from cache
        PC_OUT            : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0') -- Current value of the PC
    );
end INSTRUCTION_FETCH_STAGE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of INSTRUCTION_FETCH_STAGE is
signal STOP_PC : STD_LOGIC := '0'; -- Stop PC flag when cache miss occurs
signal PC_NEXT : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0'); -- Next value of the PC
-- CACHE SIGNALS --
signal PC_CURR : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0'); -- Program Counter
signal HIT     : STD_LOGIC; -- Hit or Miss Flag form cache
signal INSTR_PAIR : STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0); -- Instruction pair from cache
begin
    -------------------- PROGRAM COUNTER PROCESS --------------------
    PC_PROC : process(CLK)
    begin
        if(rising_edge(CLK)) then
            PC_CURR <= PC_NEXT;
        end if;
    end process PC_PROC;
    
    ----- Send PC to Decode Stage -----
    PC_OUT <= PC_CURR;
            
    ----- Stop PC on Cache miss -----
    STOP_PC <= '0' when HIT = '1' else '1';
    
    ----- Send instruction pair to Decode stage -----
    INSTR_PAIR_OUT_IF <= INSTR_PAIR;
                         
    ----- Stall Decode Stage when Instruction is RIB -----
    STALL_RIB <= '1' when INSTR_PAIR((INSTR_PAIR_SIZE-1) downto 53) = "00000100011" else
                 '0';
    
    ----- Update current PC -----
    PC_NEXT <= PC_BRNCH when BRANCH_FLUSH  = '1' else
               PC_CURR  when STOP_PC = '1' or STALL_D = '1' or STALL_DEP = '1' else
               PC_CURR + 8;
    
    -------------------- INSTANTIATE INSTRUCTION CACHE --------------------
    ic : instruction_cache port map (
        -------------------- INPUTS --------------------
        CLK          => CLK,
        BRANCH_FLUSH => BRANCH_FLUSH,
        ADDR         => PC_CURR,
        WRITE_CACHE  => WRITE_CACHE_IF,
        INSTR_BLOCK  => INSTR_BLOCK_IN_IF,
        -------------------- OUTPUTS --------------------
        HIT          => HIT,
        DATA_OUT     => INSTR_PAIR
    );

end behavioral;
