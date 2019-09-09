library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.ext;
use IEEE.std_logic_arith.sxt;
use work.tta_core_globals.all;
use work.tce_util.all;

entity tta_core_interconn is

  port (
    clk : in std_logic;
    rstx : in std_logic;
    glock : in std_logic;
    socket_ALU_i1_data : out std_logic_vector(31 downto 0);
    socket_ALU_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_ALU_o1_data0 : in std_logic_vector(31 downto 0);
    socket_ALU_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_ALU_i2_data : out std_logic_vector(31 downto 0);
    socket_ALU_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_vALU_i1_data : out std_logic_vector(1023 downto 0);
    socket_vALU_i1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_vALU_i2_data : out std_logic_vector(1023 downto 0);
    socket_vALU_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_vALU_i3_data : out std_logic_vector(1023 downto 0);
    socket_vALU_i3_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_LSU1_i1_data : out std_logic_vector(13 downto 0);
    socket_LSU1_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_LSU1_i2_data : out std_logic_vector(1023 downto 0);
    socket_LSU1_i2_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_LSU1_o1_data0 : in std_logic_vector(1023 downto 0);
    socket_LSU1_o1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_vALU_o1_data0 : in std_logic_vector(1023 downto 0);
    socket_vALU_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_IMM_o1_data0 : in std_logic_vector(31 downto 0);
    socket_IMM_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_RF_BOOL_o1_data0 : in std_logic_vector(0 downto 0);
    socket_RF_BOOL_o1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_RF_BOOL_i1_data : out std_logic_vector(0 downto 0);
    socket_RF32A_o1_data0 : in std_logic_vector(31 downto 0);
    socket_RF32A_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_RF32A_i1_data : out std_logic_vector(31 downto 0);
    socket_RF32A_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_vRF512_o1_data0 : in std_logic_vector(511 downto 0);
    socket_vRF512_o1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_vRF512_i1_data : out std_logic_vector(511 downto 0);
    socket_vRF1024_o1_data0 : in std_logic_vector(1023 downto 0);
    socket_vRF1024_o1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_vRF1024_i1_data : out std_logic_vector(1023 downto 0);
    socket_gcu_i1_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_i2_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_o1_data0 : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_o1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_LSU1_o2_data0 : in std_logic_vector(31 downto 0);
    socket_LSU1_o2_bus_cntrl : in std_logic_vector(2 downto 0);
    simm_B1 : in std_logic_vector(19 downto 0);
    simm_cntrl_B1 : in std_logic_vector(0 downto 0);
    simm_B2 : in std_logic_vector(6 downto 0);
    simm_cntrl_B2 : in std_logic_vector(0 downto 0);
    simm_B3 : in std_logic_vector(6 downto 0);
    simm_cntrl_B3 : in std_logic_vector(0 downto 0);
    db_bustraces : out std_logic_vector(BUSTRACE_WIDTH-1 downto 0));

end tta_core_interconn;

architecture comb_andor of tta_core_interconn is

  signal databus_B1 : std_logic_vector(31 downto 0);
  signal databus_B1_alt0 : std_logic_vector(31 downto 0);
  signal databus_B1_alt1 : std_logic_vector(31 downto 0);
  signal databus_B1_alt2 : std_logic_vector(31 downto 0);
  signal databus_B1_alt3 : std_logic_vector(31 downto 0);
  signal databus_B1_alt4 : std_logic_vector(1023 downto 0);
  signal databus_B1_simm : std_logic_vector(19 downto 0);
  signal databus_B2 : std_logic_vector(31 downto 0);
  signal databus_B2_alt0 : std_logic_vector(31 downto 0);
  signal databus_B2_alt1 : std_logic_vector(31 downto 0);
  signal databus_B2_alt2 : std_logic_vector(31 downto 0);
  signal databus_B2_alt3 : std_logic_vector(31 downto 0);
  signal databus_B2_alt4 : std_logic_vector(0 downto 0);
  signal databus_B2_alt5 : std_logic_vector(31 downto 0);
  signal databus_B2_simm : std_logic_vector(6 downto 0);
  signal databus_B3 : std_logic_vector(31 downto 0);
  signal databus_B3_alt0 : std_logic_vector(31 downto 0);
  signal databus_B3_alt1 : std_logic_vector(31 downto 0);
  signal databus_B3_alt2 : std_logic_vector(31 downto 0);
  signal databus_B3_alt3 : std_logic_vector(31 downto 0);
  signal databus_B3_simm : std_logic_vector(6 downto 0);
  signal databus_vB512A : std_logic_vector(511 downto 0);
  signal databus_vB512A_alt0 : std_logic_vector(1023 downto 0);
  signal databus_vB512A_alt1 : std_logic_vector(1023 downto 0);
  signal databus_vB512A_alt2 : std_logic_vector(511 downto 0);
  signal databus_vB1024A : std_logic_vector(1023 downto 0);
  signal databus_vB1024A_alt0 : std_logic_vector(1023 downto 0);
  signal databus_vB1024A_alt1 : std_logic_vector(1023 downto 0);
  signal databus_vB1024A_alt2 : std_logic_vector(1023 downto 0);

  component tta_core_input_mux_1
    generic (
      BUSW_0 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0));
  end component;

  component tta_core_input_mux_2
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      databus1 : in std_logic_vector(BUSW_1-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0);
      databus_cntrl : in std_logic_vector(0 downto 0));
  end component;

  component tta_core_input_mux_3
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

  component tta_core_input_mux_5
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      BUSW_2 : integer := 32;
      BUSW_3 : integer := 32;
      BUSW_4 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      databus1 : in std_logic_vector(BUSW_1-1 downto 0);
      databus2 : in std_logic_vector(BUSW_2-1 downto 0);
      databus3 : in std_logic_vector(BUSW_3-1 downto 0);
      databus4 : in std_logic_vector(BUSW_4-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0);
      databus_cntrl : in std_logic_vector(2 downto 0));
  end component;

  component tta_core_output_socket_cons_1_1
    generic (
      BUSW_0 : integer := 32;
      DATAW_0 : integer := 32);
    port (
      databus0_alt : out std_logic_vector(BUSW_0-1 downto 0);
      data0 : in std_logic_vector(DATAW_0-1 downto 0);
      databus_cntrl : in std_logic_vector(0 downto 0));
  end component;

  component tta_core_output_socket_cons_2_1
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      DATAW_0 : integer := 32);
    port (
      databus0_alt : out std_logic_vector(BUSW_0-1 downto 0);
      databus1_alt : out std_logic_vector(BUSW_1-1 downto 0);
      data0 : in std_logic_vector(DATAW_0-1 downto 0);
      databus_cntrl : in std_logic_vector(1 downto 0));
  end component;

  component tta_core_output_socket_cons_3_1
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

  db_bustraces <= 
    databus_vB1024A & databus_vB512A & databus_B3 & databus_B2 & 
    databus_B1;

  ALU_i1 : tta_core_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B3,
      databus2 => databus_B2,
      data => socket_ALU_i1_data,
      databus_cntrl => socket_ALU_i1_bus_cntrl);

  ALU_i2 : tta_core_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B2,
      databus1 => databus_B3,
      databus2 => databus_B1,
      data => socket_ALU_i2_data,
      databus_cntrl => socket_ALU_i2_bus_cntrl);

  ALU_o1 : tta_core_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt0,
      databus1_alt => databus_B2_alt0,
      databus2_alt => databus_B3_alt0,
      data0 => socket_ALU_o1_data0,
      databus_cntrl => socket_ALU_o1_bus_cntrl);

  IMM_o1 : tta_core_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt1,
      databus1_alt => databus_B2_alt1,
      databus2_alt => databus_B3_alt1,
      data0 => socket_IMM_o1_data0,
      databus_cntrl => socket_IMM_o1_bus_cntrl);

  LSU1_i1 : tta_core_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 14)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B3,
      databus2 => databus_B2,
      data => socket_LSU1_i1_data,
      databus_cntrl => socket_LSU1_i1_bus_cntrl);

  LSU1_i2 : tta_core_input_mux_5
    generic map (
      BUSW_0 => 1024,
      BUSW_1 => 32,
      BUSW_2 => 32,
      BUSW_3 => 512,
      BUSW_4 => 32,
      DATAW => 1024)
    port map (
      databus0 => databus_vB1024A,
      databus1 => databus_B1,
      databus2 => databus_B2,
      databus3 => databus_vB512A,
      databus4 => databus_B3,
      data => socket_LSU1_i2_data,
      databus_cntrl => socket_LSU1_i2_bus_cntrl);

  LSU1_o1 : tta_core_output_socket_cons_2_1
    generic map (
      BUSW_0 => 1024,
      BUSW_1 => 1024,
      DATAW_0 => 1024)
    port map (
      databus0_alt => databus_vB1024A_alt0,
      databus1_alt => databus_vB512A_alt0,
      data0 => socket_LSU1_o1_data0,
      databus_cntrl => socket_LSU1_o1_bus_cntrl);

  LSU1_o2 : tta_core_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt2,
      databus1_alt => databus_B2_alt2,
      databus2_alt => databus_B3_alt2,
      data0 => socket_LSU1_o2_data0,
      databus_cntrl => socket_LSU1_o2_bus_cntrl);

  RF32A_i1 : tta_core_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B2,
      databus1 => databus_B3,
      databus2 => databus_B1,
      data => socket_RF32A_i1_data,
      databus_cntrl => socket_RF32A_i1_bus_cntrl);

  RF32A_o1 : tta_core_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B2_alt3,
      databus1_alt => databus_B3_alt3,
      databus2_alt => databus_B1_alt3,
      data0 => socket_RF32A_o1_data0,
      databus_cntrl => socket_RF32A_o1_bus_cntrl);

  RF_BOOL_i1 : tta_core_input_mux_1
    generic map (
      BUSW_0 => 32,
      DATAW => 1)
    port map (
      databus0 => databus_B2,
      data => socket_RF_BOOL_i1_data);

  RF_BOOL_o1 : tta_core_output_socket_cons_1_1
    generic map (
      BUSW_0 => 1,
      DATAW_0 => 1)
    port map (
      databus0_alt => databus_B2_alt4,
      data0 => socket_RF_BOOL_o1_data0,
      databus_cntrl => socket_RF_BOOL_o1_bus_cntrl);

  gcu_i1 : tta_core_input_mux_1
    generic map (
      BUSW_0 => 32,
      DATAW => IMEMADDRWIDTH)
    port map (
      databus0 => databus_B1,
      data => socket_gcu_i1_data);

  gcu_i2 : tta_core_input_mux_1
    generic map (
      BUSW_0 => 32,
      DATAW => IMEMADDRWIDTH)
    port map (
      databus0 => databus_B2,
      data => socket_gcu_i2_data);

  gcu_o1 : tta_core_output_socket_cons_1_1
    generic map (
      BUSW_0 => 32,
      DATAW_0 => IMEMADDRWIDTH)
    port map (
      databus0_alt => databus_B2_alt5,
      data0 => socket_gcu_o1_data0,
      databus_cntrl => socket_gcu_o1_bus_cntrl);

  vALU_i1 : tta_core_input_mux_2
    generic map (
      BUSW_0 => 512,
      BUSW_1 => 1024,
      DATAW => 1024)
    port map (
      databus0 => databus_vB512A,
      databus1 => databus_vB1024A,
      data => socket_vALU_i1_data,
      databus_cntrl => socket_vALU_i1_bus_cntrl);

  vALU_i2 : tta_core_input_mux_3
    generic map (
      BUSW_0 => 512,
      BUSW_1 => 1024,
      BUSW_2 => 32,
      DATAW => 1024)
    port map (
      databus0 => databus_vB512A,
      databus1 => databus_vB1024A,
      databus2 => databus_B1,
      data => socket_vALU_i2_data,
      databus_cntrl => socket_vALU_i2_bus_cntrl);

  vALU_i3 : tta_core_input_mux_3
    generic map (
      BUSW_0 => 512,
      BUSW_1 => 1024,
      BUSW_2 => 32,
      DATAW => 1024)
    port map (
      databus0 => databus_vB512A,
      databus1 => databus_vB1024A,
      databus2 => databus_B1,
      data => socket_vALU_i3_data,
      databus_cntrl => socket_vALU_i3_bus_cntrl);

  vALU_o1 : tta_core_output_socket_cons_3_1
    generic map (
      BUSW_0 => 1024,
      BUSW_1 => 1024,
      BUSW_2 => 1024,
      DATAW_0 => 1024)
    port map (
      databus0_alt => databus_vB1024A_alt1,
      databus1_alt => databus_vB512A_alt1,
      databus2_alt => databus_B1_alt4,
      data0 => socket_vALU_o1_data0,
      databus_cntrl => socket_vALU_o1_bus_cntrl);

  vRF1024_i1 : tta_core_input_mux_1
    generic map (
      BUSW_0 => 1024,
      DATAW => 1024)
    port map (
      databus0 => databus_vB1024A,
      data => socket_vRF1024_i1_data);

  vRF1024_o1 : tta_core_output_socket_cons_1_1
    generic map (
      BUSW_0 => 1024,
      DATAW_0 => 1024)
    port map (
      databus0_alt => databus_vB1024A_alt2,
      data0 => socket_vRF1024_o1_data0,
      databus_cntrl => socket_vRF1024_o1_bus_cntrl);

  vRF512_i1 : tta_core_input_mux_1
    generic map (
      BUSW_0 => 512,
      DATAW => 512)
    port map (
      databus0 => databus_vB512A,
      data => socket_vRF512_i1_data);

  vRF512_o1 : tta_core_output_socket_cons_1_1
    generic map (
      BUSW_0 => 512,
      DATAW_0 => 512)
    port map (
      databus0_alt => databus_vB512A_alt2,
      data0 => socket_vRF512_o1_data0,
      databus_cntrl => socket_vRF512_o1_bus_cntrl);

  simm_socket_B1 : tta_core_output_socket_cons_1_1
    generic map (
      BUSW_0 => 20,
      DATAW_0 => 20)
    port map (
      databus0_alt => databus_B1_simm,
      data0 => simm_B1,
      databus_cntrl => simm_cntrl_B1);

  simm_socket_B2 : tta_core_output_socket_cons_1_1
    generic map (
      BUSW_0 => 7,
      DATAW_0 => 7)
    port map (
      databus0_alt => databus_B2_simm,
      data0 => simm_B2,
      databus_cntrl => simm_cntrl_B2);

  simm_socket_B3 : tta_core_output_socket_cons_1_1
    generic map (
      BUSW_0 => 7,
      DATAW_0 => 7)
    port map (
      databus0_alt => databus_B3_simm,
      data0 => simm_B3,
      databus_cntrl => simm_cntrl_B3);

  databus_B1 <= tce_ext(databus_B1_alt0, databus_B1'length) or tce_ext(databus_B1_alt1, databus_B1'length) or tce_ext(databus_B1_alt2, databus_B1'length) or tce_ext(databus_B1_alt3, databus_B1'length) or tce_ext(databus_B1_alt4, databus_B1'length) or tce_ext(databus_B1_simm, databus_B1'length);
  databus_B2 <= tce_ext(databus_B2_alt0, databus_B2'length) or tce_ext(databus_B2_alt1, databus_B2'length) or tce_ext(databus_B2_alt2, databus_B2'length) or tce_ext(databus_B2_alt3, databus_B2'length) or tce_ext(databus_B2_alt4, databus_B2'length) or tce_ext(databus_B2_alt5, databus_B2'length) or tce_ext(databus_B2_simm, databus_B2'length);
  databus_B3 <= tce_ext(databus_B3_alt0, databus_B3'length) or tce_ext(databus_B3_alt1, databus_B3'length) or tce_ext(databus_B3_alt2, databus_B3'length) or tce_ext(databus_B3_alt3, databus_B3'length) or tce_ext(databus_B3_simm, databus_B3'length);
  databus_vB512A <= tce_ext(databus_vB512A_alt0, databus_vB512A'length) or tce_ext(databus_vB512A_alt1, databus_vB512A'length) or tce_ext(databus_vB512A_alt2, databus_vB512A'length);
  databus_vB1024A <= tce_ext(databus_vB1024A_alt0, databus_vB1024A'length) or tce_ext(databus_vB1024A_alt1, databus_vB1024A'length) or tce_ext(databus_vB1024A_alt2, databus_vB1024A'length);

end comb_andor;
