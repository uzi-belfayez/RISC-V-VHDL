library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_DM is
end entity;

architecture testbench of tb_DM is

    component DM is
        generic (
            DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 10
        );
        port (
            clk    : in  std_logic;
            addr   : in  std_logic_vector(31 downto 0);
            data   : in  std_logic_vector(31 downto 0);
            wrMem  : in  std_logic_vector(3 downto 0);
            q      : out std_logic_vector(31 downto 0)
        );
    end component;
	 
    signal clk_t   : std_logic := '0';
    signal addr_t  : std_logic_vector(31 downto 0) := (others => '0');
    signal data_t  : std_logic_vector(31 downto 0) := (others => '0');
    signal wrMem_t : std_logic_vector(3 downto 0) := "0000";
    signal q_t     : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

begin

    DUT : DM
        generic map (
            DATA_WIDTH => 32,
            ADDR_WIDTH => 10
        )
        port map (
            clk   => clk_t,
            addr  => addr_t,
            data  => data_t,
            wrMem => wrMem_t,
            q     => q_t
        );

    clk_t <= not clk_t after clk_period / 2;

    process
    begin

        -- SW 0x12345678 à l'adresse 0
        addr_t  <= x"00000000";
        data_t  <= x"12345678";
        wrMem_t <= "1111";  -- Écrire les 4 octets
        wait for clk_period;
        
        wrMem_t <= "0000";  -- Désactiver l'écriture
        wait for clk_period;
        
        -- Écrire 0xAA au byte 0 (LSB)
        addr_t  <= x"00000000";
        data_t  <= x"000000AA";
        wrMem_t <= "0001";  -- Écrire uniquement byte 0
        wait for clk_period;
        
        wrMem_t <= "0000";
        wait for clk_period;

        -- Écrire 0xBB au byte 1

        addr_t  <= x"00000001";
        data_t  <= x"0000BB00";  -- Donnée à écrire dans data[15:8]
        wrMem_t <= "0010";  -- Écrire byte 1
        wait for clk_period;
        
        wrMem_t <= "0000";
        addr_t  <= x"00000000";  -- Relire depuis addr=0
        wait for clk_period;

        -- Écrire 0xCCDD aux bytes 0-1
		  
        addr_t  <= x"00000000";
        data_t  <= x"0000CCDD";
        wrMem_t <= "0011";  -- Écrire bytes 0 et 1
        wait for clk_period;
        
        wrMem_t <= "0000";
        wait for clk_period;

        -- Écrire 0xEEFF aux bytes 2-3
        
        addr_t  <= x"00000002";
        data_t  <= x"EEFF0000";  -- Donnée dans data[31:16]
        wrMem_t <= "1100";  -- Écrire bytes 2 et 3
        wait for clk_period;
        
        wrMem_t <= "0000";
        addr_t  <= x"00000000";
        wait for clk_period;


        -- Écrire 0xAABBCCDD à l'adresse 4
        addr_t  <= x"00000004";
        data_t  <= x"AABBCCDD";
        wrMem_t <= "1111";
        wait for clk_period;
        
        wrMem_t <= "0000";
        wait for clk_period;


        addr_t  <= x"00000004";
        data_t  <= x"00000011";
        wrMem_t <= "0001";
        wait for clk_period;
        
        wrMem_t <= "0000";
        wait for clk_period;


        addr_t  <= x"00000007";
        data_t  <= x"99000000";
        wrMem_t <= "1000";
        wait for clk_period;
        
        wrMem_t <= "0000";
        addr_t  <= x"00000004";
        wait for clk_period;
    

        addr_t  <= x"00000008";
        data_t  <= x"11223344";
        wrMem_t <= "1111";
        wait for clk_period;
        
        wrMem_t <= "0000";
        wait for clk_period;
        
 
        addr_t  <= x"0000000A";
        data_t  <= x"55660000";
        wrMem_t <= "1100";
        wait for clk_period;
        
        wrMem_t <= "0000";
        addr_t  <= x"00000008";
        wait for clk_period;

        addr_t  <= x"00000000";
        wait for clk_period;

        wait;
    end process;

end testbench;