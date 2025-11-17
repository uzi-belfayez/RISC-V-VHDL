library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use work.riscV_package.all;


entity RISCV_R is
    generic (
        dataWidth   : integer := 32;
        addrWidth   : integer := 8;
        memDepth    : integer := 100;
        memoryFile  : string  := "file.hex"
    );
    port (
        clk   : in std_logic;
        reset : in std_logic
    );
end entity RISCV_R;

architecture behav of RISCV_R is

    constant aluOpWidth : natural := 4;

    signal instr : std_logic_vector (dataWidth - 1 downto 0);
    
    alias rs1 : std_logic_vector(4 downto 0) is instr(19 downto 15);
    alias rs2 : std_logic_vector(4 downto 0) is instr(24 downto 20);
    alias rd  : std_logic_vector(4 downto 0) is instr(11 downto 7);

    signal src1     : std_logic_vector (dataWidth - 1 downto 0);
    signal src2     : std_logic_vector (dataWidth - 1 downto 0);
    signal src2_mux : std_logic_vector (dataWidth - 1 downto 0);  
    signal result   : std_logic_vector (dataWidth - 1 downto 0);
    signal result_mux : std_logic_vector (dataWidth - 1 downto 0); 

    signal rdWrite : std_logic;

    signal pc      : std_logic_vector (addrWidth - 1 downto 0);
    signal pcBy4   : std_logic_vector (addrWidth - 1 downto 0);
    signal pc_in   : std_logic_vector (addrWidth - 1 downto 0);
    signal pc_load : std_logic;

    signal aluOp : std_logic_vector(aluOpWidth - 1 downto 0);
    
    signal immExt_out : std_logic_vector((dataWidth - 1) downto 0);
    signal RI_sel_controler : std_logic;
    signal we     : std_logic;
    signal load   : std_logic;
    signal controler_funct3_out : std_logic_vector(2 downto 0);
    signal wrMem  : std_logic;
    signal loadAcc : std_logic;
    
    signal dmem_addr : std_logic_vector(addrWidth - 1 downto 0);
    signal dmem_data : std_logic_vector(dataWidth - 1 downto 0);
    signal dmem_out  : std_logic_vector(dataWidth - 1 downto 0);

begin

    -- version de PC /4 pour adresser la mémoire d'instructions en 32 bits
    pcBy4 <= "00" & pc(addrWidth - 1 downto 2) when to_integer(unsigned(pcBy4)) < memDepth-1 else (others => '0');

    imem_1 : entity work.imem
        generic map (
            DATA_WIDTH => dataWidth,
            ADDR_WIDTH => addrWidth, 
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
        generic map (ADDR_WIDTH => addrWidth)
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
            BusW  => result_mux,  
            BusA  => src1,
            BusB  => src2,
            WE    => we,
            clk   => clk,
            reset => reset
        );

    -- Multiplexeur entre registre et immédiat
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

    -- ALU utilise src2_mux (multiplexé)
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

    ir_dec_1 : entity work.ir_dec_r 
        generic map (
            dataWidth  => dataWidth,
            aluOpWidth => aluOpWidth
        )
        port map ( 
            instr => instr,
            aluOp => aluOp,
            clk   => clk,
            reset => reset
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

    controller_1 : entity work.controleur
        generic map (
            INSTR_WIDTH => dataWidth
        )
        port map (
            instr      => instr,
            aluOp      => aluOp,
            RI_sel     => RI_sel_controler,
            we         => we,
            load       => load,
            clk        => clk,
            funct3_out => controler_funct3_out,
            wrMem      => wrMem,
            loadAcc    => loadAcc
        );

    -- Connexions pour dmem
    dmem_addr <= result(addrWidth - 1 downto 0);  -- Adresse = résultat ALU
    dmem_data <= src2;                             -- Données = valeur de rs2

    
    dmem_1 : entity work.dmem
        generic map (
            DATA_WIDTH => dataWidth,
            ADDR_WIDTH => addrWidth
        )
        port map (
            clk  => clk,
            addr => dmem_addr,
            data  => dmem_data,
            we   => wrMem,
            q => dmem_out
        );

    
    mux_reg_dmem : entity work.mux2v1
        generic map (
            DATA_WIDTH => dataWidth
        )
        port map (
            input0 => result,      -- Résultat de l'ALU
            input1 => dmem_out,    -- Données lues de la mémoire
            output => result_mux,  
            sel    => loadAcc
        );

end behav;