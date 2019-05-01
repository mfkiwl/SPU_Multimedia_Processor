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

entity INSTRUCTION_FETCH_STAGE is
    port (
        -------------------- INPUTS --------------------
        CLK               : in STD_LOGIC; -- System Wide Synchronous Clock
        BRANCH            : in STD_LOGIC; -- Brach control signal
        WRITE_CACHE_IF    : in STD_LOGIC; -- Write to cache contorl signal (from LS)
        PC_BRNCH          : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Next value of the PC when branching
        INSTR_BLOCK_IN_IF : in STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0);          -- 128-Byte Data Read (32 Instructions) (from LS)
        -------------------- OUTPUTS --------------------
        INSTR_PAIR_OUT_IF : out STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0) := (others => '0');        -- Instruction pair from cache
        PC_OUT            : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0') -- Next value of the PC
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
    -------------------- PROGRAM COUNTER --------------------
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
    
    ----- Update current PC -----
    PC_NEXT <= PC_BRNCH when BRANCH  = '1' else
               PC_CURR  when STOP_PC = '1' else
               PC_CURR + 8;
    
    -------------------- INSTANTIATE INSTRUCTION CACHE --------------------
    ic : instruction_cache port map (
        -------------------- INPUTS --------------------
        CLK         => CLK,
        ADDR        => PC_CURR,
        WRITE_CACHE => WRITE_CACHE_IF,
        INSTR_BLOCK => INSTR_BLOCK_IN_IF,
        -------------------- OUTPUTS --------------------
        HIT         => HIT,
        DATA_OUT    => INSTR_PAIR
    );
    
    -------------------- INSTRUCTION FETCH PROCESS --------------------
    IF_PROC : process(CLK) 
    begin
        if(rising_edge(CLK)) then                   
            -- Send instruction pair to decode stage --
            INSTR_PAIR_OUT_IF <= INSTR_PAIR;           
        end if;
    end process IF_PROC;

end behavioral;
