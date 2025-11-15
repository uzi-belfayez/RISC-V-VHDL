-- Quartus Prime VHDL Template
-- Simple Dual-Port RAM with different read/write addresses but
-- single read/write clock
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegBank is

	generic 
	(
		dataWidth : natural := 32;
		ADDR_WIDTH : natural := 5
	);

	port 
	(
		clk,reset		: in std_logic;
		RA,RB,RW	: in std_logic_vector((ADDR_WIDTH-1) downto 0);
		BusW	: in std_logic_vector((dataWidth-1) downto 0);
		we		: in std_logic := '1';
		BusA,BusB		: out std_logic_vector((dataWidth -1) downto 0)
	);

end RegBank;

architecture rtl of RegBank is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((dataWidth-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;
	
	-- Memory Initialisation function
		function init_ram
		return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin 
		for addr_pos in 0 to 2**ADDR_WIDTH - 1 loop 
			-- Initialize each address with the address itself
			tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, dataWidth));
		end loop;
		return tmp;
	end init_ram;
	-- Declare the RAM signal.	
	signal RegFile : memory_t:=init_ram;

begin

	process(clk,reset)
	begin
	if (reset='1') then
		for i in 0 to 31 loop
                --regBank32(i)    <= (others => '0');
                RegFile(i)    <= std_logic_vector(to_unsigned(i,dataWidth));
      end loop;
	elsif(rising_edge(clk)) then 
		if(we = '1') then
			if(unsigned(RW)/=0) then
				RegFile(to_integer(unsigned(RW))) <= BusW;
			end if;
		end if;
	end if;
	end process;
	BusA <= RegFile(to_integer(unsigned(RA)));
	BusB <= RegFile(to_integer(unsigned(RB)));
end rtl;
