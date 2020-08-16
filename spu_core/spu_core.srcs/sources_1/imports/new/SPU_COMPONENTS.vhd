-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CONSTANTS_PACKAGE.ALL;
use work.SPU_CORE_ISA_PACKAGE.ALL;

-------------------- PACKAGE DECLARATION --------------------
package COMPONENTS_PACKAGE is    
    -- Instruction cache entry record --
    type cache_entry is record
    V    : STD_LOGIC; -- Block valid flag
    TAG  : STD_LOGIC_VECTOR((CACHE_TAG_SIZE-1) downto 0);  -- LS Address MS 5 bits 
    DATA : STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0); -- Cached instruction pair
    end record cache_entry;
    
    -- Instruction cache type --
    type instr_cache_type is array (0 to (CACHE_HEIGHT-1)) of cache_entry;
    
    -- 4KB x 8-byte block Storage --
    type sram_type is array (0 to (STORAGE_SIZE-1)) of STD_LOGIC_VECTOR ((INSTR_SIZE-1) downto 0);
          
    -------------------- SPU CORE TOP COMPONENT --------------------
    component SPU_CORE_TOP_MODULE 
        port (
            -------------------- INPUTS --------------------
            CLK            : in STD_LOGIC;
            INSTR_BLOCK    : in STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0);
            LS_DATA_IN     : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
            -------------------- OUTPUTS --------------------
            RESULT_PACKET_EVEN_OUT : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0);
            RESULT_PACKET_ODD_OUT  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0, '0', (others => '0'), (others => '0'), '0');
            LS_PC_OUT_EXE          : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
            LS_WE_OUT_EOP          : out STD_LOGIC := '0';
            LS_RIB_OUT_EOP         : out STD_LOGIC := '0';
            LS_DATA_OUT_EOP        : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0');
            LS_ADDR_OUT_EOP        : out STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0) := (others => '0')
        );
    end component SPU_CORE_TOP_MODULE;
    
    -------------------- RF STAGE COMPOINENT --------------------
    component REGISTER_FETCH_STAGE
        port (
            -------------------- INPUTS --------------------
            CLK              : in STD_LOGIC := '0'; 
            PC_IN            : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
            EVEN_OPCODE_RF   : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
            ODD_OPCODE_RF    : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
            RA_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RB_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RC_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RA_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
            RB_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RC_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            EVEN_RI7_RF      : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  
            EVEN_RI10_RF     : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); 
            EVEN_RI16_RF     : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); 
            ODD_RI7_RF       : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0); 
            ODD_RI10_RF      : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); 
            ODD_RI16_RF      : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); 
            ODD_RI18_RF      : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);
            EVEN_REG_DEST_RF : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            ODD_REG_DEST_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
            RESULT_PACKET_EVEN_IN_FC : in RESULT_PACKET_EVEN; 
            RESULT_PACKET_ODD_IN_FC  : in RESULT_PACKET_ODD; 
            -------------------- OUTPUTS --------------------
            PC_OUT_RF            : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
            PREV_IN_EVEN         : out PREV_DATA := ((others => 'U'), TRUE);
            PREV_IN_ODD          : out PREV_DATA := ((others => 'U'), TRUE);
            PREV_OUT_EVEN        : out PREV_DATA := ((others => 'U'), TRUE);
            PREV_OUT_ODD         : out PREV_DATA := ((others => 'U'), TRUE);
            EVEN_OPCODE_OUT_RF   : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
            ODD_OPCODE_OUT_RF    : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
            RA_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RB_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RC_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RA_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RB_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RC_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RA_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            RB_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            RC_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            RA_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            RB_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
            RC_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            EVEN_RI7_OUT_RF      : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0');
            EVEN_RI10_OUT_RF     : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); 
            EVEN_RI16_OUT_RF     : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0');
            ODD_RI7_OUT_RF       : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0'); 
            ODD_RI10_OUT_RF      : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); 
            ODD_RI16_OUT_RF      : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0'); 
            ODD_RI18_OUT_RF      : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0)   := (others => '0'); 
            EVEN_REG_DEST_OUT_RF : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            ODD_REG_DEST_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0')
        );
    end component REGISTER_FETCH_STAGE;
    
    -------------------- IF STAGE COMPONENT --------------------
    component INSTRUCTION_FETCH_STAGE is
        port (
            -------------------- INPUTS --------------------
            CLK               : in STD_LOGIC;
            STALL_D           : in STD_LOGIC;
            STALL_DEP         : in STD_LOGIC;
            BRANCH_FLUSH      : in STD_LOGIC;
            WRITE_CACHE_IF    : in STD_LOGIC; 
            PC_BRNCH          : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); 
            INSTR_BLOCK_IN_IF : in STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0);
            -------------------- OUTPUTS --------------------
            STALL_RIB         : out STD_LOGIC := '0';
            INSTR_PAIR_OUT_IF : out STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0) := (others => '0');
            PC_OUT            : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0')
        );
    end component INSTRUCTION_FETCH_STAGE;
    
    -------------------- DECODE STAGE COMPONENT --------------------
    component DECODE_STAGE is 
        port (
            -------------------- INPUTS --------------------
            CLK            : in STD_LOGIC; 
            STALL_IF       : in STD_LOGIC;
            FLUSH          : in STD_LOGIC;
            INSTR_PAIR_IN  : in STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0);
            PC_IN          : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
            -------------------- OUTPUTS --------------------
            STALL_OUT      : out STD_LOGIC := '0';
            STALL_E_O      : out STD_LOGIC := '0';
            PC_OUT         : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
            INSTR_EVEN_OUT   : out INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
            INSTR_ODD_OUT    : out INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
            INSTR_EVEN_STALL : out INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
            INSTR_ODD_STALL  : out INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'))
        );
    end component DECODE_STAGE;
    
    -------------------- DEPENDENCY ISSUE STAGE COMPONENT --------------------
    component DEPENDENCY_ISSUE_STAGE is
    port (
        -------------------- INPUTS --------------------
        CLK               : in STD_LOGIC;
        PC_IN             : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
        INSTR_EVEN_IN     : in INSTR_DATA;
        INSTR_ODD_IN      : in INSTR_DATA;
        RF_IN_EVEN        : in PREV_DATA;
        RF_IN_ODD         : in PREV_DATA;
        RF_OUT_EVEN       : in PREV_DATA;
        RF_OUT_ODD        : in PREV_DATA;
        -------------------- OUTPUTS --------------------
        STALL_DEP_OUT      : out STD_LOGIC  := '0';
        INSTR_EVEN_OUT_DEP : out INSTR_DATA := ("00000000001", SIMPLE_FIXED_1, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
        INSTR_ODD_OUT_DEP  : out INSTR_DATA := ("01000000001", PERMUTE, RI16, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
        PC_OUT_DEP         : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
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
    end component DEPENDENCY_ISSUE_STAGE;
    
    ----- REGISTER FILE COMPONENT -----
    component register_file 
        port (
            -------------------- INPUTS --------------------
            ----- CONTROL SIGNALS -----
            CLK              : in STD_LOGIC; 
            RW_EVEN_RF       : in STD_LOGIC := '0'; 
            RW_ODD_RF        : in STD_LOGIC := '0'; 
            EVEN_OPCODE_RF   : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); 
            ODD_OPCODE_RF    : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); 
            RA_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RB_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RC_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            EVEN_WB_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
            EVEN_WB_DATA_RF  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); 
            RA_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RB_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RC_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
            ODD_WB_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
            ODD_WB_DATA_RF   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); 
            EVEN_RI7_RF      : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0); 
            EVEN_RI10_RF     : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); 
            EVEN_RI16_RF     : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); 
            ODD_RI7_RF       : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0); 
            ODD_RI10_RF      : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); 
            ODD_RI16_RF      : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); 
            ODD_RI18_RF      : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0); 
            EVEN_REG_DEST_RF : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            ODD_REG_DEST_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            -------------------- OUTPUTS --------------------
            EVEN_OPCODE_OUT_RF   : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
            ODD_OPCODE_OUT_RF    : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
            RA_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
            RB_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
            RC_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
            RA_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RB_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
            RC_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RA_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
            RB_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            RC_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            RA_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            RB_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            RC_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            EVEN_RI7_OUT_RF      : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0'); 
            EVEN_RI10_OUT_RF     : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0');
            EVEN_RI16_OUT_RF     : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0');
            ODD_RI7_OUT_RF       : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0');
            ODD_RI10_OUT_RF      : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); 
            ODD_RI16_OUT_RF      : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0');
            ODD_RI18_OUT_RF      : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0)   := (others => '0'); 
            EVEN_REG_DEST_OUT_RF : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
            ODD_REG_DEST_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0')
        );
    end component register_file;
    
    component EXECUTION_STAGE 
        port (
            -------------------- INPUTS --------------------
            CLK : in STD_LOGIC;
            PC_IN             : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
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
            INSTR_BLOCK_DATA  : in STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0);
            -------------------- OUTPUTS --------------------
            INSTR_BLOCK               : out STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0'); -- 128-bytes (32 Instructions) from Local Store
            WRITE_CACHE               : out STD_LOGIC := '0'; -- Cache write enable
            PC_OUT_EXE                : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
            PC_BRNCH                  : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
            BRANCH_FLUSH              : out STD_LOGIC;
            RESULT_PACKET_EVEN_OUT_FC : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0);
            RESULT_PACKET_ODD_OUT_FC  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0, '0', (others => '0'), (others => '0'), '0');
            LS_WE_OUT_EOP             : out STD_LOGIC;
            LS_RIB_OUT_EOP            : out STD_LOGIC;
            LS_DATA_OUT_EOP           : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
            LS_ADDR_OUT_EOP           : out STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0)
        );
    end component EXECUTION_STAGE;
    
    ----- LOCAL STORE COMPONENT COMPONENT -----
    component LOCAL_STORE
        port (
            -------------------- INPUTS --------------------
            WE_LS      : in STD_LOGIC;
            RIB_LS     : in STD_LOGIC;
            FILL       : in STD_LOGIC;
            ADDR_LS    : in STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0);
            DATA_IN_LS : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
            SRAM_INSTR : in SRAM_TYPE;
            PC_LS      : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
            -------------------- OUTPUTS --------------------
            DATA_OUT_LS        : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)     := (others => '0');
            INSTR_BLOCK_OUT_LS : out STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0') 
        );
    end component LOCAL_STORE;
    
    ----- INSTRUCTION CACHE COMPONENT -----
    component instruction_cache
        port(
            -------------------- INPUTS --------------------
            CLK          : in STD_LOGIC;
            BRANCH_FLUSH : in STD_LOGIC;
            ADDR         : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
            WRITE_CACHE  : in STD_LOGIC;
            INSTR_BLOCK  : in STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0); 
            -------------------- OUTPUTS --------------------
            HIT          : out STD_LOGIC;
            DATA_OUT     : out STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0)
        );
    end component instruction_cache;
    
    ----- FORWARDING MACRO/CIRCUIS COMPONENT -----
    component forwarding_macro_circuits 
        port (
            -------------------- INPUTS --------------------
            CLK                   : in STD_LOGIC := '0';
            EVEN_OPCODE_FM        : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
            ODD_OPCODE_FM         : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
            RA_EVEN_DATA_FM       : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); 
            RB_EVEN_DATA_FM       : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
            RC_EVEN_DATA_FM       : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  
            RA_ODD_DATA_FM        : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
            RB_ODD_DATA_FM        : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
            RC_ODD_DATA_FM        : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); 
            RA_EVEN_ADDR_FM       : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RB_EVEN_ADDR_FM       : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RC_EVEN_ADDR_FM       : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RA_ODD_ADDR_FM        : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RB_ODD_ADDR_FM        : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            RC_ODD_ADDR_FM        : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            EVEN_RI7_FM           : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  
            EVEN_RI10_FM          : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
            EVEN_RI16_FM          : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
            ODD_RI7_FM            : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0); 
            ODD_RI10_FM           : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); 
            ODD_RI16_FM           : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
            ODD_RI18_FM           : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0); 
            EVEN_REG_DEST_FM      : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            ODD_REG_DEST_FM       : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            ----- FORWARDING CIRCUIT INPUTS -----
            RESULT_PACKET_EVEN_FC : in RESULT_PACKET_EVEN; 
            RESULT_PACKET_ODD_FC  : in RESULT_PACKET_ODD;
            -------------------- OUTPUTS --------------------
            INSTR_BLOCK           : out STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0');
            WRITE_CACHE           : out STD_LOGIC := '0';
            PC_BRNCH              : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
            BRANCH_FLUSH          : out STD_LOGIC := '0'; 
            RA_EVEN_DATA_OUT_FM   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RB_EVEN_DATA_OUT_FM   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RC_EVEN_DATA_OUT_FM   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            RA_ODD_DATA_OUT_FM    : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
            RB_ODD_DATA_OUT_FM    : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
            RC_ODD_DATA_OUT_FM    : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
            EVEN_RI7_OUT_FM       : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0');  
            EVEN_RI10_OUT_FM      : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); 
            EVEN_RI16_OUT_FM      : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0'); 
            ODD_RI7_OUT_FM        : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0'); 
            ODD_RI10_OUT_FM       : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0');
            ODD_RI16_OUT_FM       : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0'); 
            ODD_RI18_OUT_FM       : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0)   := (others => '0');
            EVEN_OPCODE_OUT_FM    : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
            ODD_OPCODE_OUT_FM     : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');  
            EVEN_REG_DEST_OUT_FM  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
            ODD_REG_DEST_OUT_FM   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
            ----- FORWARDING CIRCUIT OUTPUTS ----- 
            RESULT_PACKET_EVEN_OUT_FC : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0);
            RESULT_PACKET_ODD_OUT_FC  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0, '0', (others => '0'), (others => '0'), '0')
        );
    end component forwarding_macro_circuits;
    
    ----- EVEN & ODD PIPES COMPONENT -----
    component EVEN_ODD_PIPES 
        port (
            -------------------- INPUTS --------------------
            CLK               : in STD_LOGIC := '0'; 
            PC_IN             : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);
            EVEN_RI7_EOP      : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0); 
            EVEN_RI10_EOP     : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); 
            EVEN_RI16_EOP     : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); 
            EVEN_REG_DEST_EOP : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
            ODD_RI7_EOP       : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0); 
            ODD_RI10_EOP      : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
            ODD_RI16_EOP      : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); 
            ODD_RI18_EOP      : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0); 
            ODD_REG_DEST_EOP  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);  
            RA_EVEN_DATA_EOP  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); 
            RB_EVEN_DATA_EOP  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
            RC_EVEN_DATA_EOP  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); 
            RA_ODD_DATA_EOP   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  
            RB_ODD_DATA_EOP   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  
            RC_ODD_DATA_EOP   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);   
            EVEN_OPCODE_EOP   : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); 
            ODD_OPCODE_EOP    : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);  
            LOCAL_STORE_DATA_EOP : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
            INSTR_BLOCK_DATA     : in STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0); -- 128-bytes (32 Instructions) from Local Store
            -------------------- OUTPUTS --------------------
            PC_OUT                     : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
            LS_WE_OUT_EOP              : out STD_LOGIC := '0'; 
            LS_RIB_OUT_EOP             : out STD_LOGIC := '0'; 
            LS_DATA_OUT_EOP            : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0'); 
            LS_ADDR_OUT_EOP            : out STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0) := (others => '0');                 
            RESULT_PACKET_EVEN_OUT_EOP : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0);
            RESULT_PACKET_ODD_OUT_EOP  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0, '0', (others => '0'), (others => '0'), '0')
        );
    end component EVEN_ODD_PIPES;
    
    ----- Checks the Forwarding Circuits for Dependencies -----
    function check_dep(EVEN_FC : FC_EVEN; -- Even Forwarding Circuit
                       ODD_FC  : FC_ODD;   -- Odd Forwarding Circuit
                       ADDR    : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);    -- Register Address being Evaluated
                       DATA_IN : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)) -- Data from Register File
    return STD_LOGIC_VECTOR;       
end package COMPONENTS_PACKAGE;

package body COMPONENTS_PACKAGE is
    ----- Checks the Forwarding Circuits for Dependencies -----
    function check_dep(EVEN_FC : FC_EVEN; -- Even Forwarding Circuit
                       ODD_FC  : FC_ODD;   -- Odd Forwarding Circuit
                       ADDR    : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);    -- Register Address being Evaluated
                       DATA_IN : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)) -- Data from Register File
                       return STD_LOGIC_VECTOR is
        variable DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); -- Data to be Forwarded
        variable I_FC : NATURAL := 0;      -- Forwarding Circuit Index of Data
        variable found : BOOLEAN := false; -- Found a dependency?
    begin
        DATA_OUT := DATA_IN; -- Initialize DATA_OUT to the Data from Register File
        ----- Check Even Forwarding Circuit -----
        while(I_FC < (FC_DEPTH-1)) loop  
            if (EVEN_FC(I_FC).REG_DEST = ADDR) then
                DATA_OUT := EVEN_FC(I_FC).RESULT; -- Update Forwarded Data
                exit;
            end if;
            I_FC := I_FC + 1; -- Go to next Result Packet in Even FC
        end loop;
        
        ----- Check Odd Forwarding Circuit -----
        for i in 0 to (FC_DEPTH-1) loop  
            if (ODD_FC(i).REG_DEST = ADDR) then
                if (i < I_FC) then
                    DATA_OUT := ODD_FC(i).RESULT; -- Update Forwarded Data
                end if;
                exit;
            end if;
        end loop;
        
        -- Forwarded Data --
        return DATA_OUT;
    end function check_dep;
end package body COMPONENTS_PACKAGE;
    