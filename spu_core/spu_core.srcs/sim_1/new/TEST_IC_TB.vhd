-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components
use work.CONSTANTS_PACKAGE.ALL;
use work.SPU_CORE_ISA_PACKAGE.ALL;

-------------------- ENTITY DEFINITION --------------------
entity TEST_IC_TB is
end TEST_IC_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of TEST_IC_TB is
-------------------- INPUTS --------------------
signal CLK               : STD_LOGIC := '1';
--signal STALL_D_OUT       : STD_LOGIC := '0';
--signal STALL_DEP         : STD_LOGIC := '0';
--signal BRANCH_FLUSH      : STD_LOGIC := '0';
--signal WRITE_CACHE_IF    : STD_LOGIC := '0';
--signal PC_BRNCH          : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
--signal INSTR_BLOCK_IN_IF : STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0');  
---- DECODE STAGE --
--signal INSTR_PAIR_IN     : STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0) := (others => '0'); 
------------------------ OUTPUTS --------------------
--signal STALL_RIB         : STD_LOGIC := '0';
--signal INSTR_PAIR_OUT_IF : STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0) := (others => '0'); 
--signal PC_OUT_IF         : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
---- DECODE STAGE --
--signal STALL_E_O        : STD_LOGIC := '0';
--signal PC_OUT_D         : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
--signal INSTR_EVEN_OUT   : INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
--signal INSTR_ODD_OUT    : INSTR_DATA := ("01000000001", PERMUTE, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
--signal INSTR_EVEN_STALL : INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
--signal INSTR_ODD_STALL  : INSTR_DATA := ("01000000001", PERMUTE, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
--signal NOP_EVEN         : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0) := x"00200000";
--signal NOP_ODD          : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0) := x"40200000";
-------------------- CLOCK --------------------
constant CLK_PERIOD : TIME := 10ns;
begin            
    -------------------- CLK GENERATION PROCESS --------------------
    CLK <= not CLK after CLK_PERIOD/2;
    
--    IF_S : INSTRUCTION_FETCH_STAGE port map (
--        ----- INPUTS -----
--        CLK               => CLK,
--        STALL_D           => STALL_D_OUT,
--        STALL_DEP         => STALL_DEP,
--        BRANCH_FLUSH      => BRANCH_FLUSH,
--        WRITE_CACHE_IF    => WRITE_CACHE_IF,
--        PC_BRNCH          => PC_BRNCH,
--        INSTR_BLOCK_IN_IF => INSTR_BLOCK_IN_IF,
--        ----- OUTPUTS -----
--        STALL_RIB         => STALL_RIB,
--        INSTR_PAIR_OUT_IF => INSTR_PAIR_OUT_IF,
--        PC_OUT            => PC_OUT_IF
--    );
    
--    D : DECODE_STAGE port map (
--        ----- INPUTS -----
--        CLK              => CLK,
--        STALL_IF         => STALL_RIB,
--        FLUSH            => BRANCH_FLUSH,
--        INSTR_PAIR_IN    => INSTR_PAIR_IN,
--        PC_IN            => PC_OUT_IF,
--        ----- OUTPUTS -----
--        STALL_OUT        => STALL_D_OUT,
--        STALL_E_O        => STALL_E_O,
--        PC_OUT           => PC_OUT_D,
--        INSTR_EVEN_OUT   => INSTR_EVEN_OUT,
--        INSTR_ODD_OUT    => INSTR_ODD_OUT,
--        INSTR_EVEN_STALL => INSTR_EVEN_STALL,
--        INSTR_ODD_STALL  => INSTR_ODD_STALL
--    ); 

--    DEP : DEPENDENCY_STAGE port map (
--        ----- INPUTS -----
--        CLK     => CLK,
--        ----- OUTPUTS -----
--    );
  
--    ----- INSTRUCTION FETCH/DECODE STALL MULTIPLEXOR -----
--    NOP_EVEN(6 downto 0) <= "0000000" when (UNSIGNED(INSTR_EVEN_STALL.REG_DEST) > 0) else "0000001"; -- Prevent WAW Hazard when stalling                    
--    NOP_ODD(6 downto 0) <= "0000000" when (UNSIGNED(INSTR_ODD_STALL.REG_DEST) > 0) else "0000001";   -- Prevent WAW Hazard when stalling
--    INSTR_PAIR_IN <= INSTR_PAIR_OUT_IF when (STALL_D_OUT = '0') AND (STALL_E_O = '0') else
--                     (INSTR_ODD_STALL.INSTR & NOP_ODD) when ((STALL_D_OUT = '1') AND (STALL_E_O = '0')) else
--                     (INSTR_EVEN_STALL.INSTR & NOP_EVEN) when ((STALL_D_OUT = '1') AND (STALL_E_O = '1'));
                     
    -------------------- FILL LOCAL STORE PROCESS --------------------
    TEST_IC_TB : process
    begin    
--        WRITE_CACHE_IF <= '1';
--        INSTR_BLOCK_IN_IF <= (x"00000000000000000000000000000000000000000000000000000000000000000000000000000000") &
--                             (x"00000000000000000000000000000000000000000000000000000000000000000000000000000000") &
--                             (x"00000000000000000000000000000000000000003F6000003200000174000001C020000034000003") &
--                             (x"1C000000C0200000");
--        wait for CLK_PERIOD;            
        
--        WRITE_CACHE_IF <= '0';
--        INSTR_BLOCK_IN_IF <= (others => '0');    
        
--        wait for CLK_PERIOD * 2;

--        BRANCH_FLUSH <= '1';
--        PC_BRNCH <= "0000001100";
        
--        wait for CLK_PERIOD;
        
--        BRANCH_FLUSH <= '0';
        
        wait;
    end process TEST_IC_TB;
end behavioral;
