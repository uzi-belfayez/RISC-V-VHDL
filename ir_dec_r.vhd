library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;


entity ir_dec_r is
    generic (
        dataWidth   :   integer:=32;
        aluOpWidth  :   integer:=4
    );
    port ( 
        instr       :   in    std_logic_vector (dataWidth - 1 downto 0);
        aluOp       :   out     std_logic_vector (aluOpWidth - 1 downto 0);
        clk         :   in      std_logic;
        reset       :   in      std_logic
        
    );
end entity ir_dec_r;

architecture behav of ir_dec_r is

    alias instr_6_2 :   std_logic_vector(4 downto 0) is instr(6 downto 2);
    alias funct3    :   std_logic_vector(2 downto 0) is instr(14 downto 12);
    alias opcode    :   std_logic_vector(6 downto 0) is instr(6 downto 0);


    -- signaux pour identifier les différentes instructions
    signal ADDs     :   std_logic;
    signal SUBs     :   std_logic;
    signal SLLs     :   std_logic;
    signal SLTs     :   std_logic;
    signal SLTUs    :   std_logic;
    signal XORs     :   std_logic;
    signal SRLs     :   std_logic;
    signal SRAs     :   std_logic;
    signal ORs      :   std_logic;
    signal ANDs     :   std_logic;

    signal decBits          :   std_logic_vector(10 downto 0);


begin

  decBits   <=  instr(30) & funct3 & opcode;

  ADDs  <= '1' when decBits(10 downto 0)   = "00000110011" else '0';
  SUBs  <= '1' when decBits(10 downto 0)   = "10000110011" else '0';
  SLLs  <= '1' when decBits(10 downto 0)   = "00010110011" else '0';
  SLTs  <= '1' when decBits(10 downto 0)   = "00100110011" else '0';
  SLTUs <= '1' when decBits(10 downto 0)   = "00110110011" else '0';
  XORs  <= '1' when decBits(10 downto 0)   = "01000110011" else '0';
  SRLs  <= '1' when decBits(10 downto 0)   = "01010110011" else '0';
  SRAs  <= '1' when decBits(10 downto 0)   = "11010110011" else '0';
  ORs   <= '1' when decBits(10 downto 0)   = "01100110011" else '0';
  ANDs  <= '1' when decBits(10 downto 0)   = "01110110011" else '0';



    aluOp   <=  instr(30) & funct3;


end behav;


