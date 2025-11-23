library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package riscV_package_dm is
    
 
    component imem is
        generic (
            DATA_WIDTH  : natural := 32;
            ADDR_WIDTH  : natural := 8;
            MEM_DEPTH   : natural := 200;
            INIT_FILE   : string
        );
        port (
            address     : in  std_logic_vector (ADDR_WIDTH - 1 downto 0);
            Data_Out    : out std_logic_vector (DATA_WIDTH - 1 downto 0)
        );
    end component;
    
 
    component pc is
        generic (
            ADDR_WIDTH : natural := 32
        );
        port (
            din   : in  std_logic_vector (ADDR_WIDTH - 1 downto 0);
            dout  : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
            reset : in  std_logic;
            load  : in  std_logic;
            clk   : in  std_logic
        );
    end component;
    

    component RegBank is
        generic (
            dataWidth  : natural := 32;
            ADDR_WIDTH : natural := 5
        );
        port (
            clk, reset  : in  std_logic;
            RA, RB, RW  : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
            BusW        : in  std_logic_vector((dataWidth-1) downto 0);
            we          : in  std_logic := '1';
            BusA, BusB  : out std_logic_vector((dataWidth-1) downto 0)
        );
    end component;
    

    component alu is
        generic (
            DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 5
        );
        port (
            aluOp  : in  std_logic_vector(3 downto 0);
            opA    : in  std_logic_vector((DATA_WIDTH-1) downto 0);
            opB    : in  std_logic_vector((DATA_WIDTH-1) downto 0);
            res    : out std_logic_vector((DATA_WIDTH-1) downto 0)    
        );
    end component;
    
 
    component imm_ext is
        generic (
            INSTR_WIDTH : natural := 32
        );
        port (
            instr    : in  std_logic_vector((INSTR_WIDTH - 1) downto 0);
            immExt   : out std_logic_vector((INSTR_WIDTH - 1) downto 0);
            instType : in  std_logic_vector(6 downto 0)
        );
    end component;
    

    component controleur_dm is
        generic (
            INSTR_WIDTH : natural := 32
        );
        port (
            instr       : in  std_logic_vector((INSTR_WIDTH - 1) downto 0);
            clk         : in  std_logic;
            res_1_0     : in  std_logic_vector(1 downto 0);  -- NOUVEAU
				reset			: in std_logic ;
            aluOp       : out std_logic_vector(3 downto 0);
            RI_sel      : out std_logic;
            loadAcc     : out std_logic;
            we          : out std_logic;
            wrMem       : out std_logic_vector(3 downto 0);  -- MODIFIÉ: 4 bits
            load        : out std_logic;
            funct3_out  : out std_logic_vector(2 downto 0)
        );
    end component;
    
    component mux2v1 is
        generic (
            DATA_WIDTH : natural := 32
        );
        port (
            input0 : in  std_logic_vector((DATA_WIDTH - 1) downto 0);
            input1 : in  std_logic_vector((DATA_WIDTH - 1) downto 0);
            output : out std_logic_vector((DATA_WIDTH - 1) downto 0);
            sel    : in  std_logic  
        );                         
    end component;
    
 
    component DM is 
        generic (
            DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 10
        );
        port (
            clk   : in  std_logic;
            addr  : in  std_logic_vector(31 downto 0);
            data  : in  std_logic_vector((DATA_WIDTH-1) downto 0);
            wrMem : in  std_logic_vector(3 downto 0);  -- 4 bits
            q     : out std_logic_vector((DATA_WIDTH-1) downto 0)
        );
    end component;
    

    component LM is
        generic (
            DATA_WIDTH : natural := 32
        );
        port (
            data    : in  std_logic_vector((DATA_WIDTH-1) downto 0);
            res     : in  std_logic_vector(1 downto 0);
            funct3  : in  std_logic_vector(2 downto 0);
            dataOut : out std_logic_vector((DATA_WIDTH-1) downto 0)
        );
    end component;
    
end package riscV_package_dm;

package body riscV_package_dm is
    -- Corps vide (pas de fonctions à implémenter)
end package body riscV_package_dm;