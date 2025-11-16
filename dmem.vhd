library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmem is 
    generic (
        DATA_WIDTH : natural := 32;
        ADDR_WIDTH : natural := 8
		  );
    port (
        clk  : in std_logic;
        addr : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
        data : in std_logic_vector((DATA_WIDTH-1) downto 0);
        we   : in std_logic;
        q    : out std_logic_vector((DATA_WIDTH -1) downto 0)
    );
end entity;

architecture rtl of dmem is
    subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
    type memory_t is array((2**(ADDR_WIDTH-2))-1 downto 0) of word_t;
    
    function init_ram
        return memory_t is 
        variable tmp : memory_t := (others => (others => '0'));
    begin 
        for addr_pos in 0 to (2**(ADDR_WIDTH-2)) - 1 loop 
            tmp(addr_pos) := std_logic_vector(to_unsigned((2**(ADDR_WIDTH-2)) - addr_pos, DATA_WIDTH));
        end loop;
        tmp(0) := x"F3A5C789";
        return tmp;
    end init_ram;
    
    signal ram : memory_t := init_ram;

begin
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(we = '1') then
                ram(to_integer(unsigned(addr(ADDR_WIDTH - 1 downto 2)))) <= data;
            end if;
        end if;
    end process;
    
    q <= ram(to_integer(unsigned(addr(ADDR_WIDTH - 1 downto 2))));
    
end rtl;