-- Module generated by TTA Codesign Environment
-- 
-- Generated on Thu Sep 19 16:08:45 2019
-- 
-- Function Unit: FMA
-- 
-- Operations:
--  mac16x32to32x32      : 0
--  xnorpopcountacc32x32 : 1
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity fu_fma is
  port (
    clk : in std_logic;
    rstx : in std_logic;
    glock_in : in std_logic;
    glockreq_out : out std_logic;
    operation_in : in std_logic_vector(1-1 downto 0);
    data_in1t_in : in std_logic_vector(1024-1 downto 0);
    load_in1t_in : in std_logic;
    data_in2_in : in std_logic_vector(1024-1 downto 0);
    load_in2_in : in std_logic;
    data_in3_in : in std_logic_vector(1024-1 downto 0);
    load_in3_in : in std_logic;
    data_out1_out : out std_logic_vector(1024-1 downto 0));
end entity fu_fma;

architecture rtl of fu_fma is

  constant op_mac16x32to32x32_c : std_logic_vector(0 downto 0) := "0";
  constant op_xnorpopcountacc32x32_c : std_logic_vector(0 downto 0) := "1";

  signal mac16x32to32x32_op1 : std_logic_vector(511 downto 0);
  signal mac16x32to32x32_op2 : std_logic_vector(511 downto 0);
  signal mac16x32to32x32_op3 : std_logic_vector(1023 downto 0);
  signal mac16x32to32x32_op4 : std_logic_vector(1023 downto 0);
  signal xnorpopcountacc32x32_op1 : std_logic_vector(31 downto 0);
  signal xnorpopcountacc32x32_op2 : std_logic_vector(1023 downto 0);
  signal xnorpopcountacc32x32_op3 : std_logic_vector(511 downto 0);
  signal xnorpopcountacc32x32_op4 : std_logic_vector(511 downto 0);
  signal data_in1t : std_logic_vector(1023 downto 0);
  signal data_in2 : std_logic_vector(1023 downto 0);
  signal data_in3 : std_logic_vector(1023 downto 0);
  signal data_out1 : std_logic_vector(1023 downto 0);

  signal shadow_in2_r : std_logic_vector(1023 downto 0);
  signal shadow_in3_r : std_logic_vector(1023 downto 0);
  signal operation_1_r : std_logic_vector(0 downto 0);
  signal optrig_1_r : std_logic;
  signal data_out1_1_r : std_logic_vector(1023 downto 0);
  signal data_out1_1_valid_r : std_logic;
  signal data_out1_r : std_logic_vector(1023 downto 0);

begin

  data_in1t <= data_in1t_in;

  shadow_in2_sp : process(clk)
  begin
    if clk = '1' and clk'event then
      if rstx = '0' then
        shadow_in2_r <= (others => '0');
      else
        if ((glock_in = '0') and (load_in2_in = '1')) then
          shadow_in2_r <= data_in2_in;
        end if;
      end if;
    end if;
  end process shadow_in2_sp;

  shadow_in2_cp : process(shadow_in2_r, load_in1t_in, data_in2_in, load_in2_in)
  begin
    if ((load_in1t_in = '1') and (load_in2_in = '1')) then
      data_in2 <= data_in2_in;
    else
      data_in2 <= shadow_in2_r;
    end if;
  end process shadow_in2_cp;

  shadow_in3_sp : process(clk)
  begin
    if clk = '1' and clk'event then
      if rstx = '0' then
        shadow_in3_r <= (others => '0');
      else
        if ((glock_in = '0') and (load_in3_in = '1')) then
          shadow_in3_r <= data_in3_in;
        end if;
      end if;
    end if;
  end process shadow_in3_sp;

  shadow_in3_cp : process(shadow_in3_r, data_in3_in, load_in1t_in, load_in3_in)
  begin
    if ((load_in1t_in = '1') and (load_in3_in = '1')) then
      data_in3 <= data_in3_in;
    else
      data_in3 <= shadow_in3_r;
    end if;
  end process shadow_in3_cp;

  input_pipeline_sp : process(clk)
  begin
    if clk = '1' and clk'event then
      if rstx = '0' then
        operation_1_r <= (others => '0');
        optrig_1_r <= '0';
      else
        if (glock_in = '0') then
          optrig_1_r <= load_in1t_in;
          if (load_in1t_in = '1') then
            operation_1_r <= operation_in;
          end if;
        end if;
      end if;
    end if;
  end process input_pipeline_sp;

  operations_actual_cp : process(operation_in, load_in1t_in, data_in3, data_in2, xnorpopcountacc32x32_op2, xnorpopcountacc32x32_op1, mac16x32to32x32_op1, data_in1t, mac16x32to32x32_op3, xnorpopcountacc32x32_op3, mac16x32to32x32_op2)
    variable xnorpopcountacc32x32_xnor_result : std_logic_vector(32-1 downto 0);
    variable xnorpopcountacc32x32_count : unsigned(16-1 downto 0);
    variable mac16x32to32x32_out_v : signed(32-1 downto 0);
  begin
    xnorpopcountacc32x32_op4 <= (others => '-');
    xnorpopcountacc32x32_op1 <= data_in1t(31 downto 0);
    xnorpopcountacc32x32_op2 <= data_in2;
    xnorpopcountacc32x32_op3 <= data_in3(511 downto 0);
    xnorpopcountacc32x32_xnor_result := (others => '-');
    xnorpopcountacc32x32_count := (others => '-');
    mac16x32to32x32_op4 <= (others => '-');
    mac16x32to32x32_op1 <= data_in1t(511 downto 0);
    mac16x32to32x32_op2 <= data_in2(511 downto 0);
    mac16x32to32x32_op3 <= data_in3;
    mac16x32to32x32_out_v := (others => '-');
    if (load_in1t_in = '1') then
      case operation_in is
        when op_mac16x32to32x32_c =>
          for i in 0 to 31 loop
            mac16x32to32x32_out_v := signed(mac16x32to32x32_op3((i+1)*32-1 downto i*32)) + signed(mac16x32to32x32_op1((i+1)*16-1 downto i*16)) * signed(mac16x32to32x32_op2((i+1)*16-1 downto i*16));
            mac16x32to32x32_op4((i+1)*32-1 downto i*32) <= std_logic_vector(mac16x32to32x32_out_v);
          end loop;
        when op_xnorpopcountacc32x32_c =>
          for i in 0 to 31 loop
            xnorpopcountacc32x32_xnor_result := xnorpopcountacc32x32_op1 xnor xnorpopcountacc32x32_op2((i+1)*32-1 downto i*32);
            xnorpopcountacc32x32_count := unsigned(xnorpopcountacc32x32_op3((i+1)*16-1 downto i*16));
            for j in 0 to 31 loop
              if(xnorpopcountacc32x32_xnor_result(j) = '1') then
                xnorpopcountacc32x32_count := xnorpopcountacc32x32_count + 1;
              end if;
            end loop;
            
            xnorpopcountacc32x32_op4((i+1)*16-1 downto i*16) <= std_logic_vector(xnorpopcountacc32x32_count);
          end loop;
        when others =>
      end case;
    end if;
  end process operations_actual_cp;

  output_pipeline_sp : process(clk)
  begin
    if clk = '1' and clk'event then
      if rstx = '0' then
        data_out1_r <= (others => '0');
        data_out1_1_valid_r <= '0';
        data_out1_1_r <= (others => '0');
      else
        if (glock_in = '0') then
          data_out1_1_valid_r <= '1';
          if ((operation_in = op_xnorpopcountacc32x32_c) and (load_in1t_in = '1')) then
            data_out1_1_r <= ((1024-1 downto 512 => '0') & xnorpopcountacc32x32_op4);
          elsif ((operation_in = op_mac16x32to32x32_c) and (load_in1t_in = '1')) then
            data_out1_1_r <= mac16x32to32x32_op4;
          else
            data_out1_1_valid_r <= '0';
          end if;
          data_out1_r <= data_out1;
        end if;
      end if;
    end if;
  end process output_pipeline_sp;

  output_pipeline_cp : process(data_out1, data_out1_r, data_out1_1_valid_r, data_out1_1_r)
  begin
    if (data_out1_1_valid_r = '1') then
      data_out1 <= data_out1_1_r;
    else
      data_out1 <= data_out1_r;
    end if;
    data_out1_out <= data_out1;
  end process output_pipeline_cp;
  glockreq_out <= '0';

end architecture rtl;

