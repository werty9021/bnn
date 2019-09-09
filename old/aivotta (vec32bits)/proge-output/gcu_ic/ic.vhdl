library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.ext;
use IEEE.std_logic_arith.sxt;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;
use work.tta0_globals.all;
use work.tce_util.all;

entity tta0_interconn is

  port (
    clk : in std_logic;
    rstx : in std_logic;
    glock : in std_logic;
    socket_RF_i1_data : out std_logic_vector(31 downto 0);
    socket_RF_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_RF_o1_data0 : in std_logic_vector(31 downto 0);
    socket_RF_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_bool_i1_data : out std_logic_vector(0 downto 0);
    socket_bool_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_bool_o1_data0 : in std_logic_vector(0 downto 0);
    socket_bool_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_gcu_i1_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_gcu_i2_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_gcu_o1_data0 : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_data : out std_logic_vector(31 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_data : out std_logic_vector(31 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_data : out std_logic_vector(31 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_data0 : in std_logic_vector(31 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_LSU_i1_data : out std_logic_vector(29 downto 0);
    socket_LSU_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_LSU_o1_data0 : in std_logic_vector(31 downto 0);
    socket_LSU_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_LSU_i2_data : out std_logic_vector(31 downto 0);
    socket_LSU_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_LSU_inp_i1_data : out std_logic_vector(23 downto 0);
    socket_LSU_inp_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_LSU_inp_o1_data0 : in std_logic_vector(31 downto 0);
    socket_LSU_inp_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_LSU_inp_i2_data : out std_logic_vector(31 downto 0);
    socket_LSU_inp_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_ALU_i3_data : out std_logic_vector(31 downto 0);
    socket_ALU_i3_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_ALU_o2_data0 : in std_logic_vector(31 downto 0);
    socket_ALU_o2_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_ALU_i4_data : out std_logic_vector(31 downto 0);
    socket_ALU_i4_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_STREAM_i2_data : out std_logic_vector(7 downto 0);
    socket_STREAM_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_cfi_cfiu_cif_cifu_i1_data : out std_logic_vector(31 downto 0);
    socket_cfi_cfiu_cif_cifu_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_cfi_cfiu_cif_cifu_o1_data0 : in std_logic_vector(31 downto 0);
    socket_cfi_cfiu_cif_cifu_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_divf_i1_data : out std_logic_vector(31 downto 0);
    socket_divf_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_divf_i2_data : out std_logic_vector(31 downto 0);
    socket_divf_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_divf_o1_data0 : in std_logic_vector(31 downto 0);
    socket_divf_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_IMM1_o1_data0 : in std_logic_vector(31 downto 0);
    socket_IMM1_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_data : out std_logic_vector(31 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_data0 : in std_logic_vector(31 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_data : out std_logic_vector(31 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_data : out std_logic_vector(31 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl : in std_logic_vector(1 downto 0);
    simm_B1 : in std_logic_vector(31 downto 0);
    simm_cntrl_B1 : in std_logic_vector(0 downto 0);
    simm_B1_1 : in std_logic_vector(31 downto 0);
    simm_cntrl_B1_1 : in std_logic_vector(0 downto 0);
    simm_B1_2 : in std_logic_vector(31 downto 0);
    simm_cntrl_B1_2 : in std_logic_vector(0 downto 0));

end tta0_interconn;

architecture comb_andor of tta0_interconn is

  signal databus_B1 : std_logic_vector(31 downto 0);
  signal databus_B1_alt0 : std_logic_vector(31 downto 0);
  signal databus_B1_alt1 : std_logic_vector(31 downto 0);
  signal databus_B1_alt2 : std_logic_vector(31 downto 0);
  signal databus_B1_alt3 : std_logic_vector(31 downto 0);
  signal databus_B1_alt4 : std_logic_vector(31 downto 0);
  signal databus_B1_alt5 : std_logic_vector(0 downto 0);
  signal databus_B1_alt6 : std_logic_vector(31 downto 0);
  signal databus_B1_alt7 : std_logic_vector(31 downto 0);
  signal databus_B1_alt8 : std_logic_vector(31 downto 0);
  signal databus_B1_alt9 : std_logic_vector(31 downto 0);
  signal databus_B1_alt10 : std_logic_vector(31 downto 0);
  signal databus_B1_simm : std_logic_vector(31 downto 0);
  signal databus_B1_1 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt0 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt1 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt2 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt3 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt4 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt5 : std_logic_vector(0 downto 0);
  signal databus_B1_1_alt6 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt7 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt8 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt9 : std_logic_vector(31 downto 0);
  signal databus_B1_1_alt10 : std_logic_vector(31 downto 0);
  signal databus_B1_1_simm : std_logic_vector(31 downto 0);
  signal databus_B1_2 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt0 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt1 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt2 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt3 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt4 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt5 : std_logic_vector(0 downto 0);
  signal databus_B1_2_alt6 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt7 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt8 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt9 : std_logic_vector(31 downto 0);
  signal databus_B1_2_alt10 : std_logic_vector(31 downto 0);
  signal databus_B1_2_simm : std_logic_vector(31 downto 0);

  component tta0_input_mux_3
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      BUSW_2 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      databus1 : in std_logic_vector(BUSW_1-1 downto 0);
      databus2 : in std_logic_vector(BUSW_2-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0);
      databus_cntrl : in std_logic_vector(1 downto 0));
  end component;

  component tta0_output_socket_cons_1_1
    generic (
      BUSW_0 : integer := 32;
      DATAW_0 : integer := 32);
    port (
      databus0_alt : out std_logic_vector(BUSW_0-1 downto 0);
      data0 : in std_logic_vector(DATAW_0-1 downto 0);
      databus_cntrl : in std_logic_vector(0 downto 0));
  end component;

  component tta0_output_socket_cons_3_1
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      BUSW_2 : integer := 32;
      DATAW_0 : integer := 32);
    port (
      databus0_alt : out std_logic_vector(BUSW_0-1 downto 0);
      databus1_alt : out std_logic_vector(BUSW_1-1 downto 0);
      databus2_alt : out std_logic_vector(BUSW_2-1 downto 0);
      data0 : in std_logic_vector(DATAW_0-1 downto 0);
      databus_cntrl : in std_logic_vector(2 downto 0));
  end component;


begin -- comb_andor

  -- Dump the value on the buses into a file once in clock cycle
  -- setting DUMP false will disable dumping

  -- Do not synthesize this process!
  -- pragma synthesis_off
  -- pragma translate_off
  file_output : process

    file regularfileout : text;
    file executionfileout : text;

    variable lineout : line;
    variable start : boolean := true;
    variable cyclecount : integer := 0;
    variable executioncount : integer := 0;

    constant DUMP : boolean := true;
    constant REGULARDUMPFILE : string := "bus.dump";
    constant EXECUTIONDUMPFILE : string := "execbus.dump";

    -- Rounds integer up to next multiple of four.
    function ceil4 (
      constant val : natural)
      return natural is
    begin  -- function ceil4
      return natural(ceil(real(val)/real(4)))*4;
    end function ceil4;

   -- Extends std_logic_vector to multiple of four.
   function ext_to_multiple_of_4 (
     constant slv : std_logic_vector)
     return std_logic_vector is
    begin
      return std_logic_vector(resize(
        unsigned(slv), ceil4(slv'length)));
    end function ext_to_multiple_of_4;

    function to_unsigned_hex (
      constant slv : std_logic_vector) return string is
      variable resized_slv : std_logic_vector(ceil4(slv'length)-1 downto 0);
      variable result      : string(1 to ceil4(slv'length)/4)
        := (others => ' ');
      subtype digit_t is std_logic_vector(3 downto 0);
      variable digit : digit_t := "0000";
    begin
      resized_slv := ext_to_multiple_of_4(slv);
      for i in result'range loop
        digit := resized_slv(
          resized_slv'length-((i-1)*4)-1 downto resized_slv'length-(i*4));
        case digit is
          when "0000" => result(i) := '0';
          when "0001" => result(i) := '1';
          when "0010" => result(i) := '2';
          when "0011" => result(i) := '3';
          when "0100" => result(i) := '4';
          when "0101" => result(i) := '5';
          when "0110" => result(i) := '6';
          when "0111" => result(i) := '7';
          when "1000" => result(i) := '8';
          when "1001" => result(i) := '9';
          when "1010" => result(i) := 'a';
          when "1011" => result(i) := 'b';
          when "1100" => result(i) := 'c';
          when "1101" => result(i) := 'd';
          when "1110" => result(i) := 'e';
          when "1111" => result(i) := 'f';

          -- For TTAsim bustrace compatibility
          when others => 
            result := (others => '0');
            return result;
        end case;
      end loop;  -- i in result'range
      return result;
    end function to_unsigned_hex;

  begin
    if DUMP = true then
      if start = true then
        file_open(regularfileout, REGULARDUMPFILE, write_mode);
        file_open(executionfileout, EXECUTIONDUMPFILE, write_mode);
        start := false;
      end if;

      -- wait until rising edge of clock
      wait on clk until clk = '1' and clk'last_value = '0';
      if (cyclecount > 4) then
        write(lineout, cyclecount-5);
        write(lineout, string'(","));
        write(lineout, to_unsigned_hex(databus_B1));
        write(lineout, string'(","));
        write(lineout, to_unsigned_hex(databus_B1_1));
        write(lineout, string'(","));
        write(lineout, to_unsigned_hex(databus_B1_2));

        writeline(regularfileout, lineout);
        if glock = '0' then
          write(lineout, executioncount);
          write(lineout, string'(","));
          write(lineout, to_unsigned_hex(databus_B1));
          write(lineout, string'(","));
          write(lineout, to_unsigned_hex(databus_B1_1));
          write(lineout, string'(","));
          write(lineout, to_unsigned_hex(databus_B1_2));

          writeline(executionfileout, lineout);
          executioncount := executioncount + 1;
        end if;
      end if;
      cyclecount := cyclecount + 1;
    end if;
  end process file_output;
  -- pragma translate_on
  -- pragma synthesis_on

  ALU_i3 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_ALU_i3_data,
      databus_cntrl => socket_ALU_i3_bus_cntrl);

  ALU_i4 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_ALU_i4_data,
      databus_cntrl => socket_ALU_i4_bus_cntrl);

  ALU_o2 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt0,
      databus1_alt => databus_B1_1_alt0,
      databus2_alt => databus_B1_2_alt0,
      data0 => socket_ALU_o2_data0,
      databus_cntrl => socket_ALU_o2_bus_cntrl);

  IMM1_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt1,
      databus1_alt => databus_B1_1_alt1,
      databus2_alt => databus_B1_2_alt1,
      data0 => socket_IMM1_o1_data0,
      databus_cntrl => socket_IMM1_o1_bus_cntrl);

  LSU_i1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 30)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_LSU_i1_data,
      databus_cntrl => socket_LSU_i1_bus_cntrl);

  LSU_i2 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_LSU_i2_data,
      databus_cntrl => socket_LSU_i2_bus_cntrl);

  LSU_inp_i1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 24)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_LSU_inp_i1_data,
      databus_cntrl => socket_LSU_inp_i1_bus_cntrl);

  LSU_inp_i2 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_LSU_inp_i2_data,
      databus_cntrl => socket_LSU_inp_i2_bus_cntrl);

  LSU_inp_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt2,
      databus1_alt => databus_B1_1_alt2,
      databus2_alt => databus_B1_2_alt2,
      data0 => socket_LSU_inp_o1_data0,
      databus_cntrl => socket_LSU_inp_o1_bus_cntrl);

  LSU_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt3,
      databus1_alt => databus_B1_1_alt3,
      databus2_alt => databus_B1_2_alt3,
      data0 => socket_LSU_o1_data0,
      databus_cntrl => socket_LSU_o1_bus_cntrl);

  RF_i1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_RF_i1_data,
      databus_cntrl => socket_RF_i1_bus_cntrl);

  RF_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt4,
      databus1_alt => databus_B1_1_alt4,
      databus2_alt => databus_B1_2_alt4,
      data0 => socket_RF_o1_data0,
      databus_cntrl => socket_RF_o1_bus_cntrl);

  STREAM_i2 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 8)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_STREAM_i2_data,
      databus_cntrl => socket_STREAM_i2_bus_cntrl);

  bool_i1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 1)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_bool_i1_data,
      databus_cntrl => socket_bool_i1_bus_cntrl);

  bool_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 1,
      BUSW_1 => 1,
      BUSW_2 => 1,
      DATAW_0 => 1)
    port map (
      databus0_alt => databus_B1_alt5,
      databus1_alt => databus_B1_1_alt5,
      databus2_alt => databus_B1_2_alt5,
      data0 => socket_bool_o1_data0,
      databus_cntrl => socket_bool_o1_bus_cntrl);

  cfi_cfiu_cif_cifu_i1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_cfi_cfiu_cif_cifu_i1_data,
      databus_cntrl => socket_cfi_cfiu_cif_cifu_i1_bus_cntrl);

  cfi_cfiu_cif_cifu_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt6,
      databus1_alt => databus_B1_1_alt6,
      databus2_alt => databus_B1_2_alt6,
      data0 => socket_cfi_cfiu_cif_cifu_o1_data0,
      databus_cntrl => socket_cfi_cfiu_cif_cifu_o1_bus_cntrl);

  divf_i1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_divf_i1_data,
      databus_cntrl => socket_divf_i1_bus_cntrl);

  divf_i2 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_divf_i2_data,
      databus_cntrl => socket_divf_i2_bus_cntrl);

  divf_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt7,
      databus1_alt => databus_B1_1_alt7,
      databus2_alt => databus_B1_2_alt7,
      data0 => socket_divf_o1_data0,
      databus_cntrl => socket_divf_o1_bus_cntrl);

  gcu_i1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => IMEMADDRWIDTH)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_gcu_i1_data,
      databus_cntrl => socket_gcu_i1_bus_cntrl);

  gcu_i2 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => IMEMADDRWIDTH)
    port map (
      databus0 => databus_B1_1,
      databus1 => databus_B1_2,
      databus2 => databus_B1,
      data => socket_gcu_i2_data,
      databus_cntrl => socket_gcu_i2_bus_cntrl);

  gcu_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => IMEMADDRWIDTH)
    port map (
      databus0_alt => databus_B1_alt8,
      databus1_alt => databus_B1_1_alt8,
      databus2_alt => databus_B1_2_alt8,
      data0 => socket_gcu_o1_data0,
      databus_cntrl => socket_gcu_o1_bus_cntrl);

  macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_data,
      databus_cntrl => socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl);

  macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_data,
      databus_cntrl => socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl);

  macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_data,
      databus_cntrl => socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl);

  macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt9,
      databus1_alt => databus_B1_1_alt9,
      databus2_alt => databus_B1_2_alt9,
      data0 => socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_data0,
      databus_cntrl => socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl);

  popcount_popcountacc_xnorpopcntacc_set_bit_i1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_data,
      databus_cntrl => socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl);

  popcount_popcountacc_xnorpopcntacc_set_bit_i2 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_data,
      databus_cntrl => socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl);

  popcount_popcountacc_xnorpopcntacc_set_bit_i3 : tta0_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B1_1,
      databus2 => databus_B1_2,
      data => socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_data,
      databus_cntrl => socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl);

  popcount_popcountacc_xnorpopcntacc_set_bit_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt10,
      databus1_alt => databus_B1_1_alt10,
      databus2_alt => databus_B1_2_alt10,
      data0 => socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_data0,
      databus_cntrl => socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl);

  simm_socket_B1 : tta0_output_socket_cons_1_1
    generic map (
      BUSW_0 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_simm,
      data0 => simm_B1,
      databus_cntrl => simm_cntrl_B1);

  simm_socket_B1_1 : tta0_output_socket_cons_1_1
    generic map (
      BUSW_0 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_1_simm,
      data0 => simm_B1_1,
      databus_cntrl => simm_cntrl_B1_1);

  simm_socket_B1_2 : tta0_output_socket_cons_1_1
    generic map (
      BUSW_0 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_2_simm,
      data0 => simm_B1_2,
      databus_cntrl => simm_cntrl_B1_2);

  databus_B1 <= tce_ext(databus_B1_alt0, databus_B1'length) or tce_ext(databus_B1_alt1, databus_B1'length) or tce_ext(databus_B1_alt2, databus_B1'length) or tce_ext(databus_B1_alt3, databus_B1'length) or tce_ext(databus_B1_alt4, databus_B1'length) or tce_ext(databus_B1_alt5, databus_B1'length) or tce_ext(databus_B1_alt6, databus_B1'length) or tce_ext(databus_B1_alt7, databus_B1'length) or tce_ext(databus_B1_alt8, databus_B1'length) or tce_ext(databus_B1_alt9, databus_B1'length) or tce_ext(databus_B1_alt10, databus_B1'length) or tce_ext(databus_B1_simm, databus_B1'length);
  databus_B1_1 <= tce_ext(databus_B1_1_alt0, databus_B1_1'length) or tce_ext(databus_B1_1_alt1, databus_B1_1'length) or tce_ext(databus_B1_1_alt2, databus_B1_1'length) or tce_ext(databus_B1_1_alt3, databus_B1_1'length) or tce_ext(databus_B1_1_alt4, databus_B1_1'length) or tce_ext(databus_B1_1_alt5, databus_B1_1'length) or tce_ext(databus_B1_1_alt6, databus_B1_1'length) or tce_ext(databus_B1_1_alt7, databus_B1_1'length) or tce_ext(databus_B1_1_alt8, databus_B1_1'length) or tce_ext(databus_B1_1_alt9, databus_B1_1'length) or tce_ext(databus_B1_1_alt10, databus_B1_1'length) or tce_ext(databus_B1_1_simm, databus_B1_1'length);
  databus_B1_2 <= tce_ext(databus_B1_2_alt0, databus_B1_2'length) or tce_ext(databus_B1_2_alt1, databus_B1_2'length) or tce_ext(databus_B1_2_alt2, databus_B1_2'length) or tce_ext(databus_B1_2_alt3, databus_B1_2'length) or tce_ext(databus_B1_2_alt4, databus_B1_2'length) or tce_ext(databus_B1_2_alt5, databus_B1_2'length) or tce_ext(databus_B1_2_alt6, databus_B1_2'length) or tce_ext(databus_B1_2_alt7, databus_B1_2'length) or tce_ext(databus_B1_2_alt8, databus_B1_2'length) or tce_ext(databus_B1_2_alt9, databus_B1_2'length) or tce_ext(databus_B1_2_alt10, databus_B1_2'length) or tce_ext(databus_B1_2_simm, databus_B1_2'length);

end comb_andor;
