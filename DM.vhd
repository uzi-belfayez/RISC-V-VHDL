library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DM is
    generic (
        DATA_WIDTH : natural := 32;
        ADDR_WIDTH : natural := 10  -- Permet 1024 octets
    );
    port (
        clk    : in  std_logic;
        addr   : in  std_logic_vector(31 downto 0);  
        data   : in  std_logic_vector(31 downto 0);  
        wrMem  : in  std_logic_vector(3 downto 0);  
        q      : out std_logic_vector(31 downto 0) 
    );
end entity DM;

architecture rtl of DM is

    -- Définir 4 mémoires de 8 bits (une pour chaque octet)
    type byte_memory_t is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(7 downto 0);
    
    signal mem_byte0 : byte_memory_t := (others => (others => '0'));  -- Octets à addr[31:2]&"00"
    signal mem_byte1 : byte_memory_t := (others => (others => '0'));  -- Octets à addr[31:2]&"01"
    signal mem_byte2 : byte_memory_t := (others => (others => '0'));  -- Octets à addr[31:2]&"10"
    signal mem_byte3 : byte_memory_t := (others => (others => '0'));  -- Octets à addr[31:2]&"11"
    
    -- Adresse de base (addr[31:2]) pour accéder aux 4 octets consécutifs
    signal base_addr : natural range 0 to (2**ADDR_WIDTH)-1;

begin

   
    base_addr <= to_integer(unsigned(addr(ADDR_WIDTH+1 downto 2)));

    
    process(clk)
    begin
        if rising_edge(clk) then
            -- Écriture de l'octet 0 (q[7:0]) à l'adresse base_addr
            if wrMem(0) = '1' then
                mem_byte0(base_addr) <= data(7 downto 0);
            end if;
            
            
            if wrMem(1) = '1' then
                mem_byte1(base_addr) <= data(15 downto 8);
            end if;
            
            
            if wrMem(2) = '1' then
                mem_byte2(base_addr) <= data(23 downto 16);
            end if;
            
    
            if wrMem(3) = '1' then
                mem_byte3(base_addr) <= data(31 downto 24);
            end if;
        end if;
    end process;

    --lire 4 octets consécutifs à partir de base_addr
    q(7 downto 0)   <= mem_byte0(base_addr);  -- Octet à addr[31:2]&"00"
    q(15 downto 8)  <= mem_byte1(base_addr);  -- addr+1
    q(23 downto 16) <= mem_byte2(base_addr);  -- addr+2
    q(31 downto 24) <= mem_byte3(base_addr);  -- addr+3

end rtl;