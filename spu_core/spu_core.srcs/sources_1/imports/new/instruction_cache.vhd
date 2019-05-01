------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez

-- Create Date: 04/26/2019
-- Design Name: Instruction Cache
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     128-Byte DMA Cache.
--     Holds, at most, 32 Instructions of the current program 
--     executing on the CPU.
------------------------------------------------------------------------------
------------------ LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.ALL;
use work.COMPONENTS_PACKAGE.ALL;
use work.SPU_CORE_ISA_PACKAGE.ALL;

entity instruction_cache is
port (
    -------------------- INPUTS --------------------  
    CLK         : in STD_LOGIC; -- System Wide Synchronous Clock
    ADDR        : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Block address
    WRITE_CACHE : in STD_LOGIC; -- Cache write enable control signal
    INSTR_BLOCK : in STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0); -- 128-Byte Data Read (32 Instructions) (from LS)
    -------------------- OUTPUTS --------------------
    HIT         : out STD_LOGIC := '0'; -- Is the instruction pair in cache?
    DATA_OUT    : out STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0) := (others => '0') -- Instruction pair
);
end instruction_cache;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of instruction_cache is
signal CACHE : instr_cache_type := (others => ('0', (others => '0'), (others => '0')));
begin
    -------------------- CACHE PROCESS --------------------
    CACHE_PROC : process(ADDR, WRITE_CACHE, INSTR_BLOCK)
    variable INSTR_i1 : NATURAL := 31; -- Index 1 of current instruction in Cache block Data
    variable INSTR_i2 : NATURAL := 0;  -- Index 2 of current instruction in Cache block Data
    variable INSTR_BLOCK_i1 : NATURAL := 1023; -- Index 1 of next instruction in Cache block
    variable INSTR_BLOCK_i2 : NATURAL := 992;  -- Index 2 of next instruction in Cache block
    variable INSTR_ADDR : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Address of instructions in cache
    variable INDEX : NATURAL := 0;
    begin
        ----- Fill Instruction Cache with next set of instructions -----
        if(WRITE_CACHE = '1') then
            INSTR_ADDR := ADDR;
            for i in 0 to (CACHE_HEIGHT-1) loop
                INSTR_ADDR := INSTR_ADDR + 1;
                CACHE(i).TAG <= INSTR_ADDR((LS_INSTR_SECTION_SIZE - 1) downto 7); -- TAG = MS 5 bit of Instr address
                CACHE(i).DATA(INSTR_i1 downto INSTR_i2) <= INSTR_BLOCK(INSTR_BLOCK_i1 downto INSTR_BLOCK_i2); -- 1st instruction in current block
                CACHE(i).DATA((INSTR_i1+32) downto (INSTR_i2+32)) <= INSTR_BLOCK((INSTR_BLOCK_i1-32) downto (INSTR_BLOCK_i2-32)); -- 2nd instruction in current block
                CACHE(i).V <= '1';
                INSTR_BLOCK_i1 := INSTR_BLOCK_i1 - 64; -- Go to next pair of instructions
                INSTR_BLOCK_i2 := INSTR_BLOCK_i2 - 64; 
            end loop;
        else 
            INDEX := to_integer(ADDR(6 downto 3));
            ----- CHECK FOR HIT OR MISS -----
            if((CACHE(INDEX).V = '1') and (CACHE(INDEX).TAG = ADDR((LS_INSTR_SECTION_SIZE - 1) downto 7))) then -- If HIT
                HIT <= '1';
                DATA_OUT <= CACHE(INDEX).DATA; 
            else -- If MISS
                HIT <= '0';
                DATA_OUT <= (others => '0'); -- Clear first
                DATA_OUT(31 downto 21) <= STD_LOGIC_VECTOR(to_unsigned(16#23#, OPCODE_WIDTH_11)); -- Send RIB signal to fill instruction 
            end if;
        end if;
    end process CACHE_PROC;

end behavioral;
