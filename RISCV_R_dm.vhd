library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use work.riscV_package.all;

entity RISCV_R_dm is
    generic (
        dataWidth   : integer := 32;
        addrWidth   : integer := 10;  -- Pour DM byte-addressable
        memDepth    : integer := 100;
        memoryFile  : string  := "file.hex"
    );
    port (
        clk   : in std_logic;
        reset : in std_logic
    );
end entity RISCV_R_dm;

architecture behav of RISCV_R_dm is

    constant aluOpWidth : natural := 4;

    -- Signaux d'instruction
    signal instr : std_logic_vector (dataWidth - 1 downto 0);
    
    alias rs1 : std_logic_vector(4 downto 0) is instr(19 downto 15);
    alias rs2 : std_logic_vector(4 downto 0) is instr(24 downto 20);
    alias rd  : std_logic_vector(4 downto 0) is instr(11 downto 7);

    -- Signaux RegBank et ALU
    signal src1       : std_logic_vector (dataWidth - 1 downto 0);
    signal src2       : std_logic_vector (dataWidth - 1 downto 0);
    signal src2_mux   : std_logic_vector (dataWidth - 1 downto 0);  
    signal result     : std_logic_vector (dataWidth - 1 downto 0);
    signal result_mux : std_logic_vector (dataWidth - 1 downto 0); 

    -- Signaux PC
    signal pc         : std_logic_vector (7 downto 0);  
    signal pcBy4      : std_logic_vector (7 downto 0);
    signal pc_in      : std_logic_vector (7 downto 0);
    signal pc_load    : std_logic;

    -- Signaux de contrôle
    signal aluOp                : std_logic_vector(aluOpWidth - 1 downto 0);
    signal immExt_out           : std_logic_vector((dataWidth - 1) downto 0);
    signal RI_sel_controler     : std_logic;
    signal we                   : std_logic;
    signal load                 : std_logic;
    signal controler_funct3_out : std_logic_vector(2 downto 0);
    signal wrMem_vec            : std_logic_vector(3 downto 0);  
    signal loadAcc              : std_logic;
    
    -- Signaux Data Memory (DM) - Nouvelle architecture
    signal dmem_addr_full : std_logic_vector(31 downto 0);  
    signal dmem_data      : std_logic_vector(dataWidth - 1 downto 0);
    signal dmem_out       : std_logic_vector(dataWidth - 1 downto 0);
    
    -- Signaux Load Manager (LM)
    signal LM_out : std_logic_vector(dataWidth-1 downto 0);

begin


    
    -- PC /4 pour adresser la mémoire d'instructions en 32 bits
    pcBy4 <= "00" & pc(7 downto 2) when to_integer(unsigned(pc)) < memDepth-1 
             else (others => '0');

    imem_1 : entity work.imem
        generic map (
            DATA_WIDTH => dataWidth,
            ADDR_WIDTH => 8,  -- IMEM reste sur 8 bits
            MEM_DEPTH  => memDepth,
            INIT_FILE  => memoryFile 
        )
        port map (
            address  => pcBy4,
            Data_Out => instr
        );

    pc_in   <= (others => '0');
    pc_load <= '0';

    pc_1 : entity work.pc
        generic map (ADDR_WIDTH => 8)
        port map (
            din   => pc_in,
            clk   => clk,
            load  => pc_load,
            reset => reset,
            dout  => pc
        );


    rb_1 : entity work.RegBank 
        generic map (
            dataWidth => dataWidth
        )
        port map (
            RA    => rs1,  
            RB    => rs2,   
            RW    => rd,     
            BusW  => result_mux,  -- Vient du MUX ALU/DMEM
            BusA  => src1,
            BusB  => src2,
            WE    => we,
            clk   => clk,
            reset => reset
        );


    
    mux_reg_immext : entity work.mux2v1
        generic map (
            DATA_WIDTH => dataWidth
        )
        port map (
            input0 => src2,
            input1 => immExt_out,
            output => src2_mux,
            sel    => RI_sel_controler
        );


    
    alu_1 : entity work.alu 
        generic map (
            DATA_WIDTH => dataWidth,
            ADDR_WIDTH => aluOpWidth
        )
        port map (
            opA   => src1,
            opB   => src2_mux,    
            aluOp => aluOp,
            res   => result
        );

 
    
    imm_ext1 : entity work.imm_ext
        generic map (
            INSTR_WIDTH => dataWidth
        )
        port map (
            instr    => instr,
            immExt   => immExt_out,
            instType => instr(6 downto 0)
        );


    
    controller_1 : entity work.controleur_dm
        generic map (
            INSTR_WIDTH => dataWidth
        )
        port map (
            instr      => instr,
            clk        => clk,
				reset 	  => reset,
            res_1_0    => result(1 downto 0),  -- NOUVEAU: bits [1:0] de l'ALU
            aluOp      => aluOp,
            RI_sel     => RI_sel_controler,
            we         => we,
            load       => load,
            funct3_out => controler_funct3_out,
            wrMem      => wrMem_vec,  -- NOUVEAU: 4 bits au lieu de 1
            loadAcc    => loadAcc
        );


    
    -- Préparer l'adresse 32 bits pour DM
    dmem_addr_full <= std_logic_vector(resize(unsigned(result), 32));
    dmem_data      <= src2;  -- Données à écrire = valeur de rs2
    
    dmem_1 : entity work.DM
        generic map (
            DATA_WIDTH => dataWidth,
            ADDR_WIDTH => addrWidth  --
        )
        port map (
            clk   => clk,
            addr  => dmem_addr_full,   -- Adresse 32 bits
            data  => dmem_data,
            wrMem => wrMem_vec,        -- NOUVEAU: 4 bits pour write enable par byte
            q     => dmem_out
        );


    
    LM_1 : entity work.LM
        generic map (
            DATA_WIDTH => dataWidth
        )
        port map (
            data    => dmem_out,
            res     => result(1 downto 0),  -- Bits [1:0] pour alignement
            funct3  => controler_funct3_out,
            dataOut => LM_out
        );


    
    mux_reg_dmem : entity work.mux2v1
        generic map (
            DATA_WIDTH => dataWidth
        )
        port map (
            input0 => result,     -- Résultat de l'ALU (pour Type R, I)
            input1 => LM_out,     -- Données de la mémoire (pour LOAD)
            output => result_mux,  
            sel    => loadAcc
        );

end behav;