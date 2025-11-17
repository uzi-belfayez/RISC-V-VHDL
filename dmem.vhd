library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmem is
    generic (
        DATA_WIDTH : natural := 32;
        ADDR_WIDTH : natural := 8
    );
    port (
        clk  : in  std_logic;
        addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        we   : in  std_logic;
        q    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of dmem is

    subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
    type ram_t is array (0 to 2**(ADDR_WIDTH-2)-1) of word_t;

    constant INIT_RAM : ram_t := (
        0 => x"11111111",   -- DMEM[0]
        1 => x"22222222",   -- DMEM[1]
        2 => x"33333333",   -- DMEM[2]
        3 => x"44444444",   -- DMEM[3]
        4 => x"55555555",
        5 => x"AAAAAAAA",
        6 => x"DEADBEEF",
        7 => x"0000BEEF",
        others => (others => '0')
    );

    signal ram : ram_t := INIT_RAM;

begin

    -- Write only if you enable it (you won’t for LW test)
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(addr(ADDR_WIDTH-1 downto 2)))) <= data;
            end if;
        end if;
    end process;

    -- async read
    q <= ram(to_integer(unsigned(addr(ADDR_WIDTH-1 downto 2))));

end architecture;
