-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components

-------------------- ENTITY DEFINITION --------------------
entity TEST_IC_TB is
end TEST_IC_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of TEST_IC_TB is
-------------------- INPUTS --------------------
signal CLK               : STD_LOGIC := '1';
signal BRANCH            : STD_LOGIC;
signal WRITE_CACHE_IF    : STD_LOGIC;
signal PC_BRNCH          : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
signal INSTR_BLOCK_IN_IF : STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0);  
-------------------- OUTPUTS --------------------
signal INSTR_PAIR_OUT_IF : STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0) := (others => '0'); 
signal PC_OUT            : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
-------------------- CLOCK --------------------
constant CLK_PERIOD : TIME := 10ns;
begin            
    -------------------- CLK GENERATION PROCESS --------------------
    CLK <= not CLK after CLK_PERIOD/2;
    
    IF_PM : INSTRUCTION_FETCH_STAGE port map (
        ----- INPUTS -----
        CLK => CLK,
        BRANCH => BRANCH,
        WRITE_CACHE_IF => WRITE_CACHE_IF,
        PC_BRNCH       => PC_BRNCH,
        INSTR_BLOCK_IN_IF => INSTR_BLOCK_IN_IF,
        ----- OUTPUTS -----
        INSTR_PAIR_OUT_IF => INSTR_PAIR_OUT_IF,
        PC_OUT        => PC_OUT
    );

    -------------------- FILL LOCAL STORE PROCESS --------------------
    TEST_IC_TB : process
    begin             
        BRANCH <= '0';
        PC_BRNCH <= (others => '0');
        WRITE_CACHE_IF <= '0';
        INSTR_BLOCK_IN_IF <= (others => '0');
        
        wait for CLK_PERIOD;
      
        WRITE_CACHE_IF <= '1';
        INSTR_BLOCK_IN_IF(1023 downto 704) <= (x"00000000111111112222222233333333AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF");
        INSTR_BLOCK_IN_IF(63 downto 0) <= (x"8888888899999999");

        wait for CLK_PERIOD;            
        
        WRITE_CACHE_IF <= '0';
        INSTR_BLOCK_IN_IF <= (others => '0');    
        
        wait for CLK_PERIOD;     
        
        wait;
    end process TEST_IC_TB;
end behavioral;
