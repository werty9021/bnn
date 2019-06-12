library IEEE;
use IEEE.std_logic_1164.all;

package bnn_opcodes is
    constant OPC_POPCOUNT      : std_logic_vector(1 downto 0) := "00";
    constant OPC_POPCOUNTACC   : std_logic_vector(1 downto 0) := "01";
    constant OPC_SET_BIT       : std_logic_vector(1 downto 0) := "10";
    constant OPC_XNORPOPCNTACC : std_logic_vector(1 downto 0) := "11";
end;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.bnn_opcodes.all;

entity fu_bnn_ops is
    generic (busw : integer := 32);
    
    port (
        -- trigger port / operand 1
        t1data : in std_logic_vector(busw-1 downto 0);
        t1load : in std_logic;
        t1opcode : in std_logic_vector(1 downto 0);
        -- operand 2
        o2data : in std_logic_vector(busw-1 downto 0);
        o2load : in std_logic;
        -- operand 3
        o3data : in std_logic_vector(busw-1 downto 0);
        o3load : in std_logic;
        -- result port
        r1data : out std_logic_vector(busw-1 downto 0);
        -- control signals
        clk : in std_logic;
        rstx : in std_logic;
        glock : in std_logic
    );
end;


architecture rtl of fu_bnn_ops is
    signal r1reg : std_logic_vector(busw-1 downto 0);
begin
    process (clk, rstx)
        variable count : unsigned(busw-1 downto 0);
    begin
        if rstx = '0' then
            r1reg <= (others => '0');
        elsif clk'event and clk = '1' then
            if glock = '0' then
                if t1load = '1' then
                    case t1opcode is
                    when OPC_POPCOUNT =>
                        -- popcount
                        count := (others => '0');
                        for i in 0 to busw-1 loop
                            count := count + (busw-1 => t1data(i), others => '0');
                        end loop;
                        r1reg <= std_logic_vector(count);
                    when OPC_POPCOUNTACC =>
                        -- popcount + accumulate
                        if o2load = '1' then
                            count := unsigned(o2data);
                            for i in 0 to busw-1 loop
                                count := count + (busw-1 => t1data(i), others => '0');
                            end loop;
                            r1reg <= std_logic_vector(count);
                        end if;
                    when OPC_SET_BIT =>
                        -- set specific bit
                        if o2load = '1' then
                        -- pos, string
                            -- position o2data set bit to 1
                            r1reg(to_integer(unsigned(o2data))) <= '1';
                        end if;
                        r1reg(1) <= '1';
                    when OPC_XNORPOPCNTACC =>
                        -- xnor + popcount + accumulate
                         if o2load = '1' and o3load = '1' then
                            r1reg <= t1data xnor o2data;
                            count := unsigned(o3data);
                            for i in 0 to busw-1 loop
                                count := count + (busw-1 => r1reg(i), others => '0');
                            end loop;
                            r1reg <= std_logic_vector(count);
                        end if;
                    when others =>
                        null;
                    end case;
                end if;
            end if;
        end if;
    end process;
    
    r1data <= r1reg;
end

