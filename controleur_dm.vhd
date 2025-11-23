library ieee;
use ieee.std_logic_1164.all;

entity controleur_dm is
    generic (
        INSTR_WIDTH : natural := 32
    );
    port (
        
        instr       : in std_logic_vector((INSTR_WIDTH - 1) downto 0);
        clk         : in std_logic;
        res_1_0     : in std_logic_vector(1 downto 0);  -- Bits [1:0] de la sortie ALU
        aluOp       : out std_logic_vector(3 downto 0);
        RI_sel      : out std_logic; 
        loadAcc     : out std_logic;   
        
        -- Write Enable RegBank
        we          : out std_logic;  
        
        -- Sorties pour DM par octet
        wrMem       : out std_logic_vector(3 downto 0);  
        
        -- Sorties pour PC
        load        : out std_logic;
        funct3_out  : out std_logic_vector(2 downto 0);
		  
		  reset       : in std_logic
    );
end entity;

architecture arch of controleur_dm is

    alias funct7   : std_logic_vector(6 downto 0) is instr(31 downto 25);
    alias funct3   : std_logic_vector(2 downto 0) is instr(14 downto 12);
    alias opcode   : std_logic_vector(6 downto 0) is instr(6 downto 0);
    
    signal store_type : std_logic_vector(1 downto 0);  -- 00=SB, 01=SH, 10=SW
    signal is_store   : std_logic;
    
begin

    funct3_out <= funct3;

    is_store <= '1' when opcode = "0100011" else '0';

    -- funct3 = 000 → SB (Store Byte)
    -- funct3 = 001 → SH (Store Half)
    -- funct3 = 010 → SW (Store Word)
    store_type <= "00" when funct3 = "000" else  -- SB
                  "01" when funct3 = "001" else  -- SH
                  "10";                          -- SW


    process(opcode, funct7, funct3, is_store, store_type, res_1_0, reset)
    begin
	 
        RI_sel  <= '0';
        loadAcc <= '0';
        we      <= '0';
        wrMem   <= "0000";
        load    <= '0';
        aluOp   <= "0000";
  
	if reset = '0' then 
        
        case opcode is
            -- Type R 
            when "0110011" =>
                RI_sel  <= '0';     
                loadAcc <= '0';      
                we      <= '1';      
                wrMem   <= "0000";   
                load    <= '0';
                aluOp   <= funct7(5) & funct3;
            
            -- Type I
            when "0010011" =>
                RI_sel  <= '1';      
                loadAcc <= '0';      
                we      <= '1';      
                wrMem   <= "0000";   
                load    <= '0';
                aluOp   <= '0' & funct3;  
            
            -- LOAD 
            when "0000011" =>
                RI_sel  <= '1';      
                loadAcc <= '1';      
                we      <= '1';     
                wrMem   <= "0000";   
                load    <= '0';
                aluOp   <= "0000";   
  
            -- STORE
            when "0100011" =>
                RI_sel  <= '1';      
                loadAcc <= '0';     
                we      <= '0';      
                load    <= '0';
                aluOp   <= "0000"; 
                
                -- Calcul de wrMem selon le type de STORE et res[1:0]
                case store_type is
 
                    -- SB
                    when "00" =>
                        case res_1_0 is
                            when "00" => wrMem <= "0001"; 
                            when "01" => wrMem <= "0010";  
                            when "10" => wrMem <= "0100";  
                            when "11" => wrMem <= "1000";  
                            when others => wrMem <= "0000";
                        end case;
                    
                    -- SH 
                    when "01" =>
                        case res_1_0 is
                            when "00" => wrMem <= "0011"; 
                            when "10" => wrMem <= "1100";  
                            when others => wrMem <= "0000"; 
                        end case;

                    -- SW
                    when "10" =>
                        if res_1_0 = "00" then
                            wrMem <= "1111";  
                        else
                            wrMem <= "0000";  
                        end if;
                    
                    when others =>
                        wrMem <= "0000";
                end case;

            when others =>
                RI_sel  <= '0';
                loadAcc <= '0';
                we      <= '0';
                wrMem   <= "0000";
                load    <= '0';
                aluOp   <= "0000";
        end case;
		  
	else
		          RI_sel  <= '0';
                loadAcc <= '0';
                we      <= '0';
                wrMem   <= "0000";
                load    <= '0';
                aluOp   <= "0000";
	end if;
    end process;

end arch;