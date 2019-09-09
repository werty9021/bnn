-- This file is generated. Do not modify!

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_arith.all;

entity BNN_OPS_v32 is
  port(
    t1data	 : in std_logic_vector(1023 downto 0);
    t1load	 : in std_logic;
    t1opcode	 : in std_logic_vector(0 downto 0);
    r1data	 : out std_logic_vector(1023 downto 0);
    o3data	 : out std_logic_vector(1023 downto 0);
    o3load	 : in std_logic;
    o2data	 : in std_logic_vector(1023 downto 0);
    o2load	 : in std_logic;
    glock	 : in std_logic;
    rstx	 : in std_logic;
    clk	 : in std_logic);
end BNN_OPS_v32;

architecture rtl of BNN_OPS_v32 is
  signal t1data_s	 : std_logic_vector(1023 downto 0);
  signal r1data_s	 : std_logic_vector(1023 downto 0);
  signal o3data_s	 : std_logic_vector(1023 downto 0);
  signal o2data_s	 : std_logic_vector(1023 downto 0);
  signal pipelined_opcode_delay1_r	 : std_logic_vector(0 downto 0);
begin

FU_GEN :
   for i in 0 to 31 generate
     begin
      BNN_OPS_inst : entity work.BNN_OPS
        generic map(
          busw	 => 32)
        port map(
          t1data	 => t1data_s((i+1)*32-1 downto i*32),
          t1load	 => t1load,
          t1opcode	 => t1opcode,
          r1data	 => r1data_s((i+1)*32-1 downto i*32),
          o3data	 => o3data_s((i+1)*32-1 downto i*32),
          o2data	 => o2data_s((i+1)*32-1 downto i*32),
          o2load	 => o2load,
          glock	 => glock,
          rstx	 => rstx,
          clk	 => clk);
  end generate FU_GEN;


  -- Connects inputs correctly
  input_control: process (t1opcode, t1data, o2data)
  begin
    case t1opcode is
      when others =>  -- Direct connections
        t1data_s	 <= t1data;
        o2data_s	 <= o2data;
    end case;
  end process input_control;


  -- Connects outputs correctly
  output_control: process (r1data_s, pipelined_opcode_delay1_r)
  begin
    r1data	 <= (others=>'0');
    case pipelined_opcode_delay1_r is
      when others =>  -- Direct connections
        r1data	 <= r1data_s;
    end case;
  end process output_control;


  -- Pipelines opcode for output_control
  opcode_pipeline_control: process (clk, rstx)
    begin
      if rstx = '0' then
        pipelined_opcode_delay1_r	 <= (others => '0');
      elsif clk'event and clk = '1' then
        if glock='0' then
          pipelined_opcode_delay1_r	 <= t1opcode;
        end if;
      end if;
  end process opcode_pipeline_control;

end rtl;
