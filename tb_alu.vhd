library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu is
end entity;

architecture arch of tb_alu is

    -- Component declaration
    component alu is
        generic(
            DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 5
        );
        port(
            aluOp : in std_logic_vector(3 downto 0);
            opA   : in std_logic_vector(DATA_WIDTH-1 downto 0);
            opB   : in std_logic_vector(DATA_WIDTH-1 downto 0);
            res   : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    constant DATA_WIDTH_T : natural := 32;

    signal aluOp_t : std_logic_vector(3 downto 0) := (others => '0');
    signal opA_t   : std_logic_vector(DATA_WIDTH_T-1 downto 0) := (others => '0');
    signal opB_t   : std_logic_vector(DATA_WIDTH_T-1 downto 0) := (others => '0');
    signal res_t   : std_logic_vector(DATA_WIDTH_T-1 downto 0);

begin

    uut: alu
        generic map(
            DATA_WIDTH => DATA_WIDTH_T,
            ADDR_WIDTH => 5
        )
        port map(
            aluOp => aluOp_t,
            opA   => opA_t,
            opB   => opB_t,
            res   => res_t
        );


    -- TEST PROCESS
    process
    begin

        ----------------------------------------------------------
        -- ADD (aluOp = 0000)
        ----------------------------------------------------------
        opA_t <= x"00000005";
        opB_t <= x"00000003";
        aluOp_t <= "0000";
        wait for 10 ns;

        ----------------------------------------------------------
        -- SUB (1000)
        ----------------------------------------------------------
        aluOp_t <= "1000";
        wait for 10 ns;

        ----------------------------------------------------------
        -- SLL (0001)
        -- 5 << 1 = 10
        ----------------------------------------------------------
        aluOp_t <= "0001";
        opB_t <= x"00000001";
        wait for 10 ns;

        ----------------------------------------------------------
        -- SLT signed (0010)
        ----------------------------------------------------------
        opA_t <= x"FFFFFFFF"; -- -1 signed
        opB_t <= x"00000001";
        aluOp_t <= "0010";
        wait for 10 ns;

        ----------------------------------------------------------
        -- SLTU unsigned (0011)
        ----------------------------------------------------------
        opA_t <= x"00000001";
        opB_t <= x"FFFFFFFF"; -- unsigned = 4,294,967,295
        aluOp_t <= "0011";
        wait for 10 ns;

        ----------------------------------------------------------
        -- XOR (0100)
        ----------------------------------------------------------
        opA_t <= x"0F0F0F0F";
        opB_t <= x"00FF00FF";
        aluOp_t <= "0100";
        wait for 10 ns;

        ----------------------------------------------------------
        -- SRL (0101)
        ----------------------------------------------------------
        opA_t <= x"80000000";
        opB_t <= x"00000001";
        aluOp_t <= "0101";
        wait for 10 ns;

        ----------------------------------------------------------
        -- SRA (1101)
        ----------------------------------------------------------
        aluOp_t <= "1101";
        wait for 10 ns;

        ----------------------------------------------------------
        -- OR (0110)
        ----------------------------------------------------------
        aluOp_t <= "0110";
        wait for 10 ns;

        ----------------------------------------------------------
        -- AND (0111)
        ----------------------------------------------------------
        aluOp_t <= "0111";
        wait for 10 ns;

        wait;
    end process;

end architecture;
