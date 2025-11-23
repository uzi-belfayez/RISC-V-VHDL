library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_RISCV_dm is
end entity;

architecture testbench of tb_RISCV_dm is

    component RISCV_R_dm is
        generic (
            dataWidth   : integer := 32;
            addrWidth   : integer := 10;
            memDepth    : integer := 100;
            memoryFile  : string  := "file.hex"
        );
        port (
            clk   : in std_logic;
            reset : in std_logic
        );
    end component;

    constant clk_period : time := 10 ns;
    
    signal clk_t   : std_logic := '0';
    signal reset_t : std_logic := '0';

begin

    clk_t <= not clk_t after clk_period / 2;

    DUT : RISCV_R_dm
        generic map (
            dataWidth   => 32,
            addrWidth   => 10,
            memDepth    => 100,
            memoryFile  => "store_01.hex.txt"
        )
        port map (
            clk   => clk_t,
            reset => reset_t
        );
    
    process
    begin      
        reset_t <= '1';
        wait for 20 ns;
        reset_t <= '0';
        
        wait for 1000 ns;
        wait;
    end process;

end testbench;