-- Function Unit: vALU
-- 
-- Operations:
--  geu16x32to32x1  : 0
--  mac16x32to32x32 : 1
--  max16x32        : 2
--  shlsame16x32    : 3
-- 
library ieee;
use ieee.std_logic_1164.all;

package fu_valu_opcodes is
  constant OPC_GEU16X32TO32X1  : std_logic_vector(1 downto 0) := "00";
  constant OPC_MAC16X32TO32X32  : std_logic_vector(1 downto 0) := "01";
  constant OPC_MAX16X32  : std_logic_vector(1 downto 0) := "10";
  constant OPC_SHLSAME16X32  : std_logic_vector(1 downto 0) := "11";  
end fu_valu_opcodes;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.fu_valu_opcodes.all;

entity fu_valu is
  port (
    clk : in std_logic;
    rstx : in std_logic;
    glock_in : in std_logic;
    glockreq_out : out std_logic;
    operation_in : in std_logic_vector(2-1 downto 0);
    data_in1t_in : in std_logic_vector(512-1 downto 0);
    load_in1t_in : in std_logic;
    data_in2_in : in std_logic_vector(512-1 downto 0);
    load_in2_in : in std_logic;
    data_in3_in : in std_logic_vector(1024-1 downto 0);
    load_in3_in : in std_logic;
    data_in4_in : in std_logic_vector(32-1 downto 0);
    load_in4_in : in std_logic;
    data_out1_out : out std_logic_vector(32-1 downto 0);
    data_out2_out : out std_logic_vector(512-1 downto 0);
    data_out3_out : out std_logic_vector(1024-1 downto 0));
end entity fu_valu;


architecture rtl of fu_valu is
    signal data_out1_r : std_logic_vector(31 downto 0);
    signal data_out2_r : std_logic_vector(511 downto 0);
    signal data_out3_r : std_logic_vector(1023 downto 0);
    signal dspA : signed(512 downto 0);
    signal dspB : signed(512 downto 0);
    signal dspC : signed(1023 downto 0);
    signal dspP1 : signed(1023 downto 0);
    signal dspP2 : signed(1023 downto 0);
    signal dspP3 : signed(1023 downto 0);
begin
  regs : process (clk, rstx)
    --type BITVEC is array (31 downto 0) of std_ulogic;
    variable geu_result : std_logic_vector(31 downto 0);
    constant one : integer := 1;
  begin  -- process regs
    if rstx = '0' then                  -- asynchronous reset (active low)
      data_out1_r <= (others => '0');
      data_out2_r <= (others => '0');
      data_out3_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if glock_in = '0' then
        if load_in1t_in = '1' then
          case operation_in is
            when OPC_SHLSAME16X32 =>
              for i in 0 to 31 loop
                data_out2_r((i+1)*16-1 downto i*16) <= std_logic_vector(shift_left(unsigned(data_in1t_in((i+1)*16-1 downto i*16)), to_integer(unsigned(data_in4_in))));
              end loop;
            when OPC_MAX16X32 =>
              for i in 0 to 31 loop
                if signed(data_in1t_in((i+1)*16-1 downto i*16)) > signed(data_in2_in((i+1)*16-1 downto i*16)) then
                  data_out2_r((i+1)*16-1 downto i*16) <= data_in1t_in((i+1)*16-1 downto i*16);
                else
                  data_out2_r((i+1)*16-1 downto i*16) <= data_in2_in((i+1)*16-1 downto i*16);
                end if;
              end loop;
            when OPC_MAC16X32TO32X32 =>
              for i in 0 to 31 loop
                -- pipe input
                dspA((i+1)*16-1 downto i*16) <= signed(data_in1t_in((i+1)*16-1 downto i*16));
                dspB((i+1)*16-1 downto i*16) <= signed(data_in2_in((i+1)*16-1 downto i*16));
                dspC((i+1)*32-1 downto i*32) <= signed(data_in3_in((i+1)*32-1 downto i*32));
                -- pipe multiply
                --dspP1((i+1)*32-1 downto i*32) <= dspA((i+1)*16-1 downto i*16) * dspB((i+1)*16-1 downto i*16);
                -- pipe accumulate
                dspP2((i+1)*32-1 downto i*32) <= dspC((i+1)*32-1 downto i*32) + dspA((i+1)*16-1 downto i*16) * dspB((i+1)*16-1 downto i*16);
              end loop;
              -- pipe output
              data_out3_r <= std_logic_vector(dspP2);
            when OPC_GEU16X32TO32X1 =>
              geu_result := (others => '0');
--              for j in 0 to 31 loop
--                if unsigned(data_in1t_in((j+1)*16-1 downto j*16)) >= unsigned(data_in2_in((j+1)*16-1 downto j*16)) then
--                  geu_result := geu_result or std_logic_vector(shift_left(to_unsigned(one, 32), j));
--                end if;
--              end loop;
              if unsigned(data_in1t_in(15 downto 0)) >= unsigned(data_in2_in(15 downto 0)) then
                geu_result(5 downto 0) := "111111";
              end if;
              data_out1_r <= geu_result;
--              geu_result := (others => '0');
                
--              for i in 0 to 31 loop
--                if unsigned(data_in1t_in((i+1)*16-1 downto i*16)) >= unsigned(data_in2_in((i+1)*16-1 downto i*16)) then
--                  geu_result(i) := '1';
--                end if;
--              end loop;
--              data_out1_r <= geu_result(0) & geu_result(1) & geu_result(2) & geu_result(3) & geu_result(4) & geu_result(5)
--                               & geu_result(6) & geu_result(7) & geu_result(8) & geu_result(9) & geu_result(10)
--                                & geu_result(11) & geu_result(12) & geu_result(13) & geu_result(14) & geu_result(15)
--                                 & geu_result(16) & geu_result(17) & geu_result(18) & geu_result(19) & geu_result(20)
--                                  & geu_result(21) & geu_result(22) & geu_result(23) & geu_result(24) & geu_result(25)
--                                   & geu_result(26) & geu_result(27) & geu_result(28) & geu_result(29) & geu_result(30)
--                                    & geu_result(31);
            when others =>
              null;
          end case;
        end if;
      end if;
    end if;
  end process regs;

  data_out1_out <= data_out1_r;
  data_out2_out <= data_out2_r;
  data_out3_out <= data_out3_r;

end rtl;
