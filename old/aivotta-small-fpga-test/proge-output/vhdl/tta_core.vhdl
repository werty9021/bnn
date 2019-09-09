library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tce_util.all;
use work.tta_core_globals.all;
use work.tta_core_imem_mau.all;
use work.tta_core_params.all;

entity tta_core is

  generic (
    core_id : integer := 0);

  port (
    clk : in std_logic;
    rstx : in std_logic;
    busy : in std_logic;
    imem_en_x : out std_logic;
    imem_addr : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    imem_data : in std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
    locked : out std_logic;
    fu_LSU1_avalid_out : out std_logic_vector(0 downto 0);
    fu_LSU1_aready_in : in std_logic_vector(0 downto 0);
    fu_LSU1_aaddr_out : out std_logic_vector(fu_LSU1_addrw_g-7-1 downto 0);
    fu_LSU1_awren_out : out std_logic_vector(0 downto 0);
    fu_LSU1_astrb_out : out std_logic_vector(127 downto 0);
    fu_LSU1_adata_out : out std_logic_vector(1023 downto 0);
    fu_LSU1_rvalid_in : in std_logic_vector(0 downto 0);
    fu_LSU1_rready_out : out std_logic_vector(0 downto 0);
    fu_LSU1_rdata_in : in std_logic_vector(1023 downto 0);
    db_tta_nreset : in std_logic;
    db_lockcnt : out std_logic_vector(63 downto 0);
    db_cyclecnt : out std_logic_vector(63 downto 0);
    db_pc : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    db_lockrq : in std_logic;
    db_pc_start : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    db_bustraces : out std_logic_vector(BUSTRACE_WIDTH-1 downto 0);
    db_pc_next : out std_logic_vector(IMEMADDRWIDTH-1 downto 0));

end tta_core;

architecture structural of tta_core is

  signal decomp_fetch_en_wire : std_logic;
  signal decomp_lock_wire : std_logic;
  signal decomp_fetchblock_wire : std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
  signal decomp_instructionword_wire : std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
  signal decomp_glock_wire : std_logic;
  signal decomp_lock_r_wire : std_logic;
  signal fu_ALU_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_ALU_t1load_wire : std_logic;
  signal fu_ALU_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_ALU_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_ALU_o1load_wire : std_logic;
  signal fu_ALU_t1opcode_wire : std_logic_vector(3 downto 0);
  signal fu_ALU_glock_wire : std_logic;
  signal fu_LSU1_t1_address_in_wire : std_logic_vector(13 downto 0);
  signal fu_LSU1_t1_load_in_wire : std_logic;
  signal fu_LSU1_r1_data_out_wire : std_logic_vector(1023 downto 0);
  signal fu_LSU1_r2_data_out_wire : std_logic_vector(31 downto 0);
  signal fu_LSU1_o1_data_in_wire : std_logic_vector(1023 downto 0);
  signal fu_LSU1_o1_load_in_wire : std_logic;
  signal fu_LSU1_t1_opcode_in_wire : std_logic_vector(2 downto 0);
  signal fu_LSU1_glock_in_wire : std_logic;
  signal fu_LSU1_glockreq_out_wire : std_logic;
  signal fu_valu_generated_glock_in_wire : std_logic;
  signal fu_valu_generated_operation_in_wire : std_logic_vector(4-1 downto 0);
  signal fu_valu_generated_glockreq_out_wire : std_logic;
  signal fu_valu_generated_data_in1t_in_wire : std_logic_vector(1024-1 downto 0);
  signal fu_valu_generated_load_in1t_in_wire : std_logic;
  signal fu_valu_generated_data_in2_in_wire : std_logic_vector(1024-1 downto 0);
  signal fu_valu_generated_load_in2_in_wire : std_logic;
  signal fu_valu_generated_data_in3_in_wire : std_logic_vector(1024-1 downto 0);
  signal fu_valu_generated_load_in3_in_wire : std_logic;
  signal fu_valu_generated_data_out1_out_wire : std_logic_vector(32-1 downto 0);
  signal fu_valu_generated_data_out3_out_wire : std_logic_vector(1024-1 downto 0);
  signal ic_glock_wire : std_logic;
  signal ic_socket_ALU_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_ALU_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_ALU_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_vALU_i1_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_vALU_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_vALU_i2_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_vALU_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_vALU_i3_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_vALU_i3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_LSU1_i1_data_wire : std_logic_vector(13 downto 0);
  signal ic_socket_LSU1_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_LSU1_i2_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_LSU1_i2_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_LSU1_o1_data0_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_LSU1_o1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_vALU_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_vALU_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_vALU_o3_data0_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_vALU_o3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_IMM_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_IMM_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_RF_BOOL_o1_data0_wire : std_logic_vector(0 downto 0);
  signal ic_socket_RF_BOOL_o1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_RF_BOOL_i1_data_wire : std_logic_vector(0 downto 0);
  signal ic_socket_RF32A_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_RF32A_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_RF32A_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_RF32A_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_vRF512_o1_data0_wire : std_logic_vector(511 downto 0);
  signal ic_socket_vRF512_o1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_vRF512_i1_data_wire : std_logic_vector(511 downto 0);
  signal ic_socket_vRF1024_o1_data0_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_vRF1024_o1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_vRF1024_i1_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_gcu_i1_data_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_i2_data_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_o1_data0_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_o1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_LSU1_o2_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_LSU1_o2_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_simm_B1_wire : std_logic_vector(19 downto 0);
  signal ic_simm_cntrl_B1_wire : std_logic_vector(0 downto 0);
  signal ic_simm_B2_wire : std_logic_vector(6 downto 0);
  signal ic_simm_cntrl_B2_wire : std_logic_vector(0 downto 0);
  signal ic_simm_B3_wire : std_logic_vector(6 downto 0);
  signal ic_simm_cntrl_B3_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_instructionword_wire : std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
  signal inst_decoder_pc_load_wire : std_logic;
  signal inst_decoder_ra_load_wire : std_logic;
  signal inst_decoder_pc_opcode_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_lock_wire : std_logic;
  signal inst_decoder_lock_r_wire : std_logic;
  signal inst_decoder_simm_B1_wire : std_logic_vector(19 downto 0);
  signal inst_decoder_simm_cntrl_B1_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_simm_B2_wire : std_logic_vector(6 downto 0);
  signal inst_decoder_simm_cntrl_B2_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_simm_B3_wire : std_logic_vector(6 downto 0);
  signal inst_decoder_simm_cntrl_B3_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_ALU_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_ALU_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_vALU_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_vALU_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_vALU_i3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_LSU1_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_LSU1_i2_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_LSU1_o1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_vALU_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_vALU_o3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_IMM_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_RF_BOOL_o1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_RF32A_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_RF32A_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_vRF512_o1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_vRF1024_o1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_gcu_o1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_LSU1_o2_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_fu_ALU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_ALU_in2_load_wire : std_logic;
  signal inst_decoder_fu_ALU_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_vALU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_vALU_in2_load_wire : std_logic;
  signal inst_decoder_fu_vALU_in3_load_wire : std_logic;
  signal inst_decoder_fu_vALU_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_LSU1_in1t_load_wire : std_logic;
  signal inst_decoder_fu_LSU1_in2_load_wire : std_logic;
  signal inst_decoder_fu_LSU1_opc_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_rf_RF_BOOL_rd_load_wire : std_logic;
  signal inst_decoder_rf_RF_BOOL_rd_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_RF_BOOL_wr_load_wire : std_logic;
  signal inst_decoder_rf_RF_BOOL_wr_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_RF32A_rd_load_wire : std_logic;
  signal inst_decoder_rf_RF32A_rd_opc_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_rf_RF32A_wr_load_wire : std_logic;
  signal inst_decoder_rf_RF32A_wr_opc_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_rf_vRF512_rd_load_wire : std_logic;
  signal inst_decoder_rf_vRF512_rd_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_rf_vRF512_wr_load_wire : std_logic;
  signal inst_decoder_rf_vRF512_wr_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_rf_vRF1024_rd_load_wire : std_logic;
  signal inst_decoder_rf_vRF1024_rd_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_rf_vRF1024_wr_load_wire : std_logic;
  signal inst_decoder_rf_vRF1024_wr_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_iu_IMM_out1_read_load_wire : std_logic;
  signal inst_decoder_iu_IMM_out1_read_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_iu_IMM_write_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_iu_IMM_write_load_wire : std_logic;
  signal inst_decoder_iu_IMM_write_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_rf_guard_RF_BOOL_0_wire : std_logic;
  signal inst_decoder_rf_guard_RF_BOOL_1_wire : std_logic;
  signal inst_decoder_lock_req_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_glock_wire : std_logic_vector(8 downto 0);
  signal inst_fetch_ra_out_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal inst_fetch_ra_in_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal inst_fetch_pc_in_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal inst_fetch_pc_load_wire : std_logic;
  signal inst_fetch_ra_load_wire : std_logic;
  signal inst_fetch_pc_opcode_wire : std_logic_vector(0 downto 0);
  signal inst_fetch_fetch_en_wire : std_logic;
  signal inst_fetch_glock_wire : std_logic;
  signal inst_fetch_fetchblock_wire : std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
  signal iu_IMM_r1data_wire : std_logic_vector(31 downto 0);
  signal iu_IMM_r1load_wire : std_logic;
  signal iu_IMM_r1opcode_wire : std_logic_vector(1 downto 0);
  signal iu_IMM_t1data_wire : std_logic_vector(31 downto 0);
  signal iu_IMM_t1load_wire : std_logic;
  signal iu_IMM_t1opcode_wire : std_logic_vector(1 downto 0);
  signal iu_IMM_guard_wire : std_logic_vector(3 downto 0);
  signal iu_IMM_glock_wire : std_logic;
  signal rf_RF32A_data_rd_out_wire : std_logic_vector(31 downto 0);
  signal rf_RF32A_load_rd_in_wire : std_logic;
  signal rf_RF32A_addr_rd_in_wire : std_logic_vector(2 downto 0);
  signal rf_RF32A_data_wr_in_wire : std_logic_vector(31 downto 0);
  signal rf_RF32A_load_wr_in_wire : std_logic;
  signal rf_RF32A_addr_wr_in_wire : std_logic_vector(2 downto 0);
  signal rf_RF32A_glock_in_wire : std_logic;
  signal rf_RF_BOOL_r1data_wire : std_logic_vector(0 downto 0);
  signal rf_RF_BOOL_r1load_wire : std_logic;
  signal rf_RF_BOOL_r1opcode_wire : std_logic_vector(0 downto 0);
  signal rf_RF_BOOL_t1data_wire : std_logic_vector(0 downto 0);
  signal rf_RF_BOOL_t1load_wire : std_logic;
  signal rf_RF_BOOL_t1opcode_wire : std_logic_vector(0 downto 0);
  signal rf_RF_BOOL_guard_wire : std_logic_vector(1 downto 0);
  signal rf_RF_BOOL_glock_wire : std_logic;
  signal rf_vRF1024_data_rd_out_wire : std_logic_vector(1023 downto 0);
  signal rf_vRF1024_load_rd_in_wire : std_logic;
  signal rf_vRF1024_addr_rd_in_wire : std_logic_vector(1 downto 0);
  signal rf_vRF1024_data_wr_in_wire : std_logic_vector(1023 downto 0);
  signal rf_vRF1024_load_wr_in_wire : std_logic;
  signal rf_vRF1024_addr_wr_in_wire : std_logic_vector(1 downto 0);
  signal rf_vRF1024_glock_in_wire : std_logic;
  signal rf_vRF512_data_rd_out_wire : std_logic_vector(511 downto 0);
  signal rf_vRF512_load_rd_in_wire : std_logic;
  signal rf_vRF512_addr_rd_in_wire : std_logic_vector(1 downto 0);
  signal rf_vRF512_data_wr_in_wire : std_logic_vector(511 downto 0);
  signal rf_vRF512_load_wr_in_wire : std_logic;
  signal rf_vRF512_addr_wr_in_wire : std_logic_vector(1 downto 0);
  signal rf_vRF512_glock_in_wire : std_logic;
  signal ground_signal : std_logic_vector(3 downto 0);

  component tta_core_ifetch
    generic (
      debug_logic_g : boolean);
    port (
      clk : in std_logic;
      rstx : in std_logic;
      ra_out : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      ra_in : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      busy : in std_logic;
      imem_en_x : out std_logic;
      imem_addr : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      imem_data : in std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
      pc_in : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      pc_load : in std_logic;
      ra_load : in std_logic;
      pc_opcode : in std_logic_vector(1-1 downto 0);
      fetch_en : in std_logic;
      glock : out std_logic;
      fetchblock : out std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
      db_rstx : in std_logic;
      db_lockreq : in std_logic;
      db_cyclecnt : out std_logic_vector(64-1 downto 0);
      db_lockcnt : out std_logic_vector(64-1 downto 0);
      db_pc : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      db_pc_start : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      db_pc_next : out std_logic_vector(IMEMADDRWIDTH-1 downto 0));
  end component;

  component tta_core_decompressor
    port (
      fetch_en : out std_logic;
      lock : in std_logic;
      fetchblock : in std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      instructionword : out std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
      glock : out std_logic;
      lock_r : in std_logic);
  end component;

  component tta_core_decoder
    port (
      instructionword : in std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
      pc_load : out std_logic;
      ra_load : out std_logic;
      pc_opcode : out std_logic_vector(1-1 downto 0);
      lock : in std_logic;
      lock_r : out std_logic;
      clk : in std_logic;
      rstx : in std_logic;
      locked : out std_logic;
      simm_B1 : out std_logic_vector(20-1 downto 0);
      simm_cntrl_B1 : out std_logic_vector(1-1 downto 0);
      simm_B2 : out std_logic_vector(7-1 downto 0);
      simm_cntrl_B2 : out std_logic_vector(1-1 downto 0);
      simm_B3 : out std_logic_vector(7-1 downto 0);
      simm_cntrl_B3 : out std_logic_vector(1-1 downto 0);
      socket_ALU_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_ALU_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_ALU_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_vALU_i1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_vALU_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_vALU_i3_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_LSU1_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_LSU1_i2_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_LSU1_o1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_vALU_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_vALU_o3_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_IMM_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_RF_BOOL_o1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_RF32A_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_RF32A_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_vRF512_o1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_vRF1024_o1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_gcu_o1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_LSU1_o2_bus_cntrl : out std_logic_vector(3-1 downto 0);
      fu_ALU_in1t_load : out std_logic;
      fu_ALU_in2_load : out std_logic;
      fu_ALU_opc : out std_logic_vector(4-1 downto 0);
      fu_vALU_in1t_load : out std_logic;
      fu_vALU_in2_load : out std_logic;
      fu_vALU_in3_load : out std_logic;
      fu_vALU_opc : out std_logic_vector(4-1 downto 0);
      fu_LSU1_in1t_load : out std_logic;
      fu_LSU1_in2_load : out std_logic;
      fu_LSU1_opc : out std_logic_vector(3-1 downto 0);
      rf_RF_BOOL_rd_load : out std_logic;
      rf_RF_BOOL_rd_opc : out std_logic_vector(1-1 downto 0);
      rf_RF_BOOL_wr_load : out std_logic;
      rf_RF_BOOL_wr_opc : out std_logic_vector(1-1 downto 0);
      rf_RF32A_rd_load : out std_logic;
      rf_RF32A_rd_opc : out std_logic_vector(3-1 downto 0);
      rf_RF32A_wr_load : out std_logic;
      rf_RF32A_wr_opc : out std_logic_vector(3-1 downto 0);
      rf_vRF512_rd_load : out std_logic;
      rf_vRF512_rd_opc : out std_logic_vector(2-1 downto 0);
      rf_vRF512_wr_load : out std_logic;
      rf_vRF512_wr_opc : out std_logic_vector(2-1 downto 0);
      rf_vRF1024_rd_load : out std_logic;
      rf_vRF1024_rd_opc : out std_logic_vector(2-1 downto 0);
      rf_vRF1024_wr_load : out std_logic;
      rf_vRF1024_wr_opc : out std_logic_vector(2-1 downto 0);
      iu_IMM_out1_read_load : out std_logic;
      iu_IMM_out1_read_opc : out std_logic_vector(2-1 downto 0);
      iu_IMM_write : out std_logic_vector(32-1 downto 0);
      iu_IMM_write_load : out std_logic;
      iu_IMM_write_opc : out std_logic_vector(2-1 downto 0);
      rf_guard_RF_BOOL_0 : in std_logic;
      rf_guard_RF_BOOL_1 : in std_logic;
      lock_req : in std_logic_vector(3-1 downto 0);
      glock : out std_logic_vector(9-1 downto 0);
      db_tta_nreset : in std_logic);
  end component;

  component fu_valu
    port (
      clk : in std_logic;
      rstx : in std_logic;
      glock_in : in std_logic;
      operation_in : in std_logic_vector(4-1 downto 0);
      glockreq_out : out std_logic;
      data_in1t_in : in std_logic_vector(1024-1 downto 0);
      load_in1t_in : in std_logic;
      data_in2_in : in std_logic_vector(1024-1 downto 0);
      load_in2_in : in std_logic;
      data_in3_in : in std_logic_vector(1024-1 downto 0);
      load_in3_in : in std_logic;
      data_out1_out : out std_logic_vector(32-1 downto 0);
      data_out3_out : out std_logic_vector(1024-1 downto 0));
  end component;

  component fu_add_and_eq_gt_gtu_ior_shl_shr_shru_sub_sxhw_sxqw_xor_always_1
    generic (
      dataw : integer;
      shiftw : integer);
    port (
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      r1data : out std_logic_vector(dataw-1 downto 0);
      o1data : in std_logic_vector(dataw-1 downto 0);
      o1load : in std_logic;
      t1opcode : in std_logic_vector(4-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component fu_lsu_simd_32
    generic (
      addrw_g : integer);
    port (
      t1_address_in : in std_logic_vector(addrw_g-1 downto 0);
      t1_load_in : in std_logic;
      r1_data_out : out std_logic_vector(1024-1 downto 0);
      r2_data_out : out std_logic_vector(32-1 downto 0);
      o1_data_in : in std_logic_vector(1024-1 downto 0);
      o1_load_in : in std_logic;
      t1_opcode_in : in std_logic_vector(3-1 downto 0);
      avalid_out : out std_logic_vector(1-1 downto 0);
      aready_in : in std_logic_vector(1-1 downto 0);
      aaddr_out : out std_logic_vector(addrw_g-7-1 downto 0);
      awren_out : out std_logic_vector(1-1 downto 0);
      astrb_out : out std_logic_vector(128-1 downto 0);
      adata_out : out std_logic_vector(1024-1 downto 0);
      rvalid_in : in std_logic_vector(1-1 downto 0);
      rready_out : out std_logic_vector(1-1 downto 0);
      rdata_in : in std_logic_vector(1024-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock_in : in std_logic;
      glockreq_out : out std_logic);
  end component;

  component s7_rf_1wr_1rd
    generic (
      width_g : integer;
      depth_g : integer);
    port (
      data_rd_out : out std_logic_vector(width_g-1 downto 0);
      load_rd_in : in std_logic;
      addr_rd_in : in std_logic_vector(bit_width(depth_g)-1 downto 0);
      data_wr_in : in std_logic_vector(width_g-1 downto 0);
      load_wr_in : in std_logic;
      addr_wr_in : in std_logic_vector(bit_width(depth_g)-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock_in : in std_logic);
  end component;

  component rf_1wr_1rd_always_1_guarded_0
    generic (
      dataw : integer;
      rf_size : integer);
    port (
      r1data : out std_logic_vector(dataw-1 downto 0);
      r1load : in std_logic;
      r1opcode : in std_logic_vector(bit_width(rf_size)-1 downto 0);
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      t1opcode : in std_logic_vector(bit_width(rf_size)-1 downto 0);
      guard : out std_logic_vector(rf_size-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component tta_core_interconn
    port (
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic;
      socket_ALU_i1_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_ALU_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_ALU_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_ALU_i2_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_vALU_i1_data : out std_logic_vector(1024-1 downto 0);
      socket_vALU_i1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_vALU_i2_data : out std_logic_vector(1024-1 downto 0);
      socket_vALU_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_vALU_i3_data : out std_logic_vector(1024-1 downto 0);
      socket_vALU_i3_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_LSU1_i1_data : out std_logic_vector(14-1 downto 0);
      socket_LSU1_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_LSU1_i2_data : out std_logic_vector(1024-1 downto 0);
      socket_LSU1_i2_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_LSU1_o1_data0 : in std_logic_vector(1024-1 downto 0);
      socket_LSU1_o1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_vALU_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_vALU_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_vALU_o3_data0 : in std_logic_vector(1024-1 downto 0);
      socket_vALU_o3_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_IMM_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_IMM_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_RF_BOOL_o1_data0 : in std_logic_vector(1-1 downto 0);
      socket_RF_BOOL_o1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_RF_BOOL_i1_data : out std_logic_vector(1-1 downto 0);
      socket_RF32A_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_RF32A_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_RF32A_i1_data : out std_logic_vector(32-1 downto 0);
      socket_RF32A_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_vRF512_o1_data0 : in std_logic_vector(512-1 downto 0);
      socket_vRF512_o1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_vRF512_i1_data : out std_logic_vector(512-1 downto 0);
      socket_vRF1024_o1_data0 : in std_logic_vector(1024-1 downto 0);
      socket_vRF1024_o1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_vRF1024_i1_data : out std_logic_vector(1024-1 downto 0);
      socket_gcu_i1_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_i2_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_o1_data0 : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_o1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_LSU1_o2_data0 : in std_logic_vector(32-1 downto 0);
      socket_LSU1_o2_bus_cntrl : in std_logic_vector(3-1 downto 0);
      simm_B1 : in std_logic_vector(20-1 downto 0);
      simm_cntrl_B1 : in std_logic_vector(1-1 downto 0);
      simm_B2 : in std_logic_vector(7-1 downto 0);
      simm_cntrl_B2 : in std_logic_vector(1-1 downto 0);
      simm_B3 : in std_logic_vector(7-1 downto 0);
      simm_cntrl_B3 : in std_logic_vector(1-1 downto 0);
      db_bustraces : out std_logic_vector(BUSTRACE_WIDTH-1 downto 0));
  end component;


begin

  ic_socket_gcu_o1_data0_wire <= inst_fetch_ra_out_wire;
  inst_fetch_ra_in_wire <= ic_socket_gcu_i2_data_wire;
  inst_fetch_pc_in_wire <= ic_socket_gcu_i1_data_wire;
  inst_fetch_pc_load_wire <= inst_decoder_pc_load_wire;
  inst_fetch_ra_load_wire <= inst_decoder_ra_load_wire;
  inst_fetch_pc_opcode_wire <= inst_decoder_pc_opcode_wire;
  inst_fetch_fetch_en_wire <= decomp_fetch_en_wire;
  decomp_lock_wire <= inst_fetch_glock_wire;
  decomp_fetchblock_wire <= inst_fetch_fetchblock_wire;
  inst_decoder_instructionword_wire <= decomp_instructionword_wire;
  inst_decoder_lock_wire <= decomp_glock_wire;
  decomp_lock_r_wire <= inst_decoder_lock_r_wire;
  ic_simm_B1_wire <= inst_decoder_simm_B1_wire;
  ic_simm_cntrl_B1_wire <= inst_decoder_simm_cntrl_B1_wire;
  ic_simm_B2_wire <= inst_decoder_simm_B2_wire;
  ic_simm_cntrl_B2_wire <= inst_decoder_simm_cntrl_B2_wire;
  ic_simm_B3_wire <= inst_decoder_simm_B3_wire;
  ic_simm_cntrl_B3_wire <= inst_decoder_simm_cntrl_B3_wire;
  ic_socket_ALU_i1_bus_cntrl_wire <= inst_decoder_socket_ALU_i1_bus_cntrl_wire;
  ic_socket_ALU_o1_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_bus_cntrl_wire;
  ic_socket_ALU_i2_bus_cntrl_wire <= inst_decoder_socket_ALU_i2_bus_cntrl_wire;
  ic_socket_vALU_i1_bus_cntrl_wire <= inst_decoder_socket_vALU_i1_bus_cntrl_wire;
  ic_socket_vALU_i2_bus_cntrl_wire <= inst_decoder_socket_vALU_i2_bus_cntrl_wire;
  ic_socket_vALU_i3_bus_cntrl_wire <= inst_decoder_socket_vALU_i3_bus_cntrl_wire;
  ic_socket_LSU1_i1_bus_cntrl_wire <= inst_decoder_socket_LSU1_i1_bus_cntrl_wire;
  ic_socket_LSU1_i2_bus_cntrl_wire <= inst_decoder_socket_LSU1_i2_bus_cntrl_wire;
  ic_socket_LSU1_o1_bus_cntrl_wire <= inst_decoder_socket_LSU1_o1_bus_cntrl_wire;
  ic_socket_vALU_o1_bus_cntrl_wire <= inst_decoder_socket_vALU_o1_bus_cntrl_wire;
  ic_socket_vALU_o3_bus_cntrl_wire <= inst_decoder_socket_vALU_o3_bus_cntrl_wire;
  ic_socket_IMM_o1_bus_cntrl_wire <= inst_decoder_socket_IMM_o1_bus_cntrl_wire;
  ic_socket_RF_BOOL_o1_bus_cntrl_wire <= inst_decoder_socket_RF_BOOL_o1_bus_cntrl_wire;
  ic_socket_RF32A_o1_bus_cntrl_wire <= inst_decoder_socket_RF32A_o1_bus_cntrl_wire;
  ic_socket_RF32A_i1_bus_cntrl_wire <= inst_decoder_socket_RF32A_i1_bus_cntrl_wire;
  ic_socket_vRF512_o1_bus_cntrl_wire <= inst_decoder_socket_vRF512_o1_bus_cntrl_wire;
  ic_socket_vRF1024_o1_bus_cntrl_wire <= inst_decoder_socket_vRF1024_o1_bus_cntrl_wire;
  ic_socket_gcu_o1_bus_cntrl_wire <= inst_decoder_socket_gcu_o1_bus_cntrl_wire;
  ic_socket_LSU1_o2_bus_cntrl_wire <= inst_decoder_socket_LSU1_o2_bus_cntrl_wire;
  fu_ALU_t1load_wire <= inst_decoder_fu_ALU_in1t_load_wire;
  fu_ALU_o1load_wire <= inst_decoder_fu_ALU_in2_load_wire;
  fu_ALU_t1opcode_wire <= inst_decoder_fu_ALU_opc_wire;
  fu_valu_generated_load_in1t_in_wire <= inst_decoder_fu_vALU_in1t_load_wire;
  fu_valu_generated_load_in2_in_wire <= inst_decoder_fu_vALU_in2_load_wire;
  fu_valu_generated_load_in3_in_wire <= inst_decoder_fu_vALU_in3_load_wire;
  fu_valu_generated_operation_in_wire <= inst_decoder_fu_vALU_opc_wire;
  fu_LSU1_t1_load_in_wire <= inst_decoder_fu_LSU1_in1t_load_wire;
  fu_LSU1_o1_load_in_wire <= inst_decoder_fu_LSU1_in2_load_wire;
  fu_LSU1_t1_opcode_in_wire <= inst_decoder_fu_LSU1_opc_wire;
  rf_RF_BOOL_r1load_wire <= inst_decoder_rf_RF_BOOL_rd_load_wire;
  rf_RF_BOOL_r1opcode_wire <= inst_decoder_rf_RF_BOOL_rd_opc_wire;
  rf_RF_BOOL_t1load_wire <= inst_decoder_rf_RF_BOOL_wr_load_wire;
  rf_RF_BOOL_t1opcode_wire <= inst_decoder_rf_RF_BOOL_wr_opc_wire;
  rf_RF32A_load_rd_in_wire <= inst_decoder_rf_RF32A_rd_load_wire;
  rf_RF32A_addr_rd_in_wire <= inst_decoder_rf_RF32A_rd_opc_wire;
  rf_RF32A_load_wr_in_wire <= inst_decoder_rf_RF32A_wr_load_wire;
  rf_RF32A_addr_wr_in_wire <= inst_decoder_rf_RF32A_wr_opc_wire;
  rf_vRF512_load_rd_in_wire <= inst_decoder_rf_vRF512_rd_load_wire;
  rf_vRF512_addr_rd_in_wire <= inst_decoder_rf_vRF512_rd_opc_wire;
  rf_vRF512_load_wr_in_wire <= inst_decoder_rf_vRF512_wr_load_wire;
  rf_vRF512_addr_wr_in_wire <= inst_decoder_rf_vRF512_wr_opc_wire;
  rf_vRF1024_load_rd_in_wire <= inst_decoder_rf_vRF1024_rd_load_wire;
  rf_vRF1024_addr_rd_in_wire <= inst_decoder_rf_vRF1024_rd_opc_wire;
  rf_vRF1024_load_wr_in_wire <= inst_decoder_rf_vRF1024_wr_load_wire;
  rf_vRF1024_addr_wr_in_wire <= inst_decoder_rf_vRF1024_wr_opc_wire;
  iu_IMM_r1load_wire <= inst_decoder_iu_IMM_out1_read_load_wire;
  iu_IMM_r1opcode_wire <= inst_decoder_iu_IMM_out1_read_opc_wire;
  iu_IMM_t1data_wire <= inst_decoder_iu_IMM_write_wire;
  iu_IMM_t1load_wire <= inst_decoder_iu_IMM_write_load_wire;
  iu_IMM_t1opcode_wire <= inst_decoder_iu_IMM_write_opc_wire;
  inst_decoder_rf_guard_RF_BOOL_0_wire <= rf_RF_BOOL_guard_wire(0);
  inst_decoder_rf_guard_RF_BOOL_1_wire <= rf_RF_BOOL_guard_wire(1);
  inst_decoder_lock_req_wire(0) <= fu_valu_generated_glockreq_out_wire;
  inst_decoder_lock_req_wire(1) <= fu_LSU1_glockreq_out_wire;
  inst_decoder_lock_req_wire(2) <= db_lockrq;
  fu_ALU_glock_wire <= inst_decoder_glock_wire(0);
  fu_valu_generated_glock_in_wire <= inst_decoder_glock_wire(1);
  fu_LSU1_glock_in_wire <= inst_decoder_glock_wire(2);
  rf_RF_BOOL_glock_wire <= inst_decoder_glock_wire(3);
  rf_RF32A_glock_in_wire <= inst_decoder_glock_wire(4);
  rf_vRF512_glock_in_wire <= inst_decoder_glock_wire(5);
  rf_vRF1024_glock_in_wire <= inst_decoder_glock_wire(6);
  iu_IMM_glock_wire <= inst_decoder_glock_wire(7);
  ic_glock_wire <= inst_decoder_glock_wire(8);
  fu_valu_generated_data_in1t_in_wire <= ic_socket_vALU_i1_data_wire;
  fu_valu_generated_data_in2_in_wire <= ic_socket_vALU_i2_data_wire;
  fu_valu_generated_data_in3_in_wire <= ic_socket_vALU_i3_data_wire;
  ic_socket_vALU_o1_data0_wire <= fu_valu_generated_data_out1_out_wire;
  ic_socket_vALU_o3_data0_wire <= fu_valu_generated_data_out3_out_wire;
  fu_ALU_t1data_wire <= ic_socket_ALU_i1_data_wire;
  ic_socket_ALU_o1_data0_wire <= fu_ALU_r1data_wire;
  fu_ALU_o1data_wire <= ic_socket_ALU_i2_data_wire;
  fu_LSU1_t1_address_in_wire <= ic_socket_LSU1_i1_data_wire;
  ic_socket_LSU1_o1_data0_wire <= fu_LSU1_r1_data_out_wire;
  ic_socket_LSU1_o2_data0_wire <= fu_LSU1_r2_data_out_wire;
  fu_LSU1_o1_data_in_wire <= ic_socket_LSU1_i2_data_wire;
  ic_socket_vRF1024_o1_data0_wire <= rf_vRF1024_data_rd_out_wire;
  rf_vRF1024_data_wr_in_wire <= ic_socket_vRF1024_i1_data_wire;
  ic_socket_vRF512_o1_data0_wire <= rf_vRF512_data_rd_out_wire;
  rf_vRF512_data_wr_in_wire <= ic_socket_vRF512_i1_data_wire;
  ic_socket_RF32A_o1_data0_wire <= rf_RF32A_data_rd_out_wire;
  rf_RF32A_data_wr_in_wire <= ic_socket_RF32A_i1_data_wire;
  ic_socket_RF_BOOL_o1_data0_wire <= rf_RF_BOOL_r1data_wire;
  rf_RF_BOOL_t1data_wire <= ic_socket_RF_BOOL_i1_data_wire;
  ic_socket_IMM_o1_data0_wire <= iu_IMM_r1data_wire;
  ground_signal <= (others => '0');

  inst_fetch : tta_core_ifetch
    generic map (
      debug_logic_g => true)
    port map (
      clk => clk,
      rstx => rstx,
      ra_out => inst_fetch_ra_out_wire,
      ra_in => inst_fetch_ra_in_wire,
      busy => busy,
      imem_en_x => imem_en_x,
      imem_addr => imem_addr,
      imem_data => imem_data,
      pc_in => inst_fetch_pc_in_wire,
      pc_load => inst_fetch_pc_load_wire,
      ra_load => inst_fetch_ra_load_wire,
      pc_opcode => inst_fetch_pc_opcode_wire,
      fetch_en => inst_fetch_fetch_en_wire,
      glock => inst_fetch_glock_wire,
      fetchblock => inst_fetch_fetchblock_wire,
      db_rstx => db_tta_nreset,
      db_lockreq => db_lockrq,
      db_cyclecnt => db_cyclecnt,
      db_lockcnt => db_lockcnt,
      db_pc => db_pc,
      db_pc_start => db_pc_start,
      db_pc_next => db_pc_next);

  decomp : tta_core_decompressor
    port map (
      fetch_en => decomp_fetch_en_wire,
      lock => decomp_lock_wire,
      fetchblock => decomp_fetchblock_wire,
      clk => clk,
      rstx => rstx,
      instructionword => decomp_instructionword_wire,
      glock => decomp_glock_wire,
      lock_r => decomp_lock_r_wire);

  inst_decoder : tta_core_decoder
    port map (
      instructionword => inst_decoder_instructionword_wire,
      pc_load => inst_decoder_pc_load_wire,
      ra_load => inst_decoder_ra_load_wire,
      pc_opcode => inst_decoder_pc_opcode_wire,
      lock => inst_decoder_lock_wire,
      lock_r => inst_decoder_lock_r_wire,
      clk => clk,
      rstx => rstx,
      locked => locked,
      simm_B1 => inst_decoder_simm_B1_wire,
      simm_cntrl_B1 => inst_decoder_simm_cntrl_B1_wire,
      simm_B2 => inst_decoder_simm_B2_wire,
      simm_cntrl_B2 => inst_decoder_simm_cntrl_B2_wire,
      simm_B3 => inst_decoder_simm_B3_wire,
      simm_cntrl_B3 => inst_decoder_simm_cntrl_B3_wire,
      socket_ALU_i1_bus_cntrl => inst_decoder_socket_ALU_i1_bus_cntrl_wire,
      socket_ALU_o1_bus_cntrl => inst_decoder_socket_ALU_o1_bus_cntrl_wire,
      socket_ALU_i2_bus_cntrl => inst_decoder_socket_ALU_i2_bus_cntrl_wire,
      socket_vALU_i1_bus_cntrl => inst_decoder_socket_vALU_i1_bus_cntrl_wire,
      socket_vALU_i2_bus_cntrl => inst_decoder_socket_vALU_i2_bus_cntrl_wire,
      socket_vALU_i3_bus_cntrl => inst_decoder_socket_vALU_i3_bus_cntrl_wire,
      socket_LSU1_i1_bus_cntrl => inst_decoder_socket_LSU1_i1_bus_cntrl_wire,
      socket_LSU1_i2_bus_cntrl => inst_decoder_socket_LSU1_i2_bus_cntrl_wire,
      socket_LSU1_o1_bus_cntrl => inst_decoder_socket_LSU1_o1_bus_cntrl_wire,
      socket_vALU_o1_bus_cntrl => inst_decoder_socket_vALU_o1_bus_cntrl_wire,
      socket_vALU_o3_bus_cntrl => inst_decoder_socket_vALU_o3_bus_cntrl_wire,
      socket_IMM_o1_bus_cntrl => inst_decoder_socket_IMM_o1_bus_cntrl_wire,
      socket_RF_BOOL_o1_bus_cntrl => inst_decoder_socket_RF_BOOL_o1_bus_cntrl_wire,
      socket_RF32A_o1_bus_cntrl => inst_decoder_socket_RF32A_o1_bus_cntrl_wire,
      socket_RF32A_i1_bus_cntrl => inst_decoder_socket_RF32A_i1_bus_cntrl_wire,
      socket_vRF512_o1_bus_cntrl => inst_decoder_socket_vRF512_o1_bus_cntrl_wire,
      socket_vRF1024_o1_bus_cntrl => inst_decoder_socket_vRF1024_o1_bus_cntrl_wire,
      socket_gcu_o1_bus_cntrl => inst_decoder_socket_gcu_o1_bus_cntrl_wire,
      socket_LSU1_o2_bus_cntrl => inst_decoder_socket_LSU1_o2_bus_cntrl_wire,
      fu_ALU_in1t_load => inst_decoder_fu_ALU_in1t_load_wire,
      fu_ALU_in2_load => inst_decoder_fu_ALU_in2_load_wire,
      fu_ALU_opc => inst_decoder_fu_ALU_opc_wire,
      fu_vALU_in1t_load => inst_decoder_fu_vALU_in1t_load_wire,
      fu_vALU_in2_load => inst_decoder_fu_vALU_in2_load_wire,
      fu_vALU_in3_load => inst_decoder_fu_vALU_in3_load_wire,
      fu_vALU_opc => inst_decoder_fu_vALU_opc_wire,
      fu_LSU1_in1t_load => inst_decoder_fu_LSU1_in1t_load_wire,
      fu_LSU1_in2_load => inst_decoder_fu_LSU1_in2_load_wire,
      fu_LSU1_opc => inst_decoder_fu_LSU1_opc_wire,
      rf_RF_BOOL_rd_load => inst_decoder_rf_RF_BOOL_rd_load_wire,
      rf_RF_BOOL_rd_opc => inst_decoder_rf_RF_BOOL_rd_opc_wire,
      rf_RF_BOOL_wr_load => inst_decoder_rf_RF_BOOL_wr_load_wire,
      rf_RF_BOOL_wr_opc => inst_decoder_rf_RF_BOOL_wr_opc_wire,
      rf_RF32A_rd_load => inst_decoder_rf_RF32A_rd_load_wire,
      rf_RF32A_rd_opc => inst_decoder_rf_RF32A_rd_opc_wire,
      rf_RF32A_wr_load => inst_decoder_rf_RF32A_wr_load_wire,
      rf_RF32A_wr_opc => inst_decoder_rf_RF32A_wr_opc_wire,
      rf_vRF512_rd_load => inst_decoder_rf_vRF512_rd_load_wire,
      rf_vRF512_rd_opc => inst_decoder_rf_vRF512_rd_opc_wire,
      rf_vRF512_wr_load => inst_decoder_rf_vRF512_wr_load_wire,
      rf_vRF512_wr_opc => inst_decoder_rf_vRF512_wr_opc_wire,
      rf_vRF1024_rd_load => inst_decoder_rf_vRF1024_rd_load_wire,
      rf_vRF1024_rd_opc => inst_decoder_rf_vRF1024_rd_opc_wire,
      rf_vRF1024_wr_load => inst_decoder_rf_vRF1024_wr_load_wire,
      rf_vRF1024_wr_opc => inst_decoder_rf_vRF1024_wr_opc_wire,
      iu_IMM_out1_read_load => inst_decoder_iu_IMM_out1_read_load_wire,
      iu_IMM_out1_read_opc => inst_decoder_iu_IMM_out1_read_opc_wire,
      iu_IMM_write => inst_decoder_iu_IMM_write_wire,
      iu_IMM_write_load => inst_decoder_iu_IMM_write_load_wire,
      iu_IMM_write_opc => inst_decoder_iu_IMM_write_opc_wire,
      rf_guard_RF_BOOL_0 => inst_decoder_rf_guard_RF_BOOL_0_wire,
      rf_guard_RF_BOOL_1 => inst_decoder_rf_guard_RF_BOOL_1_wire,
      lock_req => inst_decoder_lock_req_wire,
      glock => inst_decoder_glock_wire,
      db_tta_nreset => db_tta_nreset);

  fu_valu_generated : fu_valu
    port map (
      clk => clk,
      rstx => rstx,
      glock_in => fu_valu_generated_glock_in_wire,
      operation_in => fu_valu_generated_operation_in_wire,
      glockreq_out => fu_valu_generated_glockreq_out_wire,
      data_in1t_in => fu_valu_generated_data_in1t_in_wire,
      load_in1t_in => fu_valu_generated_load_in1t_in_wire,
      data_in2_in => fu_valu_generated_data_in2_in_wire,
      load_in2_in => fu_valu_generated_load_in2_in_wire,
      data_in3_in => fu_valu_generated_data_in3_in_wire,
      load_in3_in => fu_valu_generated_load_in3_in_wire,
      data_out1_out => fu_valu_generated_data_out1_out_wire,
      data_out3_out => fu_valu_generated_data_out3_out_wire);

  fu_ALU : fu_add_and_eq_gt_gtu_ior_shl_shr_shru_sub_sxhw_sxqw_xor_always_1
    generic map (
      dataw => 32,
      shiftw => 5)
    port map (
      t1data => fu_ALU_t1data_wire,
      t1load => fu_ALU_t1load_wire,
      r1data => fu_ALU_r1data_wire,
      o1data => fu_ALU_o1data_wire,
      o1load => fu_ALU_o1load_wire,
      t1opcode => fu_ALU_t1opcode_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_ALU_glock_wire);

  fu_LSU1 : fu_lsu_simd_32
    generic map (
      addrw_g => fu_LSU1_addrw_g)
    port map (
      t1_address_in => fu_LSU1_t1_address_in_wire,
      t1_load_in => fu_LSU1_t1_load_in_wire,
      r1_data_out => fu_LSU1_r1_data_out_wire,
      r2_data_out => fu_LSU1_r2_data_out_wire,
      o1_data_in => fu_LSU1_o1_data_in_wire,
      o1_load_in => fu_LSU1_o1_load_in_wire,
      t1_opcode_in => fu_LSU1_t1_opcode_in_wire,
      avalid_out => fu_LSU1_avalid_out,
      aready_in => fu_LSU1_aready_in,
      aaddr_out => fu_LSU1_aaddr_out,
      awren_out => fu_LSU1_awren_out,
      astrb_out => fu_LSU1_astrb_out,
      adata_out => fu_LSU1_adata_out,
      rvalid_in => fu_LSU1_rvalid_in,
      rready_out => fu_LSU1_rready_out,
      rdata_in => fu_LSU1_rdata_in,
      clk => clk,
      rstx => rstx,
      glock_in => fu_LSU1_glock_in_wire,
      glockreq_out => fu_LSU1_glockreq_out_wire);

  rf_vRF1024 : s7_rf_1wr_1rd
    generic map (
      width_g => 1024,
      depth_g => 4)
    port map (
      data_rd_out => rf_vRF1024_data_rd_out_wire,
      load_rd_in => rf_vRF1024_load_rd_in_wire,
      addr_rd_in => rf_vRF1024_addr_rd_in_wire,
      data_wr_in => rf_vRF1024_data_wr_in_wire,
      load_wr_in => rf_vRF1024_load_wr_in_wire,
      addr_wr_in => rf_vRF1024_addr_wr_in_wire,
      clk => clk,
      rstx => rstx,
      glock_in => rf_vRF1024_glock_in_wire);

  rf_vRF512 : s7_rf_1wr_1rd
    generic map (
      width_g => 512,
      depth_g => 4)
    port map (
      data_rd_out => rf_vRF512_data_rd_out_wire,
      load_rd_in => rf_vRF512_load_rd_in_wire,
      addr_rd_in => rf_vRF512_addr_rd_in_wire,
      data_wr_in => rf_vRF512_data_wr_in_wire,
      load_wr_in => rf_vRF512_load_wr_in_wire,
      addr_wr_in => rf_vRF512_addr_wr_in_wire,
      clk => clk,
      rstx => rstx,
      glock_in => rf_vRF512_glock_in_wire);

  rf_RF32A : s7_rf_1wr_1rd
    generic map (
      width_g => 32,
      depth_g => 8)
    port map (
      data_rd_out => rf_RF32A_data_rd_out_wire,
      load_rd_in => rf_RF32A_load_rd_in_wire,
      addr_rd_in => rf_RF32A_addr_rd_in_wire,
      data_wr_in => rf_RF32A_data_wr_in_wire,
      load_wr_in => rf_RF32A_load_wr_in_wire,
      addr_wr_in => rf_RF32A_addr_wr_in_wire,
      clk => clk,
      rstx => rstx,
      glock_in => rf_RF32A_glock_in_wire);

  rf_RF_BOOL : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 1,
      rf_size => 2)
    port map (
      r1data => rf_RF_BOOL_r1data_wire,
      r1load => rf_RF_BOOL_r1load_wire,
      r1opcode => rf_RF_BOOL_r1opcode_wire,
      t1data => rf_RF_BOOL_t1data_wire,
      t1load => rf_RF_BOOL_t1load_wire,
      t1opcode => rf_RF_BOOL_t1opcode_wire,
      guard => rf_RF_BOOL_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => rf_RF_BOOL_glock_wire);

  iu_IMM : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 32,
      rf_size => 4)
    port map (
      r1data => iu_IMM_r1data_wire,
      r1load => iu_IMM_r1load_wire,
      r1opcode => iu_IMM_r1opcode_wire,
      t1data => iu_IMM_t1data_wire,
      t1load => iu_IMM_t1load_wire,
      t1opcode => iu_IMM_t1opcode_wire,
      guard => iu_IMM_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => iu_IMM_glock_wire);

  ic : tta_core_interconn
    port map (
      clk => clk,
      rstx => rstx,
      glock => ic_glock_wire,
      socket_ALU_i1_data => ic_socket_ALU_i1_data_wire,
      socket_ALU_i1_bus_cntrl => ic_socket_ALU_i1_bus_cntrl_wire,
      socket_ALU_o1_data0 => ic_socket_ALU_o1_data0_wire,
      socket_ALU_o1_bus_cntrl => ic_socket_ALU_o1_bus_cntrl_wire,
      socket_ALU_i2_data => ic_socket_ALU_i2_data_wire,
      socket_ALU_i2_bus_cntrl => ic_socket_ALU_i2_bus_cntrl_wire,
      socket_vALU_i1_data => ic_socket_vALU_i1_data_wire,
      socket_vALU_i1_bus_cntrl => ic_socket_vALU_i1_bus_cntrl_wire,
      socket_vALU_i2_data => ic_socket_vALU_i2_data_wire,
      socket_vALU_i2_bus_cntrl => ic_socket_vALU_i2_bus_cntrl_wire,
      socket_vALU_i3_data => ic_socket_vALU_i3_data_wire,
      socket_vALU_i3_bus_cntrl => ic_socket_vALU_i3_bus_cntrl_wire,
      socket_LSU1_i1_data => ic_socket_LSU1_i1_data_wire,
      socket_LSU1_i1_bus_cntrl => ic_socket_LSU1_i1_bus_cntrl_wire,
      socket_LSU1_i2_data => ic_socket_LSU1_i2_data_wire,
      socket_LSU1_i2_bus_cntrl => ic_socket_LSU1_i2_bus_cntrl_wire,
      socket_LSU1_o1_data0 => ic_socket_LSU1_o1_data0_wire,
      socket_LSU1_o1_bus_cntrl => ic_socket_LSU1_o1_bus_cntrl_wire,
      socket_vALU_o1_data0 => ic_socket_vALU_o1_data0_wire,
      socket_vALU_o1_bus_cntrl => ic_socket_vALU_o1_bus_cntrl_wire,
      socket_vALU_o3_data0 => ic_socket_vALU_o3_data0_wire,
      socket_vALU_o3_bus_cntrl => ic_socket_vALU_o3_bus_cntrl_wire,
      socket_IMM_o1_data0 => ic_socket_IMM_o1_data0_wire,
      socket_IMM_o1_bus_cntrl => ic_socket_IMM_o1_bus_cntrl_wire,
      socket_RF_BOOL_o1_data0 => ic_socket_RF_BOOL_o1_data0_wire,
      socket_RF_BOOL_o1_bus_cntrl => ic_socket_RF_BOOL_o1_bus_cntrl_wire,
      socket_RF_BOOL_i1_data => ic_socket_RF_BOOL_i1_data_wire,
      socket_RF32A_o1_data0 => ic_socket_RF32A_o1_data0_wire,
      socket_RF32A_o1_bus_cntrl => ic_socket_RF32A_o1_bus_cntrl_wire,
      socket_RF32A_i1_data => ic_socket_RF32A_i1_data_wire,
      socket_RF32A_i1_bus_cntrl => ic_socket_RF32A_i1_bus_cntrl_wire,
      socket_vRF512_o1_data0 => ic_socket_vRF512_o1_data0_wire,
      socket_vRF512_o1_bus_cntrl => ic_socket_vRF512_o1_bus_cntrl_wire,
      socket_vRF512_i1_data => ic_socket_vRF512_i1_data_wire,
      socket_vRF1024_o1_data0 => ic_socket_vRF1024_o1_data0_wire,
      socket_vRF1024_o1_bus_cntrl => ic_socket_vRF1024_o1_bus_cntrl_wire,
      socket_vRF1024_i1_data => ic_socket_vRF1024_i1_data_wire,
      socket_gcu_i1_data => ic_socket_gcu_i1_data_wire,
      socket_gcu_i2_data => ic_socket_gcu_i2_data_wire,
      socket_gcu_o1_data0 => ic_socket_gcu_o1_data0_wire,
      socket_gcu_o1_bus_cntrl => ic_socket_gcu_o1_bus_cntrl_wire,
      socket_LSU1_o2_data0 => ic_socket_LSU1_o2_data0_wire,
      socket_LSU1_o2_bus_cntrl => ic_socket_LSU1_o2_bus_cntrl_wire,
      simm_B1 => ic_simm_B1_wire,
      simm_cntrl_B1 => ic_simm_cntrl_B1_wire,
      simm_B2 => ic_simm_B2_wire,
      simm_cntrl_B2 => ic_simm_cntrl_B2_wire,
      simm_B3 => ic_simm_B3_wire,
      simm_cntrl_B3 => ic_simm_cntrl_B3_wire,
      db_bustraces => db_bustraces);

end structural;
