 --------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 04/09/2019
-- Design Name: Execution Stage
-- Tool versions: Vivado v2018.3 (64-bit)
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.COMPONENTS_PACKAGE.ALL; 
use work.CONSTANTS_PACKAGE.ALL;

-------------------- ENTITY DEFINITION --------------------
entity EXECUTION_STAGE is
port (
    -------------------- INPUTS --------------------
    CLK : in STD_LOGIC;
    EVEN_OPCODE_EXE   : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
    ODD_OPCODE_EXE    : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
    RA_EVEN_DATA_EXE  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
    RB_EVEN_DATA_EXE  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
    RC_EVEN_DATA_EXE  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
    RA_ODD_DATA_EXE   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
    RB_ODD_DATA_EXE   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
    RC_ODD_DATA_EXE   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
    RA_EVEN_ADDR_EXE  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    RB_EVEN_ADDR_EXE  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    RC_EVEN_ADDR_EXE  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    RA_ODD_ADDR_EXE   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    RB_ODD_ADDR_EXE   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    RC_ODD_ADDR_EXE   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    EVEN_RI7_EXE      : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);
    EVEN_RI10_EXE     : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
    EVEN_RI16_EXE     : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
    ODD_RI7_EXE       : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);
    ODD_RI10_EXE      : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
    ODD_RI16_EXE      : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
    ODD_RI18_EXE      : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);
    EVEN_REG_DEST_EXE : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    ODD_REG_DEST_EXE  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    LS_DATA_IN        : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); 
    -------------------- OUTPUTS --------------------
    PC_BRNCH                  : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Next value of the PC when branching
    BRANCH_FLUSH              : out STD_LOGIC;
    RESULT_PACKET_EVEN_OUT_FC : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0);
    RESULT_PACKET_ODD_OUT_FC  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0);
    LS_WE_OUT_EOP             : out STD_LOGIC := '0';
    LS_RIB_OUT_EOP            : out STD_LOGIC := '0';
    LS_DATA_OUT_EOP           : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0');
    LS_ADDR_OUT_EOP           : out STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0) := (others => '0')
);
end EXECUTION_STAGE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of EXECUTION_STAGE is
-------------------- FORWARDING MACRO -> EVEN ODD PIPES SIGNALS --------------------
signal RA_EVEN_DATA_OUT_FM  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RB_EVEN_DATA_OUT_FM  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RC_EVEN_DATA_OUT_FM  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RA_ODD_DATA_OUT_FM   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RB_ODD_DATA_OUT_FM   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RC_ODD_DATA_OUT_FM   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal EVEN_RI7_OUT_FM      : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);
signal EVEN_RI10_OUT_FM     : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
signal EVEN_RI16_OUT_FM     : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
signal ODD_RI7_OUT_FM       : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  
signal ODD_RI10_OUT_FM      : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
signal ODD_RI16_OUT_FM      : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);  
signal ODD_RI18_OUT_FM      : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);  
signal EVEN_OPCODE_OUT_FM   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
signal ODD_OPCODE_OUT_FM    : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
signal EVEN_REG_DEST_OUT_FM : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
signal ODD_REG_DEST_OUT_FM  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
-------------------- EVEN ODD PIPES -> FORWARDING CIRCUITS SIGNALS --------------------
signal RESULT_PACKET_EVEN_OUT_EOP : RESULT_PACKET_EVEN;
signal RESULT_PACKET_ODD_OUT_EOP  : RESULT_PACKET_ODD;
begin
-------------------- INSTANTIATE FORWARDING MACRO/CIRCUIT --------------------
    fwc : forwarding_macro_circuits port map (
        ----- INPUTS -----
        CLK              => CLK,
        EVEN_OPCODE_FM   => EVEN_OPCODE_EXE,     
        ODD_OPCODE_FM    => ODD_OPCODE_EXE,     
        RA_EVEN_DATA_FM  => RA_EVEN_DATA_EXE,    
        RB_EVEN_DATA_FM  => RB_EVEN_DATA_EXE,    
        RC_EVEN_DATA_FM  => RC_EVEN_DATA_EXE,     
        RA_ODD_DATA_FM   => RA_ODD_DATA_EXE,  
        RB_ODD_DATA_FM   => RB_ODD_DATA_EXE,     
        RC_ODD_DATA_FM   => RC_ODD_DATA_EXE,
        RA_EVEN_ADDR_FM  => RA_EVEN_ADDR_EXE,
        RB_EVEN_ADDR_FM  => RB_EVEN_ADDR_EXE, 
        RC_EVEN_ADDR_FM  => RC_EVEN_ADDR_EXE, 
        RA_ODD_ADDR_FM   => RA_ODD_ADDR_EXE,
        RB_ODD_ADDR_FM   => RB_ODD_ADDR_EXE,
        RC_ODD_ADDR_FM   => RC_ODD_ADDR_EXE,
        EVEN_RI7_FM      => EVEN_RI7_EXE,
        EVEN_RI10_FM     => EVEN_RI10_EXE,
        EVEN_RI16_FM     => EVEN_RI16_EXE,
        ODD_RI7_FM       => ODD_RI7_EXE,
        ODD_RI10_FM      => ODD_RI10_EXE,
        ODD_RI16_FM      => ODD_RI16_EXE,
        ODD_RI18_FM      => ODD_RI18_EXE,  
        EVEN_REG_DEST_FM => EVEN_REG_DEST_EXE, 
        ODD_REG_DEST_FM  => ODD_REG_DEST_EXE,
        RESULT_PACKET_EVEN_FC => RESULT_PACKET_EVEN_OUT_EOP,
        RESULT_PACKET_ODD_FC  => RESULT_PACKET_ODD_OUT_EOP,
        ----- OUTPUTS -----
        RA_EVEN_DATA_OUT_FM       => RA_EVEN_DATA_OUT_FM,
        RB_EVEN_DATA_OUT_FM       => RB_EVEN_DATA_OUT_FM,
        RC_EVEN_DATA_OUT_FM       => RC_EVEN_DATA_OUT_FM,
        RA_ODD_DATA_OUT_FM        => RA_ODD_DATA_OUT_FM,
        RB_ODD_DATA_OUT_FM        => RB_ODD_DATA_OUT_FM,
        RC_ODD_DATA_OUT_FM        => RC_ODD_DATA_OUT_FM, 
        EVEN_RI7_OUT_FM           => EVEN_RI7_OUT_FM,
        EVEN_RI10_OUT_FM          => EVEN_RI10_OUT_FM, 
        EVEN_RI16_OUT_FM          => EVEN_RI16_OUT_FM, 
        ODD_RI7_OUT_FM            => ODD_RI7_OUT_FM,
        ODD_RI10_OUT_FM           => ODD_RI10_OUT_FM,
        ODD_RI16_OUT_FM           => ODD_RI16_OUT_FM, 
        ODD_RI18_OUT_FM           => ODD_RI18_OUT_FM, 
        EVEN_OPCODE_OUT_FM        => EVEN_OPCODE_OUT_FM,
        ODD_OPCODE_OUT_FM         => ODD_OPCODE_OUT_FM, 
        EVEN_REG_DEST_OUT_FM      => EVEN_REG_DEST_OUT_FM,
        ODD_REG_DEST_OUT_FM       => ODD_REG_DEST_OUT_FM,
        RESULT_PACKET_EVEN_OUT_FC => RESULT_PACKET_EVEN_OUT_FC,
        RESULT_PACKET_ODD_OUT_FC  => RESULT_PACKET_ODD_OUT_FC
    );
    
    -------------------- INSTANTIATE EVEN & ODD PIPES --------------------
    eop : even_odd_pipes port map (
        ----- INPUTS -----
        CLK => CLK,
        EVEN_RI7_EOP         => EVEN_RI7_OUT_FM, 
        EVEN_RI10_EOP        => EVEN_RI10_OUT_FM,   
        EVEN_RI16_EOP        => EVEN_RI16_OUT_FM, 
        EVEN_REG_DEST_EOP    => EVEN_REG_DEST_OUT_FM,
        ODD_RI7_EOP          => ODD_RI7_OUT_FM,    
        ODD_RI10_EOP         => ODD_RI10_OUT_FM,  
        ODD_RI16_EOP         => ODD_RI16_OUT_FM,    
        ODD_RI18_EOP         => ODD_RI18_OUT_FM,    
        ODD_REG_DEST_EOP     => ODD_REG_DEST_OUT_FM, 
        RA_EVEN_DATA_EOP     => RA_EVEN_DATA_OUT_FM,
        RB_EVEN_DATA_EOP     => RB_EVEN_DATA_OUT_FM,
        RC_EVEN_DATA_EOP     => RC_EVEN_DATA_OUT_FM,
        RA_ODD_DATA_EOP      => RA_ODD_DATA_OUT_FM,
        RB_ODD_DATA_EOP      => RB_ODD_DATA_OUT_FM,
        RC_ODD_DATA_EOP      => RC_ODD_DATA_OUT_FM,
        EVEN_OPCODE_EOP      => EVEN_OPCODE_OUT_FM,
        ODD_OPCODE_EOP       => ODD_OPCODE_OUT_FM,
        LOCAL_STORE_DATA_EOP => LS_DATA_IN,
        -------------------- OUTPUTS --------------------
        PC_BRNCH                   => PC_BRNCH,
        BRANCH_FLUSH               => BRANCH_FLUSH,
        LS_WE_OUT_EOP              => LS_WE_OUT_EOP,
        LS_RIB_OUT_EOP             => LS_RIB_OUT_EOP,
        LS_DATA_OUT_EOP            => LS_DATA_OUT_EOP,
        LS_ADDR_OUT_EOP            => LS_ADDR_OUT_EOP,
        RESULT_PACKET_EVEN_OUT_EOP => RESULT_PACKET_EVEN_OUT_EOP,
        RESULT_PACKET_ODD_OUT_EOP  => RESULT_PACKET_ODD_OUT_EOP
    );
end behavioral;
