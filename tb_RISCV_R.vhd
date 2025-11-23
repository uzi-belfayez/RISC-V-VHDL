library ieee;
use ieee.std_logic_1164.all;

entity tb_RISCV_R is
end entity;

architecture arch of tb_RISCV_R is
    -- Constantes
    constant clk_period : time := 10 ns;
    
    -- Signaux
    signal clk_t   : std_logic := '0';
    signal reset_t : std_logic := '0';
    
    -- Composant
    component RISCV_R is
        generic (
            dataWidth   : integer := 32;
            addrWidth   : integer := 8;
            memDepth    : integer := 100;
            memoryFile  : string  := "file.txt"
        );
        port (
            clk   : in std_logic;
            reset : in std_logic
        );
    end component;

begin
    -- Génération de l'horloge
    clk_t <= not clk_t after clk_period/2;
    
    -- Instanciation du processeur
    DUT : RISCV_R
        generic map (
            dataWidth   => 32,
            addrWidth   => 8,
            memDepth    => 100,
            memoryFile  => "load_03.hex.txt"
        )
        port map (
            clk   => clk_t,
            reset => reset_t
        );
    
    -- Processus de test
    process
    begin
        -- Reset initial
        reset_t <= '1';
        wait for 20 ns;
        reset_t <= '0';
        
        -- Laisser le processeur exécuter
        wait for 500 ns;
        
        wait;
    end process;

end architecture;