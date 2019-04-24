--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/22/2019
-- Design Name: SPU Core Testbench
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--    Fills Local Store with the machine code produced 
--    by the assembler and executes the corresponding instructions.
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components

-------------------- ENTITY DEFINITION --------------------
entity SPU_CORE_TOP_MODULE_TB is
end SPU_CORE_TOP_MODULE_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of SPU_CORE_TOP_MODULE_TB is
signal CLK           : STD_LOGIC := '0';
signal FILL          : STD_LOGIC := '0';
signal SRAM_INSTR    : sram_type := (others => (others => '0'));
signal EVEN_OPCODE   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0)  := (others => '0'); 
signal RA_EVEN_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)    := (others => '0'); 
signal RB_EVEN_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)    := (others => '0'); 
signal RC_EVEN_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)    := (others => '0'); 
signal EVEN_REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)    := (others => '0');
signal EVEN_RI7      : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)     := (others => '0');   
signal EVEN_RI10     : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)    := (others => '0');
signal EVEN_RI16     : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)    := (others => '0');
signal ODD_OPCODE    : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0)  := (others => '0'); 
signal RA_ODD_ADDR   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)    := (others => '0');  
signal RB_ODD_ADDR   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)    := (others => '0');  
signal RC_ODD_ADDR   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)    := (others => '0');  
signal ODD_REG_DEST  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)    := (others => '0'); 
signal ODD_RI7       : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)     := (others => '0');  
signal ODD_RI10      : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)    := (others => '0'); 
signal ODD_RI16      : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)    := (others => '0'); 
signal ODD_RI18      : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0)    := (others => '0');
signal LS_DATA_IN    : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0'); 
-------------------- OUTPUTS --------------------
signal RESULT_PACKET_EVEN_OUT : RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0); 
signal RESULT_PACKET_ODD_OUT  : RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0);
signal LS_WE_OUT_EOP          : STD_LOGIC          := '0'; 
signal LS_RIB_OUT_EOP         : STD_LOGIC          := '0'; 
signal LS_DATA_OUT_EOP        : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)     := (others => '0'); 
signal LS_ADDR_OUT_EOP        : STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0)  := (others => '0'); 
signal INSTR_BLOCK_OUT_LS     : STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0');
-------------------- CLOCK --------------------
constant CLK_PERIOD : TIME := 10ns;
begin    
    -------------------- INSTANTIATE UNIT UNDER TEST --------------------
    UUT : SPU_CORE_TOP_MODULE port map (
        ----- INPUTS -----
        CLK           => CLK,
        EVEN_OPCODE   => EVEN_OPCODE,
        RA_EVEN_ADDR  => RA_EVEN_ADDR,
        RB_EVEN_ADDR  => RB_EVEN_ADDR,
        RC_EVEN_ADDR  => RC_EVEN_ADDR,
        EVEN_REG_DEST => EVEN_REG_DEST,
        EVEN_RI7      => EVEN_RI7, 
        EVEN_RI10     => EVEN_RI10,
        EVEN_RI16     => EVEN_RI16,
        ODD_OPCODE    => ODD_OPCODE,
        RA_ODD_ADDR   => RA_ODD_ADDR,
        RB_ODD_ADDR   => RB_ODD_ADDR,
        RC_ODD_ADDR   => RC_ODD_ADDR,
        ODD_REG_DEST  => ODD_REG_DEST,
        ODD_RI7       => ODD_RI7,
        ODD_RI10      => ODD_RI10,
        ODD_RI16      => ODD_RI16,
        ODD_RI18      => ODD_RI18,
        LS_DATA_IN    => LS_DATA_IN,
        ----- OUTPUTS -----
        RESULT_PACKET_EVEN_OUT => RESULT_PACKET_EVEN_OUT,
        RESULT_PACKET_ODD_OUT  => RESULT_PACKET_ODD_OUT,
        LS_WE_OUT_EOP          => LS_WE_OUT_EOP, 
        LS_RIB_OUT_EOP         => LS_RIB_OUT_EOP,
        LS_DATA_OUT_EOP        => LS_DATA_OUT_EOP,
        LS_ADDR_OUT_EOP        => LS_ADDR_OUT_EOP
    ); 
    
    ------------------ INSTANTIATE LOCAL STORE --------------------
    ls : local_store port map (
        ----- INPUTS -----
        WE_LS      => LS_WE_OUT_EOP,  
        RIB_LS     => LS_RIB_OUT_EOP,
        ADDR_LS    => LS_ADDR_OUT_EOP,
        FILL       => FILL,
        DATA_IN_LS => LS_DATA_OUT_EOP,
        SRAM_INSTR => SRAM_INSTR,
        ----- OUTPUTS -----
        DATA_OUT_LS        => LS_DATA_IN, 
        INSTR_BLOCK_OUT_LS => INSTR_BLOCK_OUT_LS
    );
    
    -------------------- CLK GENERATION PROCESS --------------------
    CLK <= not CLK after CLK_PERIOD/2;

    -------------------- SPU CORE PROCESS --------------------
    SIMULUS_PROC : process
    begin         
        -- Add Word
        EVEN_OPCODE   <= STD_LOGIC_VECTOR(to_unsigned(16#C0#, OPCODE_WIDTH));
        RA_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(1, ADDR_WIDTH));
        RB_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(1, ADDR_WIDTH));
        EVEN_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(2, ADDR_WIDTH));
        
        -- NOP (Execute)
        ODD_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(16#201#, OPCODE_WIDTH));
        
        wait for CLK_PERIOD;
        
        -- Add Word
        EVEN_OPCODE   <= STD_LOGIC_VECTOR(to_unsigned(16#C0#, OPCODE_WIDTH));
        RA_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(2, ADDR_WIDTH));
        RB_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(2, ADDR_WIDTH));
        EVEN_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(3, ADDR_WIDTH));
        
        -- NOP (Execute)
        ODD_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(16#201#, OPCODE_WIDTH));
        
        wait for CLK_PERIOD;
        
        -- Add Word
        EVEN_OPCODE   <= STD_LOGIC_VECTOR(to_unsigned(16#C0#, OPCODE_WIDTH));
        RA_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(3, ADDR_WIDTH));
        RB_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(3, ADDR_WIDTH));
        EVEN_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(4, ADDR_WIDTH));
        
        -- NOP (Execute)
        ODD_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(16#201#, OPCODE_WIDTH));
        
        wait for CLK_PERIOD;
        
        -- Add Word
        EVEN_OPCODE   <= STD_LOGIC_VECTOR(to_unsigned(16#C0#, OPCODE_WIDTH));
        RA_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(4, ADDR_WIDTH));
        RB_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(4, ADDR_WIDTH));
        EVEN_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(5, ADDR_WIDTH));
        
        -- NOP (Execute)
        ODD_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(16#201#, OPCODE_WIDTH));
        
        wait for CLK_PERIOD;
        
        -- Add Word
        EVEN_OPCODE   <= STD_LOGIC_VECTOR(to_unsigned(16#C0#, OPCODE_WIDTH));
        RA_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(2, ADDR_WIDTH));
        RB_EVEN_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(2, ADDR_WIDTH));
        EVEN_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(8, ADDR_WIDTH));
        
        -- NOP (Execute)
        ODD_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(16#201#, OPCODE_WIDTH));
        
        wait for CLK_PERIOD;
        
        EVEN_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(16#1#, OPCODE_WIDTH));
        
        -- NOP (Execute)
        ODD_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(16#201#, OPCODE_WIDTH));
        
        wait;
    end process SIMULUS_PROC;
end behavioral;
