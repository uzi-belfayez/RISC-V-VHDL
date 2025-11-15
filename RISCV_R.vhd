library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use work.riscV_package.all;


entity RISCV_R is
    generic (
        dataWidth      : integer:=32;
        addrWidth      : integer:=8;
        memDepth       : integer:=100;
        memoryFile       : string:="file.hex"
    );
    port (
        clk             :   in std_logic;
        reset           :   in std_logic
    );
end;

architecture behav of RISCV_R is

    constant aluOpWidth :   natural:=4;

    signal instr :   std_logic_vector (dataWidth - 1 downto 0);
    alias   rs1 :   std_logic_vector(4 downto 0) is instr(19 downto 15);
    alias   rs2 :   std_logic_vector(4 downto 0) is instr(24 downto 20);
    alias   rd  :   std_logic_vector(4 downto 0) is instr(11 downto 7);
--    alias   rs1 :   natural range 0 to 31 is to_integer(unsigned(instr(19 downto 15)));
--    alias   rs2 :   natural range 0 to 31 is to_integer(unsigned(instr(24 downto 20)));
--    alias   rd  :   natural range 0 to 31 is to_integer(unsigned(instr(11 downto 7)));	 

    signal src1     : std_logic_vector ( dataWidth - 1 downto 0);
    signal src2     : std_logic_vector ( dataWidth - 1 downto 0);
    signal result   : std_logic_vector ( dataWidth - 1 downto 0);

    signal rdWrite  :   std_logic;

    signal pc            :   std_logic_vector (addrWidth - 1 downto 0);
    signal pcBy4         :   std_logic_vector (addrWidth - 1 downto 0);
    signal pc_in         :   std_logic_vector (addrWidth - 1 downto 0);
    signal pc_load       :   std_logic;

    signal aluOp        :   std_logic_vector(aluOpWidth - 1 downto 0);
begin

-- version de PC /4 pour adresser la mémoire d'instructions en 32 bits
    pcBy4   <=  "00" & pc(addrWidth - 1 downto 2) when to_integer(unsigned(pcBy4)) < memDepth-1 else (others => '0');

    imem_1  :   imem
    generic map
    (
        DATA_WIDTH  => dataWidth,
        ADDR_WIDTH  => addrWidth, 
        MEM_DEPTH   => memDepth,
        INIT_FILE   => memoryFile 
    )
    port map 
    (
        address     =>  pcBy4,
        Data_Out    =>  instr
    );

    -- non utilisé pour l'instant
    pc_in   <=  (others => '0');
    pc_load <=  '0';

	 
	 
    pc_1    :   compteur
    generic map (TAILLE => addrWidth)
    port map 
    (
        din	    => pc_in,
        clk	    => clk,
        load	=> pc_load,
        reset	=> reset,
        dout	=> pc
    );


    -- non utilisé pour l'instant
    rdWrite <=  '1';
    rb_1:   RegBank 
    generic map (
        dataWidth      =>   dataWidth
    )
    port map(
        RA      =>  rs1,
        RB      =>  rs2,
        RW      =>  rd,
        BusW    =>  result,
        BusA    =>  src1,
        BusB    =>  src2,
        WE      =>  rdWrite,
        clk     =>  clk,
        reset   =>  reset
    );


    alu_1: alu 
        generic map(
        dataWidth      =>   dataWidth,
        aluOpWidth      =>  aluOpWidth
    )
    port map(
             opA    =>  src1,
             opB    =>  src2,
             aluOp  =>  aluOp,
             res    =>  result
         );


    ir_dec_1 : ir_dec_r 
    generic map(
        dataWidth   =>  dataWidth,
        aluOpWidth  =>  aluOpWidth
    )
    port map ( 
        instr       =>  instr,
        aluOp       =>  aluOp,
        clk         =>  clk,
        reset       =>  reset
        
    );
end behav;

