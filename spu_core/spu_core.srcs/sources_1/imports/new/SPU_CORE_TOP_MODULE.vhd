----------------------------------------------------------------------------------
---- Company: Stony Brook University
---- Engineer: Wilmer Suarez
----
---- Create Date: 05/04/2019
---- Design Name: SPU Core 
---- Tool versions: Vivado v2018.3 (64-bit)
----------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL;   -- SPU Core Components
use work.CONSTANTS_PACKAGE.ALL;    -- Common Constants
use work.SPU_CORE_ISA_PACKAGE.ALL; -- ISA Data Structures

-------------------- ENTITY DEFINITION --------------------
entity SPU_CORE_TOP_MODULE is
port (
    -------------------- INPUTS --------------------
    CLK            : in STD_LOGIC; -- System Wide Synchronous Clock
    INSTR_BLOCK    : in STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0); -- 128-bytes (32 Instructions) from Local Store
    LS_DATA_IN     : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);     -- 16-Byte data from Local Store
    -------------------- OUTPUTS --------------------
    RESULT_PACKET_EVEN_OUT : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0); -- Even Pipe Result Packet to Write Back Stage 
    RESULT_PACKET_ODD_OUT  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0, '0', (others => '0'), (others => '0'), '0'); -- Odd Pipe Result Packet to Write Back Stage 
    LS_PC_OUT_EXE          : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Current PC value to be used by Local Store when RIB
    LS_WE_OUT_EOP          : out STD_LOGIC          := '0'; -- Local Store Write Enable
    LS_RIB_OUT_EOP         : out STD_LOGIC          := '0'; -- Local Store Read Instruction Block Flag
    LS_DATA_OUT_EOP        : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0'); -- Local Store Data IN
    LS_ADDR_OUT_EOP        : out STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0) := (others => '0')  -- Local Store Addr IN
);
end SPU_CORE_TOP_MODULE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of SPU_CORE_TOP_MODULE is
-------------------- INSTRUCTION FETCH -> DECODE STAGE SIGNALS --------------------
signal STALL_RIB          : STD_LOGIC := '0';
signal INSTR_PAIR_OUT_IF  : STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0) := (others => '0'); 
signal PC_OUT_IF          : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
signal INSTR_PAIR_IN      : STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0) := (others => '0'); 
-------------------- DECODE -> DEPENDENCY STAGE SIGNALS --------------------
signal STALL_E_O          : STD_LOGIC := '0';
signal STALL_D_OUT        : STD_LOGIC := '0';
signal PC_OUT_D           : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
signal INSTR_EVEN_OUT     : INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
signal INSTR_ODD_OUT      : INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
signal INSTR_EVEN_STALL   : INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
signal INSTR_ODD_STALL    : INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
signal NOP_EVEN           : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0) := x"00200000";
signal NOP_ODD            : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0) := x"40200000";
---------------------- DEPENDENCY -> REGISTER FILE STAGE SIGNALS ---------------------- 
signal INSTR_EVEN_DEP_IN  : INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
signal INSTR_ODD_DEP_IN   : INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
signal STALL_DEP_OUT      : STD_LOGIC  := '0';
signal INSTR_EVEN_OUT_DEP : INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
signal INSTR_ODD_OUT_DEP  : INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
signal PC_OUT_DEP         : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
signal EVEN_OPCODE_DEP    : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := "00000000001";
signal ODD_OPCODE_DEP     : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := "01000000001";
signal RA_EVEN_ADDR_DEP   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
signal RB_EVEN_ADDR_DEP   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal RC_EVEN_ADDR_DEP   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal RA_ODD_ADDR_DEP    : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal RB_ODD_ADDR_DEP    : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal RC_ODD_ADDR_DEP    : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal EVEN_RI7_DEP       : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0');  
signal EVEN_RI10_DEP      : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0');
signal EVEN_RI16_DEP      : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0');
signal ODD_RI7_DEP        : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0'); 
signal ODD_RI10_DEP       : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); 
signal ODD_RI16_DEP       : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0');
signal ODD_RI18_DEP       : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0)   := (others => '0');
signal EVEN_REG_DEST_DEP  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal ODD_REG_DEST_DEP   : STD_LOGIC_VECTOR ((ADDR_WIDTH-1) downto 0)  := (others => '0');
------------------ REGISTER FILE -> DEPENDENCY STAGE --------------------
signal PREV_IN_EVEN       :  PREV_DATA := ((others => '0'), TRUE);
signal PREV_IN_ODD        :  PREV_DATA := ((others => '0'), TRUE);
signal PREV_OUT_EVEN      :  PREV_DATA := ((others => '0'), TRUE);
signal PREV_OUT_ODD       :  PREV_DATA := ((others => '0'), TRUE);
-------------------- REGISTER FILE -> FORWARDING MACRO SIGNALS --------------------
signal EVEN_OPCODE_OUT_RF   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');
signal ODD_OPCODE_OUT_RF    : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');
signal RA_EVEN_DATA_OUT_RF  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
signal RB_EVEN_DATA_OUT_RF  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
signal RC_EVEN_DATA_OUT_RF  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
signal RA_ODD_DATA_OUT_RF   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
signal RB_ODD_DATA_OUT_RF   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
signal RC_ODD_DATA_OUT_RF   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
signal RA_EVEN_ADDR_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal RB_EVEN_ADDR_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal RC_EVEN_ADDR_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal RA_ODD_ADDR_OUT_RF   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal RB_ODD_ADDR_OUT_RF   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal RC_ODD_ADDR_OUT_RF   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal EVEN_RI7_OUT_RF      : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)  := (others => '0');
signal EVEN_RI10_OUT_RF     : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');
signal EVEN_RI16_OUT_RF     : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');
signal ODD_RI7_OUT_RF       : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)  := (others => '0');
signal ODD_RI10_OUT_RF      : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');
signal ODD_RI16_OUT_RF      : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');
signal ODD_RI18_OUT_RF      : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');
signal EVEN_REG_DEST_OUT_RF : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal ODD_REG_DEST_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal PC_OUT_RF            : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
-------------------- FORWARDING CIRCUITS -> REGISTER FILE SIGNALS --------------------
signal RESULT_PACKET_EVEN_OUT_FC : RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0);
signal RESULT_PACKET_ODD_OUT_FC  : RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0, '0', (others => '0'), (others => '0'), '0');
-------------------- RIB SIGNALS  --------------------
signal INSTR_BLOCK_IN : STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0');
signal WRITE_CACHE_IN : STD_LOGIC := '0';
-------------------- BRANCH UNIT SIGNALS --------------------
signal BRANCH_FLUSH  : STD_LOGIC := '0';
signal PC_BRNCH      : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
begin
----======================================= INSTRUCTION FETCH STAGE ========================================--
    IF_STAGE : INSTRUCTION_FETCH_STAGE port map (
        ----- INPUTS -----
        CLK               => CLK,
        STALL_D           => STALL_D_OUT,
        STALL_DEP         => STALL_DEP_OUT,
        BRANCH_FLUSH      => BRANCH_FLUSH,
        WRITE_CACHE_IF    => WRITE_CACHE_IN,
        PC_BRNCH          => PC_BRNCH,
        INSTR_BLOCK_IN_IF => INSTR_BLOCK_IN,
        ----- OUTPUTS -----
        STALL_RIB         => STALL_RIB,
        INSTR_PAIR_OUT_IF => INSTR_PAIR_OUT_IF,
        PC_OUT            => PC_OUT_IF
    );

    -------------------- INSTRUCTION FETCH/DECODE STAGE STALL MULTIPLEXOR -------------------- 
    NOP_EVEN(6 downto 0) <= "0000000" when (UNSIGNED(INSTR_EVEN_STALL.REG_DEST) > 0) else "0000001"; -- Prevent WAW Hazard when stalling                    
    NOP_ODD(6 downto 0) <= "0000000" when (UNSIGNED(INSTR_ODD_STALL.REG_DEST) > 0) else "0000001";   -- Prevent WAW Hazard when stalling
    INSTR_PAIR_IN <= INSTR_PAIR_OUT_IF when (STALL_D_OUT = '0') AND (STALL_E_O = '0') else
                     (INSTR_ODD_STALL.INSTR & NOP_ODD) when ((STALL_D_OUT = '1') AND (STALL_E_O = '0')) else
                     (INSTR_EVEN_STALL.INSTR & NOP_EVEN) when ((STALL_D_OUT = '1') AND (STALL_E_O = '1'));

----============================================= DECODE STAGE =============================================--
    DEC_STAGE : DECODE_STAGE port map (
        ----- INPUTS -----
        CLK              => CLK,
        STALL_IF         => STALL_RIB,
        FLUSH            => BRANCH_FLUSH,
        INSTR_PAIR_IN    => INSTR_PAIR_IN,
        PC_IN            => PC_OUT_IF,
        ----- OUTPUTS -----
        STALL_OUT        => STALL_D_OUT,
        STALL_E_O        => STALL_E_O,
        PC_OUT           => PC_OUT_D,
        INSTR_EVEN_OUT   => INSTR_EVEN_OUT,
        INSTR_ODD_OUT    => INSTR_ODD_OUT,
        INSTR_EVEN_STALL => INSTR_EVEN_STALL,
        INSTR_ODD_STALL  => INSTR_ODD_STALL
    ); 

-------------------- DECODE/DEPENDENCY STAGE EVEN INSTRUCTION STALL MULTIPLEXOR --------------------     
    INSTR_EVEN_DEP_IN <= INSTR_EVEN_OUT when (STALL_DEP_OUT = '0') else INSTR_EVEN_OUT_DEP;
-------------------- DECODE/DEPENDENCY STAGE ODD INSTRUCTION STALL MULTIPLEXOR --------------------
    INSTR_ODD_DEP_IN  <= INSTR_ODD_OUT when (STALL_DEP_OUT = '0') else INSTR_ODD_OUT_DEP;

----======================================= DEPENDENCY & ISSUE STAGE =======================================--
    DEP_STAGE : DEPENDENCY_ISSUE_STAGE port map (
        -------------------- INPUTS --------------------
        CLK                => CLK,
        PC_IN              => PC_OUT_D,
        INSTR_EVEN_IN      => INSTR_EVEN_DEP_IN,
        INSTR_ODD_IN       => INSTR_ODD_DEP_IN,
        RF_IN_EVEN         => PREV_IN_EVEN,
        RF_IN_ODD          => PREV_IN_ODD,
        RF_OUT_EVEN        => PREV_OUT_EVEN,
        RF_OUT_ODD         => PREV_OUT_ODD,
        -------------------- OUTPUTS --------------------
        STALL_DEP_OUT      => STALL_DEP_OUT,
        INSTR_EVEN_OUT_DEP => INSTR_EVEN_OUT_DEP, 
        INSTR_ODD_OUT_DEP  => INSTR_ODD_OUT_DEP,
        PC_OUT_DEP         => PC_OUT_DEP,
        EVEN_OPCODE_DEP    => EVEN_OPCODE_DEP,
        ODD_OPCODE_DEP     => ODD_OPCODE_DEP,
        RA_EVEN_ADDR_DEP   => RA_EVEN_ADDR_DEP,
        RB_EVEN_ADDR_DEP   => RB_EVEN_ADDR_DEP,
        RC_EVEN_ADDR_DEP   => RC_EVEN_ADDR_DEP,
        RA_ODD_ADDR_DEP    => RA_ODD_ADDR_DEP,
        RB_ODD_ADDR_DEP    => RB_ODD_ADDR_DEP,
        RC_ODD_ADDR_DEP    => RC_ODD_ADDR_DEP,
        EVEN_RI7_DEP       => EVEN_RI7_DEP,
        EVEN_RI10_DEP      => EVEN_RI10_DEP,
        EVEN_RI16_DEP      => EVEN_RI16_DEP,
        ODD_RI7_DEP        => ODD_RI7_DEP,
        ODD_RI10_DEP       => ODD_RI10_DEP,
        ODD_RI16_DEP       => ODD_RI16_DEP,
        ODD_RI18_DEP       => ODD_RI18_DEP,
        EVEN_REG_DEST_DEP  => EVEN_REG_DEST_DEP,
        ODD_REG_DEST_DEP   => ODD_REG_DEST_DEP
    );
----========================================= REGISTER FETCH STAGE =========================================--
    RF_STAGE : REGISTER_FETCH_STAGE port map ( 
        -------------------- INPUTS --------------------
        CLK              => CLK,
        PC_IN            => PC_OUT_DEP,
        EVEN_OPCODE_RF   => EVEN_OPCODE_DEP,
        ODD_OPCODE_RF    => ODD_OPCODE_DEP,  
        RA_EVEN_ADDR_RF  => RA_EVEN_ADDR_DEP, 
        RB_EVEN_ADDR_RF  => RB_EVEN_ADDR_DEP,
        RC_EVEN_ADDR_RF  => RC_EVEN_ADDR_DEP,   
        RA_ODD_ADDR_RF   => RA_ODD_ADDR_DEP,
        RB_ODD_ADDR_RF   => RB_ODD_ADDR_DEP,
        RC_ODD_ADDR_RF   => RC_ODD_ADDR_DEP,
        EVEN_RI7_RF      => EVEN_RI7_DEP,  
        EVEN_RI10_RF     => EVEN_RI10_DEP,   
        EVEN_RI16_RF     => EVEN_RI16_DEP,     
        ODD_RI7_RF       => ODD_RI7_DEP,       
        ODD_RI10_RF      => ODD_RI10_DEP,      
        ODD_RI16_RF      => ODD_RI16_DEP,      
        ODD_RI18_RF      => ODD_RI18_DEP,     
        EVEN_REG_DEST_RF => EVEN_REG_DEST_DEP, 
        ODD_REG_DEST_RF  => ODD_REG_DEST_DEP,
        RESULT_PACKET_EVEN_IN_FC => RESULT_PACKET_EVEN_OUT_FC,   
        RESULT_PACKET_ODD_IN_FC  => RESULT_PACKET_ODD_OUT_FC,
        -------------------- OUTPUTS --------------------
        PC_OUT_RF            => PC_OUT_RF,
        PREV_IN_EVEN         => PREV_IN_EVEN,
        PREV_IN_ODD          => PREV_IN_ODD,
        PREV_OUT_EVEN        => PREV_OUT_EVEN,
        PREV_OUT_ODD         => PREV_OUT_ODD,
        EVEN_OPCODE_OUT_RF   => EVEN_OPCODE_OUT_RF,
        ODD_OPCODE_OUT_RF    => ODD_OPCODE_OUT_RF,
        RA_EVEN_DATA_OUT_RF  => RA_EVEN_DATA_OUT_RF,
        RB_EVEN_DATA_OUT_RF  => RB_EVEN_DATA_OUT_RF,
        RC_EVEN_DATA_OUT_RF  => RC_EVEN_DATA_OUT_RF, 
        RA_ODD_DATA_OUT_RF   => RA_ODD_DATA_OUT_RF,
        RB_ODD_DATA_OUT_RF   => RB_ODD_DATA_OUT_RF,
        RC_ODD_DATA_OUT_RF   => RC_ODD_DATA_OUT_RF,
        RA_EVEN_ADDR_OUT_RF  => RA_EVEN_ADDR_OUT_RF,
        RB_EVEN_ADDR_OUT_RF  => RB_EVEN_ADDR_OUT_RF,
        RC_EVEN_ADDR_OUT_RF  => RC_EVEN_ADDR_OUT_RF,
        RA_ODD_ADDR_OUT_RF   => RA_ODD_ADDR_OUT_RF,
        RB_ODD_ADDR_OUT_RF   => RB_ODD_ADDR_OUT_RF, 
        RC_ODD_ADDR_OUT_RF   => RC_ODD_ADDR_OUT_RF, 
        EVEN_RI7_OUT_RF      => EVEN_RI7_OUT_RF, 
        EVEN_RI10_OUT_RF     => EVEN_RI10_OUT_RF, 
        EVEN_RI16_OUT_RF     => EVEN_RI16_OUT_RF,
        ODD_RI7_OUT_RF       => ODD_RI7_OUT_RF, 
        ODD_RI10_OUT_RF      => ODD_RI10_OUT_RF,
        ODD_RI16_OUT_RF      => ODD_RI16_OUT_RF, 
        ODD_RI18_OUT_RF      => ODD_RI18_OUT_RF,
        EVEN_REG_DEST_OUT_RF => EVEN_REG_DEST_OUT_RF,
        ODD_REG_DEST_OUT_RF  => ODD_REG_DEST_OUT_RF
    );
  
----========================================= EXECUTION & WRITEBACK STAGES =========================================--
    EXE_STAGE : EXECUTION_STAGE port map (
        -------------------- INPUTS --------------------
        CLK               => CLK, 
        PC_IN             => PC_OUT_RF,
        EVEN_OPCODE_EXE   => EVEN_OPCODE_OUT_RF,
        ODD_OPCODE_EXE    => ODD_OPCODE_OUT_RF,
        RA_EVEN_DATA_EXE  => RA_EVEN_DATA_OUT_RF,
        RB_EVEN_DATA_EXE  => RB_EVEN_DATA_OUT_RF,
        RC_EVEN_DATA_EXE  => RC_EVEN_DATA_OUT_RF,
        RA_ODD_DATA_EXE   => RA_ODD_DATA_OUT_RF,
        RB_ODD_DATA_EXE   => RB_ODD_DATA_OUT_RF,
        RC_ODD_DATA_EXE   => RC_ODD_DATA_OUT_RF,
        RA_EVEN_ADDR_EXE  => RA_EVEN_ADDR_OUT_RF,
        RB_EVEN_ADDR_EXE  => RB_EVEN_ADDR_OUT_RF,
        RC_EVEN_ADDR_EXE  => RC_EVEN_ADDR_OUT_RF,
        RA_ODD_ADDR_EXE   => RA_ODD_ADDR_OUT_RF,
        RB_ODD_ADDR_EXE   => RB_ODD_ADDR_OUT_RF,
        RC_ODD_ADDR_EXE   => RC_ODD_ADDR_OUT_RF,
        EVEN_RI7_EXE      => EVEN_RI7_OUT_RF,
        EVEN_RI10_EXE     => EVEN_RI10_OUT_RF,
        EVEN_RI16_EXE     => EVEN_RI16_OUT_RF,
        ODD_RI7_EXE       => ODD_RI7_OUT_RF,
        ODD_RI10_EXE      => ODD_RI10_OUT_RF,
        ODD_RI16_EXE      => ODD_RI16_OUT_RF,
        ODD_RI18_EXE      => ODD_RI18_OUT_RF,
        EVEN_REG_DEST_EXE => EVEN_REG_DEST_OUT_RF,
        ODD_REG_DEST_EXE  => ODD_REG_DEST_OUT_RF,
        LS_DATA_IN        => LS_DATA_IN,
        INSTR_BLOCK_DATA  => INSTR_BLOCK,
        -------------------- OUTPUTS --------------------
        INSTR_BLOCK       => INSTR_BLOCK_IN,
        WRITE_CACHE       => WRITE_CACHE_IN,
        PC_OUT_EXE        => LS_PC_OUT_EXE,
        PC_BRNCH          => PC_BRNCH,
        BRANCH_FLUSH      => BRANCH_FLUSH,
        RESULT_PACKET_EVEN_OUT_FC => RESULT_PACKET_EVEN_OUT_FC,
        RESULT_PACKET_ODD_OUT_FC  => RESULT_PACKET_ODD_OUT_FC,
        LS_WE_OUT_EOP   => LS_WE_OUT_EOP,
        LS_RIB_OUT_EOP  => LS_RIB_OUT_EOP,
        LS_DATA_OUT_EOP => LS_DATA_OUT_EOP,
        LS_ADDR_OUT_EOP => LS_ADDR_OUT_EOP
    );
    
    ----- OUTPUT RESULT PACKETS -----
    RESULT_PACKET_EVEN_OUT <= RESULT_PACKET_EVEN_OUT_FC;
    RESULT_PACKET_ODD_OUT  <= RESULT_PACKET_ODD_OUT_FC;
end behavioral;
