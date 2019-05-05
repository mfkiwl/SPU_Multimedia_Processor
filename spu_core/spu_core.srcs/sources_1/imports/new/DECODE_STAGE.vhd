-----------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez

-- Create Date: 04/16/2019
-- Design Name: Decode Stage
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     Decodes the instruction pairs recieved by the Instruction Cache.
--     Sends them to dependency stage after handling any structural or WAW hazards.
-----------------------------------------------------------------------------------
------------------ LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.COMPONENTS_PACKAGE.ALL;
use work.SPU_CORE_ISA_PACKAGE.ALL; -- Contains all instructions in ISA
use work.CONSTANTS_PACKAGE.ALL;

entity DECODE_STAGE is
port (
    -------------------- INPUTS --------------------
    CLK            : in STD_LOGIC; -- System Wide Synchronous Clock
    STALL_IF       : in STD_LOGIC; -- Stall flag from IF Stage
    FLUSH          : in STD_LOGIC; -- Flush Flag when Branch mispredict
    INSTR_PAIR_IN  : in STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0); -- Instruction Pair from Instruction Cache
    PC_IN          : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);  -- Current value of the PC
    -------------------- OUTPUTS --------------------
    STALL_OUT        : out STD_LOGIC := '0'; -- Stall IF stage when there's a structural hazard
    STALL_E_O        : out STD_LOGIC := '0'; -- Stall Even or Odd Instruction
    PC_OUT           : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0'); -- Current value of the PC
    INSTR_EVEN_OUT   : out INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    INSTR_ODD_OUT    : out INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    INSTR_EVEN_STALL : out INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    INSTR_ODD_STALL  : out INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'))
);
end DECODE_STAGE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of DECODE_STAGE is
begin
    ----- Send PC to Dependency Stage -----
    PC_OUT <= PC_IN;
    
    -------------------- DECODE STAGE PROCESS -------------------- 
    DECODE_PROC : process(CLK)
    variable INSTR_PAIR_S : INSTR_PAIR_STRUCTURE; 
    variable FIRST_RIB    : STD_LOGIC := '1';
    variable EVEN_INSTR_DATA : INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    variable ODD_INSTR_DATA  : INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    variable EVEN_STALL : INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    variable ODD_STALL  : INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    variable STOP_PROG  : BOOLEAN := false; -- Stop program 
    begin
        if(rising_edge(CLK)) then
            ----- GET INSTRUCTION PAIR STRUCTURE (EVEN & ODD) -----
            INSTR_PAIR_S := instr_search(INSTR_PAIR_IN);

            ----- HANDLE INSTRUCTION FORMAT -----
            EVEN_INSTR_DATA := get_instr_data(INSTR_PAIR_S.EVEN_INSTR, INSTR_PAIR_S.EVEN_S);
            ODD_INSTR_DATA  := get_instr_data(INSTR_PAIR_S.ODD_INSTR, INSTR_PAIR_S.ODD_S); 

            if(INSTR_PAIR_S.ODD_S.HALT = '1' OR STOP_PROG) then -- When stop signal is reached 
                STALL_OUT <= '1';
                ODD_STALL.INSTR := x"00200000"; -- Reset mux input
                ----- STOP signal will either be both instructions or only the first one -----
                ODD_INSTR_DATA  := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
                if(INSTR_PAIR_S.EVEN_S.HALT = '1') then
                    EVEN_INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
                else 
                    ----- If first instruction is not the STOP instruction -----
                    if(INSTR_PAIR_S.EVEN_S.UNIT = PERMUTE     OR 
                       INSTR_PAIR_S.EVEN_S.UNIT = LOCAL_STORE OR
                       INSTR_PAIR_S.EVEN_S.UNIT = BRANCH) then
                        ODD_INSTR_DATA := EVEN_INSTR_DATA;
                        EVEN_INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));   
                    end if;
                end if;
                STOP_PROG := true;
            elsif(FLUSH = '1') then -- Flush instructions - triggered by mispredicted branch
                STALL_E_O <= '0'; -- Reset pipe stall
                STALL_OUT <= '0'; -- Reset Structural Hazard stall
                FIRST_RIB := '1'; -- Reset RIB stall
                -- NOPs --
                EVEN_INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
                ODD_INSTR_DATA  := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
            elsif(INSTR_PAIR_S.STRUCT_HAZARD = '1') then -- When both instructions going to same pipe
                FIRST_RIB := '1'; -- Reset RIB stall
                if(INSTR_PAIR_S.HAZARD_E_O = '0') then -- Even Pipe Structural Hazard
                    STALL_E_O <= '0'; -- Even pipe stall
                    ODD_STALL := ODD_INSTR_DATA; -- Save original Odd Data
                    -- Update Odd Pipe Data --
                    ODD_INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
                else -- Odd Pipe Structural Hazard
                    STALL_E_O <= '1'; -- Odd pipe stall
                    EVEN_STALL := EVEN_INSTR_DATA; -- Save original Even Data
                    -- Update Even Pipe Data --
                    EVEN_INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0')); 
                end if;
                STALL_OUT <= '1'; -- Stall IF stage 
            ----- IF RIB INSTRUCTION - Stall until Instruction Cache is Full -----
            elsif(STALL_IF = '1' AND FIRST_RIB = '1') then
                STALL_OUT <= '0'; -- Reset Structural Hazard stall
                STALL_E_O <= '0'; -- Reset pipe stall
                
                FIRST_RIB := '0';
            elsif(STALL_IF = '1') then
                STALL_E_O <= '0'; -- Reset pipe stall
                STALL_OUT <= '0'; -- Reset Structural Hazard stall
                EVEN_INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
                ODD_INSTR_DATA  := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
            else 
                STALL_E_O <= '0'; -- Reset pipe stall
                STALL_OUT <= '0'; -- Reset Structural Hazard stall
                FIRST_RIB := '1'; -- Reset RIB stall
                ----- HANDLE WAW HAZARD -----
                if(EVEN_INSTR_DATA.REG_DEST = ODD_INSTR_DATA.REG_DEST) then
                    STALL_OUT <= '1'; -- Stall IF stage 
                    ----- Make sure first instruction doesn't get stalled -----
                    if(EVEN_INSTR_DATA.INSTR = INSTR_PAIR_IN((INSTR_SIZE-1) downto 0)) then
                        STALL_E_O <= '1'; -- Even pipe stall
                        EVEN_STALL := ODD_INSTR_DATA; -- Save original Odd Data
                        -- Update Odd Pipe Data --
                        ODD_INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
                    else 
                        STALL_E_O <= '0'; -- Odd pipe stall
                        ODD_STALL := EVEN_INSTR_DATA; -- Save original Even Data
                        -- Update Even Pipe Data --
                        EVEN_INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0')); 
                    end if;
                end if;
            end if; 

            ----- Output Even and Odd Instruction Data -----
            INSTR_EVEN_OUT <= EVEN_INSTR_DATA;
            INSTR_ODD_OUT  <= ODD_INSTR_DATA;
            INSTR_EVEN_STALL <= EVEN_STALL;
            INSTR_ODD_STALL  <= ODD_STALL;
        end if;
    end process DECODE_PROC;
end behavioral;
