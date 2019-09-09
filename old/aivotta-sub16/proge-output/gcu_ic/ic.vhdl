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
    socket_ALU_i2_data : out std_logic_vector(31 downto 0);
    socket_ALU_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_vALU_i1_data : out std_logic_vector(1023 downto 0);
    socket_vALU_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_vALU_i2_data : out std_logic_vector(1023 downto 0);
    socket_vALU_i2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_vALU_i3_data : out std_logic_vector(1023 downto 0);
    socket_vALU_i3_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_LSU1_i1_data : out std_logic_vector(15 downto 0);
    socket_LSU1_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_LSU1_i2_data : out std_logic_vector(1023 downto 0);
    socket_LSU1_i2_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_RF_BOOL_i1_data : out std_logic_vector(0 downto 0);
    socket_RF32A_i1_data : out std_logic_vector(31 downto 0);
    socket_RF32A_i1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_vRF512_i1_data : out std_logic_vector(511 downto 0);
    socket_vRF1024_i1_data : out std_logic_vector(1023 downto 0);
    socket_gcu_i1_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_i2_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    B1_mux_ctrl_in : in std_logic_vector(2 downto 0);
    B1_data_0_in : in std_logic_vector(31 downto 0);
    B1_data_1_in : in std_logic_vector(1023 downto 0);
    B1_data_2_in : in std_logic_vector(31 downto 0);
    B1_data_3_in : in std_logic_vector(31 downto 0);
    B1_data_4_in : in std_logic_vector(31 downto 0);
    B2_mux_ctrl_in : in std_logic_vector(2 downto 0);
    B2_data_0_in : in std_logic_vector(31 downto 0);
    B2_data_1_in : in std_logic_vector(31 downto 0);
    B2_data_2_in : in std_logic_vector(0 downto 0);
    B2_data_3_in : in std_logic_vector(31 downto 0);
    B2_data_4_in : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    B2_data_5_in : in std_logic_vector(31 downto 0);
    B3_mux_ctrl_in : in std_logic_vector(2 downto 0);
    B3_data_0_in : in std_logic_vector(31 downto 0);
    B3_data_1_in : in std_logic_vector(31 downto 0);
    B3_data_2_in : in std_logic_vector(31 downto 0);
    B3_data_3_in : in std_logic_vector(31 downto 0);
    vB512A_mux_ctrl_in : in std_logic_vector(1 downto 0);
    vB512A_data_0_in : in std_logic_vector(1023 downto 0);
    vB512A_data_1_in : in std_logic_vector(1023 downto 0);
    vB512A_data_2_in : in std_logic_vector(511 downto 0);
    vB1024A_mux_ctrl_in : in std_logic_vector(1 downto 0);
    vB1024A_data_0_in : in std_logic_vector(1023 downto 0);
    vB1024A_data_1_in : in std_logic_vector(1023 downto 0);
    vB1024A_data_2_in : in std_logic_vector(1023 downto 0);
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
  signal databus_B2 : std_logic_vector(31 downto 0);
  signal databus_B3 : std_logic_vector(31 downto 0);
  signal databus_vB512A : std_logic_vector(511 downto 0);
  signal databus_vB1024A : std_logic_vector(1023 downto 0);

  component tta_core_input_mux_1
    generic (
      BUSW_0 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0));
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

  component tta_core_input_mux_6
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      BUSW_2 : integer := 32;
      BUSW_3 : integer := 32;
      BUSW_4 : integer := 32;
      BUSW_5 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      databus1 : in std_logic_vector(BUSW_1-1 downto 0);
      databus2 : in std_logic_vector(BUSW_2-1 downto 0);
      databus3 : in std_logic_vector(BUSW_3-1 downto 0);
      databus4 : in std_logic_vector(BUSW_4-1 downto 0);
      databus5 : in std_logic_vector(BUSW_5-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0);
      databus_cntrl : in std_logic_vector(2 downto 0));
  end component;

  component tta_core_input_mux_7
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      BUSW_2 : integer := 32;
      BUSW_3 : integer := 32;
      BUSW_4 : integer := 32;
      BUSW_5 : integer := 32;
      BUSW_6 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      databus1 : in std_logic_vector(BUSW_1-1 downto 0);
      databus2 : in std_logic_vector(BUSW_2-1 downto 0);
      databus3 : in std_logic_vector(BUSW_3-1 downto 0);
      databus4 : in std_logic_vector(BUSW_4-1 downto 0);
      databus5 : in std_logic_vector(BUSW_5-1 downto 0);
      databus6 : in std_logic_vector(BUSW_6-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0);
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

  LSU1_i1 : tta_core_input_mux_3
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW => 16)
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

  RF_BOOL_i1 : tta_core_input_mux_1
    generic map (
      BUSW_0 => 32,
      DATAW => 1)
    port map (
      databus0 => databus_B2,
      data => socket_RF_BOOL_i1_data);

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

  vALU_i1 : tta_core_input_mux_3
    generic map (
      BUSW_0 => 512,
      BUSW_1 => 1024,
      BUSW_2 => 32,
      DATAW => 1024)
    port map (
      databus0 => databus_vB512A,
      databus1 => databus_vB1024A,
      databus2 => databus_B1,
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

  vRF1024_i1 : tta_core_input_mux_1
    generic map (
      BUSW_0 => 1024,
      DATAW => 1024)
    port map (
      databus0 => databus_vB1024A,
      data => socket_vRF1024_i1_data);

  vRF512_i1 : tta_core_input_mux_1
    generic map (
      BUSW_0 => 512,
      DATAW => 512)
    port map (
      databus0 => databus_vB512A,
      data => socket_vRF512_i1_data);

  B1_bus_mux_inst : tta_core_input_mux_6
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 1024,
      BUSW_2 => 32,
      BUSW_3 => 32,
      BUSW_4 => 32,
      BUSW_5 => 20,
      DATAW => 32)
    port map (
      databus0 => B1_data_0_in,
      databus1 => B1_data_1_in,
      databus2 => B1_data_2_in,
      databus3 => B1_data_3_in,
      databus4 => B1_data_4_in,
      databus5 => simm_B1,
      data => databus_B1,
      databus_cntrl => B1_mux_ctrl_in);

  B2_bus_mux_inst : tta_core_input_mux_7
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 1,
      BUSW_3 => 32,
      BUSW_4 => IMEMADDRWIDTH,
      BUSW_5 => 32,
      BUSW_6 => 7,
      DATAW => 32)
    port map (
      databus0 => B2_data_0_in,
      databus1 => B2_data_1_in,
      databus2 => B2_data_2_in,
      databus3 => B2_data_3_in,
      databus4 => B2_data_4_in,
      databus5 => B2_data_5_in,
      databus6 => simm_B2,
      data => databus_B2,
      databus_cntrl => B2_mux_ctrl_in);

  B3_bus_mux_inst : tta_core_input_mux_5
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      BUSW_3 => 32,
      BUSW_4 => 7,
      DATAW => 32)
    port map (
      databus0 => B3_data_0_in,
      databus1 => B3_data_1_in,
      databus2 => B3_data_2_in,
      databus3 => B3_data_3_in,
      databus4 => simm_B3,
      data => databus_B3,
      databus_cntrl => B3_mux_ctrl_in);

  vB512A_bus_mux_inst : tta_core_input_mux_3
    generic map (
      BUSW_0 => 1024,
      BUSW_1 => 1024,
      BUSW_2 => 512,
      DATAW => 512)
    port map (
      databus0 => vB512A_data_0_in,
      databus1 => vB512A_data_1_in,
      databus2 => vB512A_data_2_in,
      data => databus_vB512A,
      databus_cntrl => vB512A_mux_ctrl_in);

  vB1024A_bus_mux_inst : tta_core_input_mux_3
    generic map (
      BUSW_0 => 1024,
      BUSW_1 => 1024,
      BUSW_2 => 1024,
      DATAW => 1024)
    port map (
      databus0 => vB1024A_data_0_in,
      databus1 => vB1024A_data_1_in,
      databus2 => vB1024A_data_2_in,
      data => databus_vB1024A,
      databus_cntrl => vB1024A_mux_ctrl_in);


end comb_andor;
