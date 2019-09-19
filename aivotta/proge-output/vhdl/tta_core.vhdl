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
    fu_DMA_m_axi_awaddr : out std_logic_vector(fu_DMA_addr_width_g-1 downto 0);
    fu_DMA_m_axi_awcache : out std_logic_vector(3 downto 0);
    fu_DMA_m_axi_awlen : out std_logic_vector(7 downto 0);
    fu_DMA_m_axi_awsize : out std_logic_vector(2 downto 0);
    fu_DMA_m_axi_awburst : out std_logic_vector(1 downto 0);
    fu_DMA_m_axi_awprot : out std_logic_vector(2 downto 0);
    fu_DMA_m_axi_awvalid : out std_logic_vector(0 downto 0);
    fu_DMA_m_axi_awready : in std_logic_vector(0 downto 0);
    fu_DMA_m_axi_wdata : out std_logic_vector(fu_DMA_data_width_g-1 downto 0);
    fu_DMA_m_axi_wstrb : out std_logic_vector(fu_DMA_data_width_g/8-1 downto 0);
    fu_DMA_m_axi_wlast : out std_logic_vector(0 downto 0);
    fu_DMA_m_axi_wvalid : out std_logic_vector(0 downto 0);
    fu_DMA_m_axi_wready : in std_logic_vector(0 downto 0);
    fu_DMA_m_axi_araddr : out std_logic_vector(fu_DMA_addr_width_g-1 downto 0);
    fu_DMA_m_axi_arcache : out std_logic_vector(3 downto 0);
    fu_DMA_m_axi_arlen : out std_logic_vector(7 downto 0);
    fu_DMA_m_axi_arsize : out std_logic_vector(2 downto 0);
    fu_DMA_m_axi_arburst : out std_logic_vector(1 downto 0);
    fu_DMA_m_axi_arprot : out std_logic_vector(2 downto 0);
    fu_DMA_m_axi_arvalid : out std_logic_vector(0 downto 0);
    fu_DMA_m_axi_arready : in std_logic_vector(0 downto 0);
    fu_DMA_m_axi_rdata : in std_logic_vector(fu_DMA_data_width_g-1 downto 0);
    fu_DMA_m_axi_rvalid : in std_logic_vector(0 downto 0);
    fu_DMA_m_axi_rready : out std_logic_vector(0 downto 0);
    fu_DMA_m_axi_bvalid : in std_logic_vector(0 downto 0);
    fu_DMA_m_axi_bready : out std_logic_vector(0 downto 0);
    fu_DMA_m_axi_rlast : in std_logic_vector(0 downto 0);
    fu_dmem_LSU_avalid_out : out std_logic_vector(0 downto 0);
    fu_dmem_LSU_aready_in : in std_logic_vector(0 downto 0);
    fu_dmem_LSU_aaddr_out : out std_logic_vector(fu_dmem_LSU_addrw_g-7-1 downto 0);
    fu_dmem_LSU_awren_out : out std_logic_vector(0 downto 0);
    fu_dmem_LSU_astrb_out : out std_logic_vector(127 downto 0);
    fu_dmem_LSU_adata_out : out std_logic_vector(1023 downto 0);
    fu_dmem_LSU_rvalid_in : in std_logic_vector(0 downto 0);
    fu_dmem_LSU_rready_out : out std_logic_vector(0 downto 0);
    fu_dmem_LSU_rdata_in : in std_logic_vector(1023 downto 0);
    fu_pmem_LSU_avalid_out : out std_logic_vector(0 downto 0);
    fu_pmem_LSU_aready_in : in std_logic_vector(0 downto 0);
    fu_pmem_LSU_aaddr_out : out std_logic_vector(fu_pmem_LSU_addrw_g-7-1 downto 0);
    fu_pmem_LSU_awren_out : out std_logic_vector(0 downto 0);
    fu_pmem_LSU_astrb_out : out std_logic_vector(127 downto 0);
    fu_pmem_LSU_adata_out : out std_logic_vector(1023 downto 0);
    fu_pmem_LSU_rvalid_in : in std_logic_vector(0 downto 0);
    fu_pmem_LSU_rready_out : out std_logic_vector(0 downto 0);
    fu_pmem_LSU_rdata_in : in std_logic_vector(1023 downto 0);
    db_tta_nreset : in std_logic;
    db_lockcnt : out std_logic_vector(63 downto 0);
    db_cyclecnt : out std_logic_vector(63 downto 0);
    db_pc : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    db_lockrq : in std_logic;
    db_pc_start : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    db_bustraces : out std_logic_vector(BUSTRACE_WIDTH-1 downto 0);
    db_pc_next : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    fu_DBG_debug_lock_count_in : in std_logic_vector(63 downto 0);
    fu_DBG_debug_cycle_count_in : in std_logic_vector(63 downto 0));

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
  signal fu_DMA_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_DMA_t1load_wire : std_logic;
  signal fu_DMA_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_DMA_o1load_wire : std_logic;
  signal fu_DMA_o2data_wire : std_logic_vector(31 downto 0);
  signal fu_DMA_o2load_wire : std_logic;
  signal fu_DMA_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_DMA_t1opcode_wire : std_logic_vector(1 downto 0);
  signal fu_DMA_glock_wire : std_logic;
  signal fu_DMA_lockreq_wire : std_logic;
  signal fu_add_mul_sub_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_add_mul_sub_t1load_wire : std_logic;
  signal fu_add_mul_sub_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_add_mul_sub_o1load_wire : std_logic;
  signal fu_add_mul_sub_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_add_mul_sub_t1opcode_wire : std_logic_vector(1 downto 0);
  signal fu_add_mul_sub_glock_wire : std_logic;
  signal fu_dbg_generated_glock_in_wire : std_logic;
  signal fu_dbg_generated_operation_in_wire : std_logic_vector(1-1 downto 0);
  signal fu_dbg_generated_glockreq_out_wire : std_logic;
  signal fu_dbg_generated_data_in1t_in_wire : std_logic_vector(32-1 downto 0);
  signal fu_dbg_generated_load_in1t_in_wire : std_logic;
  signal fu_dbg_generated_data_out1_out_wire : std_logic_vector(32-1 downto 0);
  signal fu_dmem_LSU_t1_address_in_wire : std_logic_vector(12 downto 0);
  signal fu_dmem_LSU_t1_load_in_wire : std_logic;
  signal fu_dmem_LSU_r1_data_out_wire : std_logic_vector(1023 downto 0);
  signal fu_dmem_LSU_r2_data_out_wire : std_logic_vector(31 downto 0);
  signal fu_dmem_LSU_o1_data_in_wire : std_logic_vector(1023 downto 0);
  signal fu_dmem_LSU_o1_load_in_wire : std_logic;
  signal fu_dmem_LSU_t1_opcode_in_wire : std_logic_vector(3 downto 0);
  signal fu_dmem_LSU_glock_in_wire : std_logic;
  signal fu_dmem_LSU_glockreq_out_wire : std_logic;
  signal fu_fma_generated_glock_in_wire : std_logic;
  signal fu_fma_generated_operation_in_wire : std_logic_vector(1-1 downto 0);
  signal fu_fma_generated_glockreq_out_wire : std_logic;
  signal fu_fma_generated_data_in1t_in_wire : std_logic_vector(1024-1 downto 0);
  signal fu_fma_generated_load_in1t_in_wire : std_logic;
  signal fu_fma_generated_data_in2_in_wire : std_logic_vector(1024-1 downto 0);
  signal fu_fma_generated_load_in2_in_wire : std_logic;
  signal fu_fma_generated_data_in3_in_wire : std_logic_vector(1024-1 downto 0);
  signal fu_fma_generated_load_in3_in_wire : std_logic;
  signal fu_fma_generated_data_out1_out_wire : std_logic_vector(1024-1 downto 0);
  signal fu_pmem_LSU_t1_address_in_wire : std_logic_vector(12 downto 0);
  signal fu_pmem_LSU_t1_load_in_wire : std_logic;
  signal fu_pmem_LSU_r1_data_out_wire : std_logic_vector(1023 downto 0);
  signal fu_pmem_LSU_r2_data_out_wire : std_logic_vector(31 downto 0);
  signal fu_pmem_LSU_o1_data_in_wire : std_logic_vector(1023 downto 0);
  signal fu_pmem_LSU_o1_load_in_wire : std_logic;
  signal fu_pmem_LSU_t1_opcode_in_wire : std_logic_vector(3 downto 0);
  signal fu_pmem_LSU_glock_in_wire : std_logic;
  signal fu_pmem_LSU_glockreq_out_wire : std_logic;
  signal fu_vops_generated_glock_in_wire : std_logic;
  signal fu_vops_generated_operation_in_wire : std_logic_vector(4-1 downto 0);
  signal fu_vops_generated_glockreq_out_wire : std_logic;
  signal fu_vops_generated_data_in1t_in_wire : std_logic_vector(1024-1 downto 0);
  signal fu_vops_generated_load_in1t_in_wire : std_logic;
  signal fu_vops_generated_data_in2_in_wire : std_logic_vector(1024-1 downto 0);
  signal fu_vops_generated_load_in2_in_wire : std_logic;
  signal fu_vops_generated_data_in3_in_wire : std_logic_vector(32-1 downto 0);
  signal fu_vops_generated_load_in3_in_wire : std_logic;
  signal fu_vops_generated_data_out1_out_wire : std_logic_vector(1024-1 downto 0);
  signal ic_glock_wire : std_logic;
  signal ic_socket_ALU_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_LSU1_i1_data_wire : std_logic_vector(12 downto 0);
  signal ic_socket_LSU1_i2_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_LSU1_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_RF_BOOL_i1_data_wire : std_logic_vector(0 downto 0);
  signal ic_socket_RF_BOOL_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_vRF1024_i1_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_vRF1024_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_gcu_i1_data_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_i2_data_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_dma_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_dma_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_dma_i3_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_add_mul_sub_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_add_mul_sub_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_add_mul_sub_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_add_mul_sub_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_RF32B_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_RF32B_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_FMA_i1_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_FMA_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_FMA_i2_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_FMA_i3_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_vOPS_i1_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_vOPS_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_vOPS_i2_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_vOPS_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_vOPS_i3_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_LSU2_i2_data_wire : std_logic_vector(1023 downto 0);
  signal ic_socket_LSU2_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_LSU2_i1_data_wire : std_logic_vector(12 downto 0);
  signal ic_socket_RF32A_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_RF32A_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_DBG_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_B1_mux_ctrl_in_wire : std_logic_vector(2 downto 0);
  signal ic_B1_data_0_in_wire : std_logic_vector(31 downto 0);
  signal ic_B1_data_1_in_wire : std_logic_vector(0 downto 0);
  signal ic_B1_data_2_in_wire : std_logic_vector(31 downto 0);
  signal ic_B1_data_3_in_wire : std_logic_vector(31 downto 0);
  signal ic_B1_data_4_in_wire : std_logic_vector(1024-1 downto 0);
  signal ic_B1_data_5_in_wire : std_logic_vector(31 downto 0);
  signal ic_B1_data_6_in_wire : std_logic_vector(32-1 downto 0);
  signal ic_B2_mux_ctrl_in_wire : std_logic_vector(3 downto 0);
  signal ic_B2_data_0_in_wire : std_logic_vector(31 downto 0);
  signal ic_B2_data_1_in_wire : std_logic_vector(31 downto 0);
  signal ic_B2_data_2_in_wire : std_logic_vector(0 downto 0);
  signal ic_B2_data_3_in_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_B2_data_4_in_wire : std_logic_vector(31 downto 0);
  signal ic_B2_data_5_in_wire : std_logic_vector(31 downto 0);
  signal ic_B2_data_6_in_wire : std_logic_vector(31 downto 0);
  signal ic_B2_data_7_in_wire : std_logic_vector(31 downto 0);
  signal ic_B2_data_8_in_wire : std_logic_vector(31 downto 0);
  signal ic_B2_data_9_in_wire : std_logic_vector(31 downto 0);
  signal ic_B3_mux_ctrl_in_wire : std_logic_vector(2 downto 0);
  signal ic_B3_data_0_in_wire : std_logic_vector(31 downto 0);
  signal ic_B3_data_1_in_wire : std_logic_vector(31 downto 0);
  signal ic_B3_data_2_in_wire : std_logic_vector(31 downto 0);
  signal ic_B3_data_3_in_wire : std_logic_vector(31 downto 0);
  signal ic_B3_data_4_in_wire : std_logic_vector(31 downto 0);
  signal ic_B4_mux_ctrl_in_wire : std_logic_vector(0 downto 0);
  signal ic_B4_data_0_in_wire : std_logic_vector(31 downto 0);
  signal ic_B4_data_1_in_wire : std_logic_vector(31 downto 0);
  signal ic_vB1024A_mux_ctrl_in_wire : std_logic_vector(1 downto 0);
  signal ic_vB1024A_data_0_in_wire : std_logic_vector(1023 downto 0);
  signal ic_vB1024A_data_1_in_wire : std_logic_vector(0 downto 0);
  signal ic_vB1024A_data_2_in_wire : std_logic_vector(1023 downto 0);
  signal ic_vB1024A_data_3_in_wire : std_logic_vector(1023 downto 0);
  signal ic_vB1024B_mux_ctrl_in_wire : std_logic_vector(2 downto 0);
  signal ic_vB1024B_data_0_in_wire : std_logic_vector(1023 downto 0);
  signal ic_vB1024B_data_1_in_wire : std_logic_vector(1023 downto 0);
  signal ic_vB1024B_data_2_in_wire : std_logic_vector(1024-1 downto 0);
  signal ic_vB1024B_data_3_in_wire : std_logic_vector(1024-1 downto 0);
  signal ic_vB1024B_data_4_in_wire : std_logic_vector(1023 downto 0);
  signal ic_simm_B1_wire : std_logic_vector(31 downto 0);
  signal ic_simm_cntrl_B1_wire : std_logic_vector(0 downto 0);
  signal ic_simm_B2_wire : std_logic_vector(31 downto 0);
  signal ic_simm_cntrl_B2_wire : std_logic_vector(0 downto 0);
  signal ic_simm_B3_wire : std_logic_vector(3 downto 0);
  signal ic_simm_cntrl_B3_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_instructionword_wire : std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
  signal inst_decoder_pc_load_wire : std_logic;
  signal inst_decoder_ra_load_wire : std_logic;
  signal inst_decoder_pc_opcode_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_lock_wire : std_logic;
  signal inst_decoder_lock_r_wire : std_logic;
  signal inst_decoder_simm_B1_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_simm_B2_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_simm_B3_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_socket_ALU_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_LSU1_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_RF_BOOL_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_vRF1024_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_add_mul_sub_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_add_mul_sub_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_RF32B_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_FMA_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_vOPS_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_vOPS_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_LSU2_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_RF32A_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_B1_src_sel_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_B2_src_sel_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_B3_src_sel_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_B4_src_sel_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_vB1024A_src_sel_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_vB1024B_src_sel_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_fu_ALU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_ALU_in2_load_wire : std_logic;
  signal inst_decoder_fu_ALU_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_FMA_in1t_load_wire : std_logic;
  signal inst_decoder_fu_FMA_in2_load_wire : std_logic;
  signal inst_decoder_fu_FMA_in3_load_wire : std_logic;
  signal inst_decoder_fu_FMA_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_fu_vOPS_in1t_load_wire : std_logic;
  signal inst_decoder_fu_vOPS_in2_load_wire : std_logic;
  signal inst_decoder_fu_vOPS_in3_load_wire : std_logic;
  signal inst_decoder_fu_vOPS_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_dmem_LSU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_dmem_LSU_in2_load_wire : std_logic;
  signal inst_decoder_fu_dmem_LSU_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_pmem_LSU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_pmem_LSU_in2_load_wire : std_logic;
  signal inst_decoder_fu_pmem_LSU_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_DMA_in1t_load_wire : std_logic;
  signal inst_decoder_fu_DMA_in2_load_wire : std_logic;
  signal inst_decoder_fu_DMA_in3_load_wire : std_logic;
  signal inst_decoder_fu_DMA_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_fu_add_mul_sub_in1t_load_wire : std_logic;
  signal inst_decoder_fu_add_mul_sub_in2_load_wire : std_logic;
  signal inst_decoder_fu_add_mul_sub_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_fu_DBG_in1t_load_wire : std_logic;
  signal inst_decoder_fu_DBG_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_RF_BOOL_rd_load_wire : std_logic;
  signal inst_decoder_rf_RF_BOOL_rd_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_RF_BOOL_wr_load_wire : std_logic;
  signal inst_decoder_rf_RF_BOOL_wr_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_RF32A_rd_load_wire : std_logic;
  signal inst_decoder_rf_RF32A_rd_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_rf_RF32A_wr_load_wire : std_logic;
  signal inst_decoder_rf_RF32A_wr_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_rf_RF32B_rd_load_wire : std_logic;
  signal inst_decoder_rf_RF32B_rd_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_rf_RF32B_wr_load_wire : std_logic;
  signal inst_decoder_rf_RF32B_wr_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_rf_vRF1024_rd_load_wire : std_logic;
  signal inst_decoder_rf_vRF1024_rd_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_rf_vRF1024_wr_load_wire : std_logic;
  signal inst_decoder_rf_vRF1024_wr_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_iu_IMM_out1_read_load_wire : std_logic;
  signal inst_decoder_iu_IMM_out1_read_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_iu_IMM_write_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_iu_IMM_write_load_wire : std_logic;
  signal inst_decoder_iu_IMM_write_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_guard_RF_BOOL_0_wire : std_logic;
  signal inst_decoder_rf_guard_RF_BOOL_1_wire : std_logic;
  signal inst_decoder_lock_req_wire : std_logic_vector(6 downto 0);
  signal inst_decoder_glock_wire : std_logic_vector(13 downto 0);
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
  signal iu_IMM_r1opcode_wire : std_logic_vector(0 downto 0);
  signal iu_IMM_t1data_wire : std_logic_vector(31 downto 0);
  signal iu_IMM_t1load_wire : std_logic;
  signal iu_IMM_t1opcode_wire : std_logic_vector(0 downto 0);
  signal iu_IMM_guard_wire : std_logic_vector(0 downto 0);
  signal iu_IMM_glock_wire : std_logic;
  signal rf_RF32A_r1data_wire : std_logic_vector(31 downto 0);
  signal rf_RF32A_r1load_wire : std_logic;
  signal rf_RF32A_r1opcode_wire : std_logic_vector(3 downto 0);
  signal rf_RF32A_t1data_wire : std_logic_vector(31 downto 0);
  signal rf_RF32A_t1load_wire : std_logic;
  signal rf_RF32A_t1opcode_wire : std_logic_vector(3 downto 0);
  signal rf_RF32A_guard_wire : std_logic_vector(15 downto 0);
  signal rf_RF32A_glock_wire : std_logic;
  signal rf_RF32B_r1data_wire : std_logic_vector(31 downto 0);
  signal rf_RF32B_r1load_wire : std_logic;
  signal rf_RF32B_r1opcode_wire : std_logic_vector(3 downto 0);
  signal rf_RF32B_t1data_wire : std_logic_vector(31 downto 0);
  signal rf_RF32B_t1load_wire : std_logic;
  signal rf_RF32B_t1opcode_wire : std_logic_vector(3 downto 0);
  signal rf_RF32B_guard_wire : std_logic_vector(15 downto 0);
  signal rf_RF32B_glock_wire : std_logic;
  signal rf_RF_BOOL_r1data_wire : std_logic_vector(0 downto 0);
  signal rf_RF_BOOL_r1load_wire : std_logic;
  signal rf_RF_BOOL_r1opcode_wire : std_logic_vector(0 downto 0);
  signal rf_RF_BOOL_t1data_wire : std_logic_vector(0 downto 0);
  signal rf_RF_BOOL_t1load_wire : std_logic;
  signal rf_RF_BOOL_t1opcode_wire : std_logic_vector(0 downto 0);
  signal rf_RF_BOOL_guard_wire : std_logic_vector(1 downto 0);
  signal rf_RF_BOOL_glock_wire : std_logic;
  signal rf_vRF1024_r1data_wire : std_logic_vector(1023 downto 0);
  signal rf_vRF1024_r1load_wire : std_logic;
  signal rf_vRF1024_r1opcode_wire : std_logic_vector(1 downto 0);
  signal rf_vRF1024_t1data_wire : std_logic_vector(1023 downto 0);
  signal rf_vRF1024_t1load_wire : std_logic;
  signal rf_vRF1024_t1opcode_wire : std_logic_vector(1 downto 0);
  signal rf_vRF1024_guard_wire : std_logic_vector(3 downto 0);
  signal rf_vRF1024_glock_wire : std_logic;
  signal ground_signal : std_logic_vector(15 downto 0);

  component tta_core_ifetch
    generic (
      sync_reset_g : boolean;
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
      simm_B1 : out std_logic_vector(32-1 downto 0);
      simm_B2 : out std_logic_vector(32-1 downto 0);
      simm_B3 : out std_logic_vector(4-1 downto 0);
      socket_ALU_i1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_i2_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_LSU1_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_RF_BOOL_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_vRF1024_i1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_add_mul_sub_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_add_mul_sub_i2_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_RF32B_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_FMA_i1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_vOPS_i1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_vOPS_i2_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_LSU2_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_RF32A_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      B1_src_sel : out std_logic_vector(3-1 downto 0);
      B2_src_sel : out std_logic_vector(4-1 downto 0);
      B3_src_sel : out std_logic_vector(3-1 downto 0);
      B4_src_sel : out std_logic_vector(1-1 downto 0);
      vB1024A_src_sel : out std_logic_vector(2-1 downto 0);
      vB1024B_src_sel : out std_logic_vector(3-1 downto 0);
      fu_ALU_in1t_load : out std_logic;
      fu_ALU_in2_load : out std_logic;
      fu_ALU_opc : out std_logic_vector(4-1 downto 0);
      fu_FMA_in1t_load : out std_logic;
      fu_FMA_in2_load : out std_logic;
      fu_FMA_in3_load : out std_logic;
      fu_FMA_opc : out std_logic_vector(1-1 downto 0);
      fu_vOPS_in1t_load : out std_logic;
      fu_vOPS_in2_load : out std_logic;
      fu_vOPS_in3_load : out std_logic;
      fu_vOPS_opc : out std_logic_vector(4-1 downto 0);
      fu_dmem_LSU_in1t_load : out std_logic;
      fu_dmem_LSU_in2_load : out std_logic;
      fu_dmem_LSU_opc : out std_logic_vector(4-1 downto 0);
      fu_pmem_LSU_in1t_load : out std_logic;
      fu_pmem_LSU_in2_load : out std_logic;
      fu_pmem_LSU_opc : out std_logic_vector(4-1 downto 0);
      fu_DMA_in1t_load : out std_logic;
      fu_DMA_in2_load : out std_logic;
      fu_DMA_in3_load : out std_logic;
      fu_DMA_opc : out std_logic_vector(2-1 downto 0);
      fu_add_mul_sub_in1t_load : out std_logic;
      fu_add_mul_sub_in2_load : out std_logic;
      fu_add_mul_sub_opc : out std_logic_vector(2-1 downto 0);
      fu_DBG_in1t_load : out std_logic;
      fu_DBG_opc : out std_logic_vector(1-1 downto 0);
      rf_RF_BOOL_rd_load : out std_logic;
      rf_RF_BOOL_rd_opc : out std_logic_vector(1-1 downto 0);
      rf_RF_BOOL_wr_load : out std_logic;
      rf_RF_BOOL_wr_opc : out std_logic_vector(1-1 downto 0);
      rf_RF32A_rd_load : out std_logic;
      rf_RF32A_rd_opc : out std_logic_vector(4-1 downto 0);
      rf_RF32A_wr_load : out std_logic;
      rf_RF32A_wr_opc : out std_logic_vector(4-1 downto 0);
      rf_RF32B_rd_load : out std_logic;
      rf_RF32B_rd_opc : out std_logic_vector(4-1 downto 0);
      rf_RF32B_wr_load : out std_logic;
      rf_RF32B_wr_opc : out std_logic_vector(4-1 downto 0);
      rf_vRF1024_rd_load : out std_logic;
      rf_vRF1024_rd_opc : out std_logic_vector(2-1 downto 0);
      rf_vRF1024_wr_load : out std_logic;
      rf_vRF1024_wr_opc : out std_logic_vector(2-1 downto 0);
      iu_IMM_out1_read_load : out std_logic;
      iu_IMM_out1_read_opc : out std_logic_vector(0 downto 0);
      iu_IMM_write : out std_logic_vector(32-1 downto 0);
      iu_IMM_write_load : out std_logic;
      iu_IMM_write_opc : out std_logic_vector(0 downto 0);
      rf_guard_RF_BOOL_0 : in std_logic;
      rf_guard_RF_BOOL_1 : in std_logic;
      lock_req : in std_logic_vector(7-1 downto 0);
      glock : out std_logic_vector(14-1 downto 0);
      db_tta_nreset : in std_logic);
  end component;

  component fu_dbg
    port (
      clk : in std_logic;
      rstx : in std_logic;
      glock_in : in std_logic;
      operation_in : in std_logic_vector(1-1 downto 0);
      glockreq_out : out std_logic;
      data_in1t_in : in std_logic_vector(32-1 downto 0);
      load_in1t_in : in std_logic;
      data_out1_out : out std_logic_vector(32-1 downto 0);
      debug_lock_count_in : in std_logic_vector(64-1 downto 0);
      debug_cycle_count_in : in std_logic_vector(64-1 downto 0));
  end component;

  component fu_vops
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
      data_in3_in : in std_logic_vector(32-1 downto 0);
      load_in3_in : in std_logic;
      data_out1_out : out std_logic_vector(1024-1 downto 0));
  end component;

  component fu_fma
    port (
      clk : in std_logic;
      rstx : in std_logic;
      glock_in : in std_logic;
      operation_in : in std_logic_vector(1-1 downto 0);
      glockreq_out : out std_logic;
      data_in1t_in : in std_logic_vector(1024-1 downto 0);
      load_in1t_in : in std_logic;
      data_in2_in : in std_logic_vector(1024-1 downto 0);
      load_in2_in : in std_logic;
      data_in3_in : in std_logic_vector(1024-1 downto 0);
      load_in3_in : in std_logic;
      data_out1_out : out std_logic_vector(1024-1 downto 0));
  end component;

  component fu_axi_bc
    generic (
      data_width_g : integer;
      addr_width_g : integer;
      max_burst_log2_g : integer);
    port (
      t1data : in std_logic_vector(32-1 downto 0);
      t1load : in std_logic;
      o1data : in std_logic_vector(32-1 downto 0);
      o1load : in std_logic;
      o2data : in std_logic_vector(32-1 downto 0);
      o2load : in std_logic;
      r1data : out std_logic_vector(32-1 downto 0);
      t1opcode : in std_logic_vector(2-1 downto 0);
      m_axi_awaddr : out std_logic_vector(addr_width_g-1 downto 0);
      m_axi_awcache : out std_logic_vector(4-1 downto 0);
      m_axi_awlen : out std_logic_vector(8-1 downto 0);
      m_axi_awsize : out std_logic_vector(3-1 downto 0);
      m_axi_awburst : out std_logic_vector(2-1 downto 0);
      m_axi_awprot : out std_logic_vector(3-1 downto 0);
      m_axi_awvalid : out std_logic_vector(1-1 downto 0);
      m_axi_awready : in std_logic_vector(1-1 downto 0);
      m_axi_wdata : out std_logic_vector(data_width_g-1 downto 0);
      m_axi_wstrb : out std_logic_vector(data_width_g/8-1 downto 0);
      m_axi_wlast : out std_logic_vector(1-1 downto 0);
      m_axi_wvalid : out std_logic_vector(1-1 downto 0);
      m_axi_wready : in std_logic_vector(1-1 downto 0);
      m_axi_araddr : out std_logic_vector(addr_width_g-1 downto 0);
      m_axi_arcache : out std_logic_vector(4-1 downto 0);
      m_axi_arlen : out std_logic_vector(8-1 downto 0);
      m_axi_arsize : out std_logic_vector(3-1 downto 0);
      m_axi_arburst : out std_logic_vector(2-1 downto 0);
      m_axi_arprot : out std_logic_vector(3-1 downto 0);
      m_axi_arvalid : out std_logic_vector(1-1 downto 0);
      m_axi_arready : in std_logic_vector(1-1 downto 0);
      m_axi_rdata : in std_logic_vector(data_width_g-1 downto 0);
      m_axi_rvalid : in std_logic_vector(1-1 downto 0);
      m_axi_rready : out std_logic_vector(1-1 downto 0);
      m_axi_bvalid : in std_logic_vector(1-1 downto 0);
      m_axi_bready : out std_logic_vector(1-1 downto 0);
      m_axi_rlast : in std_logic_vector(1-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic;
      lockreq : out std_logic);
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
      t1_opcode_in : in std_logic_vector(4-1 downto 0);
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

  component fu_add_mul_sub_always_2
    generic (
      dataw : integer;
      busw : integer);
    port (
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      o1data : in std_logic_vector(dataw-1 downto 0);
      o1load : in std_logic;
      r1data : out std_logic_vector(busw-1 downto 0);
      t1opcode : in std_logic_vector(2-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component fu_add_and_eq_gt_gtu_ior_shl_shr_shru_sub_sxhw_sxqw_xor_always_2
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
      socket_ALU_i1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_i2_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i2_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_LSU1_i1_data : out std_logic_vector(13-1 downto 0);
      socket_LSU1_i2_data : out std_logic_vector(1024-1 downto 0);
      socket_LSU1_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_RF_BOOL_i1_data : out std_logic_vector(1-1 downto 0);
      socket_RF_BOOL_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_vRF1024_i1_data : out std_logic_vector(1024-1 downto 0);
      socket_vRF1024_i1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_gcu_i1_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_i2_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_dma_i1_data : out std_logic_vector(32-1 downto 0);
      socket_dma_i2_data : out std_logic_vector(32-1 downto 0);
      socket_dma_i3_data : out std_logic_vector(32-1 downto 0);
      socket_add_mul_sub_i1_data : out std_logic_vector(32-1 downto 0);
      socket_add_mul_sub_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_add_mul_sub_i2_data : out std_logic_vector(32-1 downto 0);
      socket_add_mul_sub_i2_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_RF32B_i1_data : out std_logic_vector(32-1 downto 0);
      socket_RF32B_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_FMA_i1_data : out std_logic_vector(1024-1 downto 0);
      socket_FMA_i1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_FMA_i2_data : out std_logic_vector(1024-1 downto 0);
      socket_FMA_i3_data : out std_logic_vector(1024-1 downto 0);
      socket_vOPS_i1_data : out std_logic_vector(1024-1 downto 0);
      socket_vOPS_i1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_vOPS_i2_data : out std_logic_vector(1024-1 downto 0);
      socket_vOPS_i2_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_vOPS_i3_data : out std_logic_vector(32-1 downto 0);
      socket_LSU2_i2_data : out std_logic_vector(1024-1 downto 0);
      socket_LSU2_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_LSU2_i1_data : out std_logic_vector(13-1 downto 0);
      socket_RF32A_i1_data : out std_logic_vector(32-1 downto 0);
      socket_RF32A_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_DBG_i1_data : out std_logic_vector(32-1 downto 0);
      B1_mux_ctrl_in : in std_logic_vector(3-1 downto 0);
      B1_data_0_in : in std_logic_vector(32-1 downto 0);
      B1_data_1_in : in std_logic_vector(1-1 downto 0);
      B1_data_2_in : in std_logic_vector(32-1 downto 0);
      B1_data_3_in : in std_logic_vector(32-1 downto 0);
      B1_data_4_in : in std_logic_vector(1024-1 downto 0);
      B1_data_5_in : in std_logic_vector(32-1 downto 0);
      B1_data_6_in : in std_logic_vector(32-1 downto 0);
      B2_mux_ctrl_in : in std_logic_vector(4-1 downto 0);
      B2_data_0_in : in std_logic_vector(32-1 downto 0);
      B2_data_1_in : in std_logic_vector(32-1 downto 0);
      B2_data_2_in : in std_logic_vector(1-1 downto 0);
      B2_data_3_in : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      B2_data_4_in : in std_logic_vector(32-1 downto 0);
      B2_data_5_in : in std_logic_vector(32-1 downto 0);
      B2_data_6_in : in std_logic_vector(32-1 downto 0);
      B2_data_7_in : in std_logic_vector(32-1 downto 0);
      B2_data_8_in : in std_logic_vector(32-1 downto 0);
      B2_data_9_in : in std_logic_vector(32-1 downto 0);
      B3_mux_ctrl_in : in std_logic_vector(3-1 downto 0);
      B3_data_0_in : in std_logic_vector(32-1 downto 0);
      B3_data_1_in : in std_logic_vector(32-1 downto 0);
      B3_data_2_in : in std_logic_vector(32-1 downto 0);
      B3_data_3_in : in std_logic_vector(32-1 downto 0);
      B3_data_4_in : in std_logic_vector(32-1 downto 0);
      B4_mux_ctrl_in : in std_logic_vector(1-1 downto 0);
      B4_data_0_in : in std_logic_vector(32-1 downto 0);
      B4_data_1_in : in std_logic_vector(32-1 downto 0);
      vB1024A_mux_ctrl_in : in std_logic_vector(2-1 downto 0);
      vB1024A_data_0_in : in std_logic_vector(1024-1 downto 0);
      vB1024A_data_1_in : in std_logic_vector(1-1 downto 0);
      vB1024A_data_2_in : in std_logic_vector(1024-1 downto 0);
      vB1024A_data_3_in : in std_logic_vector(1024-1 downto 0);
      vB1024B_mux_ctrl_in : in std_logic_vector(3-1 downto 0);
      vB1024B_data_0_in : in std_logic_vector(1024-1 downto 0);
      vB1024B_data_1_in : in std_logic_vector(1024-1 downto 0);
      vB1024B_data_2_in : in std_logic_vector(1024-1 downto 0);
      vB1024B_data_3_in : in std_logic_vector(1024-1 downto 0);
      vB1024B_data_4_in : in std_logic_vector(1024-1 downto 0);
      simm_B1 : in std_logic_vector(32-1 downto 0);
      simm_cntrl_B1 : in std_logic_vector(1-1 downto 0);
      simm_B2 : in std_logic_vector(32-1 downto 0);
      simm_cntrl_B2 : in std_logic_vector(1-1 downto 0);
      simm_B3 : in std_logic_vector(4-1 downto 0);
      simm_cntrl_B3 : in std_logic_vector(1-1 downto 0);
      db_bustraces : out std_logic_vector(BUSTRACE_WIDTH-1 downto 0));
  end component;


begin

  ic_B2_data_3_in_wire <= inst_fetch_ra_out_wire;
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
  ic_simm_B2_wire <= inst_decoder_simm_B2_wire;
  ic_simm_B3_wire <= inst_decoder_simm_B3_wire;
  ic_socket_ALU_i1_bus_cntrl_wire <= inst_decoder_socket_ALU_i1_bus_cntrl_wire;
  ic_socket_ALU_i2_bus_cntrl_wire <= inst_decoder_socket_ALU_i2_bus_cntrl_wire;
  ic_socket_LSU1_i2_bus_cntrl_wire <= inst_decoder_socket_LSU1_i2_bus_cntrl_wire;
  ic_socket_RF_BOOL_i1_bus_cntrl_wire <= inst_decoder_socket_RF_BOOL_i1_bus_cntrl_wire;
  ic_socket_vRF1024_i1_bus_cntrl_wire <= inst_decoder_socket_vRF1024_i1_bus_cntrl_wire;
  ic_socket_add_mul_sub_i1_bus_cntrl_wire <= inst_decoder_socket_add_mul_sub_i1_bus_cntrl_wire;
  ic_socket_add_mul_sub_i2_bus_cntrl_wire <= inst_decoder_socket_add_mul_sub_i2_bus_cntrl_wire;
  ic_socket_RF32B_i1_bus_cntrl_wire <= inst_decoder_socket_RF32B_i1_bus_cntrl_wire;
  ic_socket_FMA_i1_bus_cntrl_wire <= inst_decoder_socket_FMA_i1_bus_cntrl_wire;
  ic_socket_vOPS_i1_bus_cntrl_wire <= inst_decoder_socket_vOPS_i1_bus_cntrl_wire;
  ic_socket_vOPS_i2_bus_cntrl_wire <= inst_decoder_socket_vOPS_i2_bus_cntrl_wire;
  ic_socket_LSU2_i2_bus_cntrl_wire <= inst_decoder_socket_LSU2_i2_bus_cntrl_wire;
  ic_socket_RF32A_i1_bus_cntrl_wire <= inst_decoder_socket_RF32A_i1_bus_cntrl_wire;
  ic_B1_mux_ctrl_in_wire <= inst_decoder_B1_src_sel_wire;
  ic_B2_mux_ctrl_in_wire <= inst_decoder_B2_src_sel_wire;
  ic_B3_mux_ctrl_in_wire <= inst_decoder_B3_src_sel_wire;
  ic_B4_mux_ctrl_in_wire <= inst_decoder_B4_src_sel_wire;
  ic_vB1024A_mux_ctrl_in_wire <= inst_decoder_vB1024A_src_sel_wire;
  ic_vB1024B_mux_ctrl_in_wire <= inst_decoder_vB1024B_src_sel_wire;
  fu_ALU_t1load_wire <= inst_decoder_fu_ALU_in1t_load_wire;
  fu_ALU_o1load_wire <= inst_decoder_fu_ALU_in2_load_wire;
  fu_ALU_t1opcode_wire <= inst_decoder_fu_ALU_opc_wire;
  fu_fma_generated_load_in1t_in_wire <= inst_decoder_fu_FMA_in1t_load_wire;
  fu_fma_generated_load_in2_in_wire <= inst_decoder_fu_FMA_in2_load_wire;
  fu_fma_generated_load_in3_in_wire <= inst_decoder_fu_FMA_in3_load_wire;
  fu_fma_generated_operation_in_wire <= inst_decoder_fu_FMA_opc_wire;
  fu_vops_generated_load_in1t_in_wire <= inst_decoder_fu_vOPS_in1t_load_wire;
  fu_vops_generated_load_in2_in_wire <= inst_decoder_fu_vOPS_in2_load_wire;
  fu_vops_generated_load_in3_in_wire <= inst_decoder_fu_vOPS_in3_load_wire;
  fu_vops_generated_operation_in_wire <= inst_decoder_fu_vOPS_opc_wire;
  fu_dmem_LSU_t1_load_in_wire <= inst_decoder_fu_dmem_LSU_in1t_load_wire;
  fu_dmem_LSU_o1_load_in_wire <= inst_decoder_fu_dmem_LSU_in2_load_wire;
  fu_dmem_LSU_t1_opcode_in_wire <= inst_decoder_fu_dmem_LSU_opc_wire;
  fu_pmem_LSU_t1_load_in_wire <= inst_decoder_fu_pmem_LSU_in1t_load_wire;
  fu_pmem_LSU_o1_load_in_wire <= inst_decoder_fu_pmem_LSU_in2_load_wire;
  fu_pmem_LSU_t1_opcode_in_wire <= inst_decoder_fu_pmem_LSU_opc_wire;
  fu_DMA_t1load_wire <= inst_decoder_fu_DMA_in1t_load_wire;
  fu_DMA_o1load_wire <= inst_decoder_fu_DMA_in2_load_wire;
  fu_DMA_o2load_wire <= inst_decoder_fu_DMA_in3_load_wire;
  fu_DMA_t1opcode_wire <= inst_decoder_fu_DMA_opc_wire;
  fu_add_mul_sub_t1load_wire <= inst_decoder_fu_add_mul_sub_in1t_load_wire;
  fu_add_mul_sub_o1load_wire <= inst_decoder_fu_add_mul_sub_in2_load_wire;
  fu_add_mul_sub_t1opcode_wire <= inst_decoder_fu_add_mul_sub_opc_wire;
  fu_dbg_generated_load_in1t_in_wire <= inst_decoder_fu_DBG_in1t_load_wire;
  fu_dbg_generated_operation_in_wire <= inst_decoder_fu_DBG_opc_wire;
  rf_RF_BOOL_r1load_wire <= inst_decoder_rf_RF_BOOL_rd_load_wire;
  rf_RF_BOOL_r1opcode_wire <= inst_decoder_rf_RF_BOOL_rd_opc_wire;
  rf_RF_BOOL_t1load_wire <= inst_decoder_rf_RF_BOOL_wr_load_wire;
  rf_RF_BOOL_t1opcode_wire <= inst_decoder_rf_RF_BOOL_wr_opc_wire;
  rf_RF32A_r1load_wire <= inst_decoder_rf_RF32A_rd_load_wire;
  rf_RF32A_r1opcode_wire <= inst_decoder_rf_RF32A_rd_opc_wire;
  rf_RF32A_t1load_wire <= inst_decoder_rf_RF32A_wr_load_wire;
  rf_RF32A_t1opcode_wire <= inst_decoder_rf_RF32A_wr_opc_wire;
  rf_RF32B_r1load_wire <= inst_decoder_rf_RF32B_rd_load_wire;
  rf_RF32B_r1opcode_wire <= inst_decoder_rf_RF32B_rd_opc_wire;
  rf_RF32B_t1load_wire <= inst_decoder_rf_RF32B_wr_load_wire;
  rf_RF32B_t1opcode_wire <= inst_decoder_rf_RF32B_wr_opc_wire;
  rf_vRF1024_r1load_wire <= inst_decoder_rf_vRF1024_rd_load_wire;
  rf_vRF1024_r1opcode_wire <= inst_decoder_rf_vRF1024_rd_opc_wire;
  rf_vRF1024_t1load_wire <= inst_decoder_rf_vRF1024_wr_load_wire;
  rf_vRF1024_t1opcode_wire <= inst_decoder_rf_vRF1024_wr_opc_wire;
  iu_IMM_r1load_wire <= inst_decoder_iu_IMM_out1_read_load_wire;
  iu_IMM_r1opcode_wire <= inst_decoder_iu_IMM_out1_read_opc_wire;
  iu_IMM_t1data_wire <= inst_decoder_iu_IMM_write_wire;
  iu_IMM_t1load_wire <= inst_decoder_iu_IMM_write_load_wire;
  iu_IMM_t1opcode_wire <= inst_decoder_iu_IMM_write_opc_wire;
  inst_decoder_rf_guard_RF_BOOL_0_wire <= rf_RF_BOOL_guard_wire(0);
  inst_decoder_rf_guard_RF_BOOL_1_wire <= rf_RF_BOOL_guard_wire(1);
  inst_decoder_lock_req_wire(0) <= fu_fma_generated_glockreq_out_wire;
  inst_decoder_lock_req_wire(1) <= fu_vops_generated_glockreq_out_wire;
  inst_decoder_lock_req_wire(2) <= fu_dmem_LSU_glockreq_out_wire;
  inst_decoder_lock_req_wire(3) <= fu_pmem_LSU_glockreq_out_wire;
  inst_decoder_lock_req_wire(4) <= fu_DMA_lockreq_wire;
  inst_decoder_lock_req_wire(5) <= fu_dbg_generated_glockreq_out_wire;
  inst_decoder_lock_req_wire(6) <= db_lockrq;
  fu_ALU_glock_wire <= inst_decoder_glock_wire(0);
  fu_fma_generated_glock_in_wire <= inst_decoder_glock_wire(1);
  fu_vops_generated_glock_in_wire <= inst_decoder_glock_wire(2);
  fu_dmem_LSU_glock_in_wire <= inst_decoder_glock_wire(3);
  fu_pmem_LSU_glock_in_wire <= inst_decoder_glock_wire(4);
  fu_DMA_glock_wire <= inst_decoder_glock_wire(5);
  fu_add_mul_sub_glock_wire <= inst_decoder_glock_wire(6);
  fu_dbg_generated_glock_in_wire <= inst_decoder_glock_wire(7);
  rf_RF_BOOL_glock_wire <= inst_decoder_glock_wire(8);
  rf_RF32A_glock_wire <= inst_decoder_glock_wire(9);
  rf_RF32B_glock_wire <= inst_decoder_glock_wire(10);
  rf_vRF1024_glock_wire <= inst_decoder_glock_wire(11);
  iu_IMM_glock_wire <= inst_decoder_glock_wire(12);
  ic_glock_wire <= inst_decoder_glock_wire(13);
  fu_dbg_generated_data_in1t_in_wire <= ic_socket_DBG_i1_data_wire;
  ic_B1_data_6_in_wire <= fu_dbg_generated_data_out1_out_wire;
  fu_vops_generated_data_in1t_in_wire <= ic_socket_vOPS_i1_data_wire;
  fu_vops_generated_data_in2_in_wire <= ic_socket_vOPS_i2_data_wire;
  fu_vops_generated_data_in3_in_wire <= ic_socket_vOPS_i3_data_wire;
  ic_B1_data_4_in_wire <= fu_vops_generated_data_out1_out_wire;
  ic_vB1024B_data_3_in_wire <= fu_vops_generated_data_out1_out_wire;
  fu_fma_generated_data_in1t_in_wire <= ic_socket_FMA_i1_data_wire;
  fu_fma_generated_data_in2_in_wire <= ic_socket_FMA_i2_data_wire;
  fu_fma_generated_data_in3_in_wire <= ic_socket_FMA_i3_data_wire;
  ic_vB1024B_data_2_in_wire <= fu_fma_generated_data_out1_out_wire;
  fu_DMA_t1data_wire <= ic_socket_dma_i1_data_wire;
  fu_DMA_o1data_wire <= ic_socket_dma_i2_data_wire;
  fu_DMA_o2data_wire <= ic_socket_dma_i3_data_wire;
  ic_B2_data_5_in_wire <= fu_DMA_r1data_wire;
  fu_dmem_LSU_t1_address_in_wire <= ic_socket_LSU1_i1_data_wire;
  ic_vB1024A_data_0_in_wire <= fu_dmem_LSU_r1_data_out_wire;
  ic_vB1024B_data_0_in_wire <= fu_dmem_LSU_r1_data_out_wire;
  ic_B1_data_2_in_wire <= fu_dmem_LSU_r2_data_out_wire;
  ic_B2_data_4_in_wire <= fu_dmem_LSU_r2_data_out_wire;
  fu_dmem_LSU_o1_data_in_wire <= ic_socket_LSU1_i2_data_wire;
  fu_add_mul_sub_t1data_wire <= ic_socket_add_mul_sub_i1_data_wire;
  fu_add_mul_sub_o1data_wire <= ic_socket_add_mul_sub_i2_data_wire;
  ic_B2_data_6_in_wire <= fu_add_mul_sub_r1data_wire;
  ic_B3_data_1_in_wire <= fu_add_mul_sub_r1data_wire;
  fu_ALU_t1data_wire <= ic_socket_ALU_i1_data_wire;
  ic_B2_data_0_in_wire <= fu_ALU_r1data_wire;
  ic_B3_data_0_in_wire <= fu_ALU_r1data_wire;
  fu_ALU_o1data_wire <= ic_socket_ALU_i2_data_wire;
  fu_pmem_LSU_t1_address_in_wire <= ic_socket_LSU2_i1_data_wire;
  ic_vB1024A_data_3_in_wire <= fu_pmem_LSU_r1_data_out_wire;
  ic_vB1024B_data_4_in_wire <= fu_pmem_LSU_r1_data_out_wire;
  ic_B2_data_8_in_wire <= fu_pmem_LSU_r2_data_out_wire;
  ic_B3_data_3_in_wire <= fu_pmem_LSU_r2_data_out_wire;
  fu_pmem_LSU_o1_data_in_wire <= ic_socket_LSU2_i2_data_wire;
  ic_vB1024A_data_2_in_wire <= rf_vRF1024_r1data_wire;
  ic_vB1024B_data_1_in_wire <= rf_vRF1024_r1data_wire;
  rf_vRF1024_t1data_wire <= ic_socket_vRF1024_i1_data_wire;
  ic_B1_data_5_in_wire <= rf_RF32A_r1data_wire;
  ic_B2_data_9_in_wire <= rf_RF32A_r1data_wire;
  ic_B3_data_4_in_wire <= rf_RF32A_r1data_wire;
  ic_B4_data_1_in_wire <= rf_RF32A_r1data_wire;
  rf_RF32A_t1data_wire <= ic_socket_RF32A_i1_data_wire;
  ic_B1_data_1_in_wire <= rf_RF_BOOL_r1data_wire;
  ic_B2_data_2_in_wire <= rf_RF_BOOL_r1data_wire;
  ic_vB1024A_data_1_in_wire <= rf_RF_BOOL_r1data_wire;
  rf_RF_BOOL_t1data_wire <= ic_socket_RF_BOOL_i1_data_wire;
  ic_B1_data_3_in_wire <= rf_RF32B_r1data_wire;
  ic_B2_data_7_in_wire <= rf_RF32B_r1data_wire;
  ic_B3_data_2_in_wire <= rf_RF32B_r1data_wire;
  ic_B4_data_0_in_wire <= rf_RF32B_r1data_wire;
  rf_RF32B_t1data_wire <= ic_socket_RF32B_i1_data_wire;
  ic_B1_data_0_in_wire <= iu_IMM_r1data_wire;
  ic_B2_data_1_in_wire <= iu_IMM_r1data_wire;
  ground_signal <= (others => '0');

  inst_fetch : tta_core_ifetch
    generic map (
      sync_reset_g => true,
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
      simm_B2 => inst_decoder_simm_B2_wire,
      simm_B3 => inst_decoder_simm_B3_wire,
      socket_ALU_i1_bus_cntrl => inst_decoder_socket_ALU_i1_bus_cntrl_wire,
      socket_ALU_i2_bus_cntrl => inst_decoder_socket_ALU_i2_bus_cntrl_wire,
      socket_LSU1_i2_bus_cntrl => inst_decoder_socket_LSU1_i2_bus_cntrl_wire,
      socket_RF_BOOL_i1_bus_cntrl => inst_decoder_socket_RF_BOOL_i1_bus_cntrl_wire,
      socket_vRF1024_i1_bus_cntrl => inst_decoder_socket_vRF1024_i1_bus_cntrl_wire,
      socket_add_mul_sub_i1_bus_cntrl => inst_decoder_socket_add_mul_sub_i1_bus_cntrl_wire,
      socket_add_mul_sub_i2_bus_cntrl => inst_decoder_socket_add_mul_sub_i2_bus_cntrl_wire,
      socket_RF32B_i1_bus_cntrl => inst_decoder_socket_RF32B_i1_bus_cntrl_wire,
      socket_FMA_i1_bus_cntrl => inst_decoder_socket_FMA_i1_bus_cntrl_wire,
      socket_vOPS_i1_bus_cntrl => inst_decoder_socket_vOPS_i1_bus_cntrl_wire,
      socket_vOPS_i2_bus_cntrl => inst_decoder_socket_vOPS_i2_bus_cntrl_wire,
      socket_LSU2_i2_bus_cntrl => inst_decoder_socket_LSU2_i2_bus_cntrl_wire,
      socket_RF32A_i1_bus_cntrl => inst_decoder_socket_RF32A_i1_bus_cntrl_wire,
      B1_src_sel => inst_decoder_B1_src_sel_wire,
      B2_src_sel => inst_decoder_B2_src_sel_wire,
      B3_src_sel => inst_decoder_B3_src_sel_wire,
      B4_src_sel => inst_decoder_B4_src_sel_wire,
      vB1024A_src_sel => inst_decoder_vB1024A_src_sel_wire,
      vB1024B_src_sel => inst_decoder_vB1024B_src_sel_wire,
      fu_ALU_in1t_load => inst_decoder_fu_ALU_in1t_load_wire,
      fu_ALU_in2_load => inst_decoder_fu_ALU_in2_load_wire,
      fu_ALU_opc => inst_decoder_fu_ALU_opc_wire,
      fu_FMA_in1t_load => inst_decoder_fu_FMA_in1t_load_wire,
      fu_FMA_in2_load => inst_decoder_fu_FMA_in2_load_wire,
      fu_FMA_in3_load => inst_decoder_fu_FMA_in3_load_wire,
      fu_FMA_opc => inst_decoder_fu_FMA_opc_wire,
      fu_vOPS_in1t_load => inst_decoder_fu_vOPS_in1t_load_wire,
      fu_vOPS_in2_load => inst_decoder_fu_vOPS_in2_load_wire,
      fu_vOPS_in3_load => inst_decoder_fu_vOPS_in3_load_wire,
      fu_vOPS_opc => inst_decoder_fu_vOPS_opc_wire,
      fu_dmem_LSU_in1t_load => inst_decoder_fu_dmem_LSU_in1t_load_wire,
      fu_dmem_LSU_in2_load => inst_decoder_fu_dmem_LSU_in2_load_wire,
      fu_dmem_LSU_opc => inst_decoder_fu_dmem_LSU_opc_wire,
      fu_pmem_LSU_in1t_load => inst_decoder_fu_pmem_LSU_in1t_load_wire,
      fu_pmem_LSU_in2_load => inst_decoder_fu_pmem_LSU_in2_load_wire,
      fu_pmem_LSU_opc => inst_decoder_fu_pmem_LSU_opc_wire,
      fu_DMA_in1t_load => inst_decoder_fu_DMA_in1t_load_wire,
      fu_DMA_in2_load => inst_decoder_fu_DMA_in2_load_wire,
      fu_DMA_in3_load => inst_decoder_fu_DMA_in3_load_wire,
      fu_DMA_opc => inst_decoder_fu_DMA_opc_wire,
      fu_add_mul_sub_in1t_load => inst_decoder_fu_add_mul_sub_in1t_load_wire,
      fu_add_mul_sub_in2_load => inst_decoder_fu_add_mul_sub_in2_load_wire,
      fu_add_mul_sub_opc => inst_decoder_fu_add_mul_sub_opc_wire,
      fu_DBG_in1t_load => inst_decoder_fu_DBG_in1t_load_wire,
      fu_DBG_opc => inst_decoder_fu_DBG_opc_wire,
      rf_RF_BOOL_rd_load => inst_decoder_rf_RF_BOOL_rd_load_wire,
      rf_RF_BOOL_rd_opc => inst_decoder_rf_RF_BOOL_rd_opc_wire,
      rf_RF_BOOL_wr_load => inst_decoder_rf_RF_BOOL_wr_load_wire,
      rf_RF_BOOL_wr_opc => inst_decoder_rf_RF_BOOL_wr_opc_wire,
      rf_RF32A_rd_load => inst_decoder_rf_RF32A_rd_load_wire,
      rf_RF32A_rd_opc => inst_decoder_rf_RF32A_rd_opc_wire,
      rf_RF32A_wr_load => inst_decoder_rf_RF32A_wr_load_wire,
      rf_RF32A_wr_opc => inst_decoder_rf_RF32A_wr_opc_wire,
      rf_RF32B_rd_load => inst_decoder_rf_RF32B_rd_load_wire,
      rf_RF32B_rd_opc => inst_decoder_rf_RF32B_rd_opc_wire,
      rf_RF32B_wr_load => inst_decoder_rf_RF32B_wr_load_wire,
      rf_RF32B_wr_opc => inst_decoder_rf_RF32B_wr_opc_wire,
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

  fu_dbg_generated : fu_dbg
    port map (
      clk => clk,
      rstx => rstx,
      glock_in => fu_dbg_generated_glock_in_wire,
      operation_in => fu_dbg_generated_operation_in_wire,
      glockreq_out => fu_dbg_generated_glockreq_out_wire,
      data_in1t_in => fu_dbg_generated_data_in1t_in_wire,
      load_in1t_in => fu_dbg_generated_load_in1t_in_wire,
      data_out1_out => fu_dbg_generated_data_out1_out_wire,
      debug_lock_count_in => fu_DBG_debug_lock_count_in,
      debug_cycle_count_in => fu_DBG_debug_cycle_count_in);

  fu_vops_generated : fu_vops
    port map (
      clk => clk,
      rstx => rstx,
      glock_in => fu_vops_generated_glock_in_wire,
      operation_in => fu_vops_generated_operation_in_wire,
      glockreq_out => fu_vops_generated_glockreq_out_wire,
      data_in1t_in => fu_vops_generated_data_in1t_in_wire,
      load_in1t_in => fu_vops_generated_load_in1t_in_wire,
      data_in2_in => fu_vops_generated_data_in2_in_wire,
      load_in2_in => fu_vops_generated_load_in2_in_wire,
      data_in3_in => fu_vops_generated_data_in3_in_wire,
      load_in3_in => fu_vops_generated_load_in3_in_wire,
      data_out1_out => fu_vops_generated_data_out1_out_wire);

  fu_fma_generated : fu_fma
    port map (
      clk => clk,
      rstx => rstx,
      glock_in => fu_fma_generated_glock_in_wire,
      operation_in => fu_fma_generated_operation_in_wire,
      glockreq_out => fu_fma_generated_glockreq_out_wire,
      data_in1t_in => fu_fma_generated_data_in1t_in_wire,
      load_in1t_in => fu_fma_generated_load_in1t_in_wire,
      data_in2_in => fu_fma_generated_data_in2_in_wire,
      load_in2_in => fu_fma_generated_load_in2_in_wire,
      data_in3_in => fu_fma_generated_data_in3_in_wire,
      load_in3_in => fu_fma_generated_load_in3_in_wire,
      data_out1_out => fu_fma_generated_data_out1_out_wire);

  fu_DMA : fu_axi_bc
    generic map (
      data_width_g => fu_DMA_data_width_g,
      addr_width_g => fu_DMA_addr_width_g,
      max_burst_log2_g => 10)
    port map (
      t1data => fu_DMA_t1data_wire,
      t1load => fu_DMA_t1load_wire,
      o1data => fu_DMA_o1data_wire,
      o1load => fu_DMA_o1load_wire,
      o2data => fu_DMA_o2data_wire,
      o2load => fu_DMA_o2load_wire,
      r1data => fu_DMA_r1data_wire,
      t1opcode => fu_DMA_t1opcode_wire,
      m_axi_awaddr => fu_DMA_m_axi_awaddr,
      m_axi_awcache => fu_DMA_m_axi_awcache,
      m_axi_awlen => fu_DMA_m_axi_awlen,
      m_axi_awsize => fu_DMA_m_axi_awsize,
      m_axi_awburst => fu_DMA_m_axi_awburst,
      m_axi_awprot => fu_DMA_m_axi_awprot,
      m_axi_awvalid => fu_DMA_m_axi_awvalid,
      m_axi_awready => fu_DMA_m_axi_awready,
      m_axi_wdata => fu_DMA_m_axi_wdata,
      m_axi_wstrb => fu_DMA_m_axi_wstrb,
      m_axi_wlast => fu_DMA_m_axi_wlast,
      m_axi_wvalid => fu_DMA_m_axi_wvalid,
      m_axi_wready => fu_DMA_m_axi_wready,
      m_axi_araddr => fu_DMA_m_axi_araddr,
      m_axi_arcache => fu_DMA_m_axi_arcache,
      m_axi_arlen => fu_DMA_m_axi_arlen,
      m_axi_arsize => fu_DMA_m_axi_arsize,
      m_axi_arburst => fu_DMA_m_axi_arburst,
      m_axi_arprot => fu_DMA_m_axi_arprot,
      m_axi_arvalid => fu_DMA_m_axi_arvalid,
      m_axi_arready => fu_DMA_m_axi_arready,
      m_axi_rdata => fu_DMA_m_axi_rdata,
      m_axi_rvalid => fu_DMA_m_axi_rvalid,
      m_axi_rready => fu_DMA_m_axi_rready,
      m_axi_bvalid => fu_DMA_m_axi_bvalid,
      m_axi_bready => fu_DMA_m_axi_bready,
      m_axi_rlast => fu_DMA_m_axi_rlast,
      clk => clk,
      rstx => rstx,
      glock => fu_DMA_glock_wire,
      lockreq => fu_DMA_lockreq_wire);

  fu_dmem_LSU : fu_lsu_simd_32
    generic map (
      addrw_g => fu_dmem_LSU_addrw_g)
    port map (
      t1_address_in => fu_dmem_LSU_t1_address_in_wire,
      t1_load_in => fu_dmem_LSU_t1_load_in_wire,
      r1_data_out => fu_dmem_LSU_r1_data_out_wire,
      r2_data_out => fu_dmem_LSU_r2_data_out_wire,
      o1_data_in => fu_dmem_LSU_o1_data_in_wire,
      o1_load_in => fu_dmem_LSU_o1_load_in_wire,
      t1_opcode_in => fu_dmem_LSU_t1_opcode_in_wire,
      avalid_out => fu_dmem_LSU_avalid_out,
      aready_in => fu_dmem_LSU_aready_in,
      aaddr_out => fu_dmem_LSU_aaddr_out,
      awren_out => fu_dmem_LSU_awren_out,
      astrb_out => fu_dmem_LSU_astrb_out,
      adata_out => fu_dmem_LSU_adata_out,
      rvalid_in => fu_dmem_LSU_rvalid_in,
      rready_out => fu_dmem_LSU_rready_out,
      rdata_in => fu_dmem_LSU_rdata_in,
      clk => clk,
      rstx => rstx,
      glock_in => fu_dmem_LSU_glock_in_wire,
      glockreq_out => fu_dmem_LSU_glockreq_out_wire);

  fu_add_mul_sub : fu_add_mul_sub_always_2
    generic map (
      dataw => 32,
      busw => 32)
    port map (
      t1data => fu_add_mul_sub_t1data_wire,
      t1load => fu_add_mul_sub_t1load_wire,
      o1data => fu_add_mul_sub_o1data_wire,
      o1load => fu_add_mul_sub_o1load_wire,
      r1data => fu_add_mul_sub_r1data_wire,
      t1opcode => fu_add_mul_sub_t1opcode_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_add_mul_sub_glock_wire);

  fu_ALU : fu_add_and_eq_gt_gtu_ior_shl_shr_shru_sub_sxhw_sxqw_xor_always_2
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

  fu_pmem_LSU : fu_lsu_simd_32
    generic map (
      addrw_g => fu_pmem_LSU_addrw_g)
    port map (
      t1_address_in => fu_pmem_LSU_t1_address_in_wire,
      t1_load_in => fu_pmem_LSU_t1_load_in_wire,
      r1_data_out => fu_pmem_LSU_r1_data_out_wire,
      r2_data_out => fu_pmem_LSU_r2_data_out_wire,
      o1_data_in => fu_pmem_LSU_o1_data_in_wire,
      o1_load_in => fu_pmem_LSU_o1_load_in_wire,
      t1_opcode_in => fu_pmem_LSU_t1_opcode_in_wire,
      avalid_out => fu_pmem_LSU_avalid_out,
      aready_in => fu_pmem_LSU_aready_in,
      aaddr_out => fu_pmem_LSU_aaddr_out,
      awren_out => fu_pmem_LSU_awren_out,
      astrb_out => fu_pmem_LSU_astrb_out,
      adata_out => fu_pmem_LSU_adata_out,
      rvalid_in => fu_pmem_LSU_rvalid_in,
      rready_out => fu_pmem_LSU_rready_out,
      rdata_in => fu_pmem_LSU_rdata_in,
      clk => clk,
      rstx => rstx,
      glock_in => fu_pmem_LSU_glock_in_wire,
      glockreq_out => fu_pmem_LSU_glockreq_out_wire);

  rf_vRF1024 : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 1024,
      rf_size => 4)
    port map (
      r1data => rf_vRF1024_r1data_wire,
      r1load => rf_vRF1024_r1load_wire,
      r1opcode => rf_vRF1024_r1opcode_wire,
      t1data => rf_vRF1024_t1data_wire,
      t1load => rf_vRF1024_t1load_wire,
      t1opcode => rf_vRF1024_t1opcode_wire,
      guard => rf_vRF1024_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => rf_vRF1024_glock_wire);

  rf_RF32A : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 32,
      rf_size => 16)
    port map (
      r1data => rf_RF32A_r1data_wire,
      r1load => rf_RF32A_r1load_wire,
      r1opcode => rf_RF32A_r1opcode_wire,
      t1data => rf_RF32A_t1data_wire,
      t1load => rf_RF32A_t1load_wire,
      t1opcode => rf_RF32A_t1opcode_wire,
      guard => rf_RF32A_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => rf_RF32A_glock_wire);

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

  rf_RF32B : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 32,
      rf_size => 16)
    port map (
      r1data => rf_RF32B_r1data_wire,
      r1load => rf_RF32B_r1load_wire,
      r1opcode => rf_RF32B_r1opcode_wire,
      t1data => rf_RF32B_t1data_wire,
      t1load => rf_RF32B_t1load_wire,
      t1opcode => rf_RF32B_t1opcode_wire,
      guard => rf_RF32B_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => rf_RF32B_glock_wire);

  iu_IMM : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 32,
      rf_size => 1)
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
      socket_ALU_i2_data => ic_socket_ALU_i2_data_wire,
      socket_ALU_i2_bus_cntrl => ic_socket_ALU_i2_bus_cntrl_wire,
      socket_LSU1_i1_data => ic_socket_LSU1_i1_data_wire,
      socket_LSU1_i2_data => ic_socket_LSU1_i2_data_wire,
      socket_LSU1_i2_bus_cntrl => ic_socket_LSU1_i2_bus_cntrl_wire,
      socket_RF_BOOL_i1_data => ic_socket_RF_BOOL_i1_data_wire,
      socket_RF_BOOL_i1_bus_cntrl => ic_socket_RF_BOOL_i1_bus_cntrl_wire,
      socket_vRF1024_i1_data => ic_socket_vRF1024_i1_data_wire,
      socket_vRF1024_i1_bus_cntrl => ic_socket_vRF1024_i1_bus_cntrl_wire,
      socket_gcu_i1_data => ic_socket_gcu_i1_data_wire,
      socket_gcu_i2_data => ic_socket_gcu_i2_data_wire,
      socket_dma_i1_data => ic_socket_dma_i1_data_wire,
      socket_dma_i2_data => ic_socket_dma_i2_data_wire,
      socket_dma_i3_data => ic_socket_dma_i3_data_wire,
      socket_add_mul_sub_i1_data => ic_socket_add_mul_sub_i1_data_wire,
      socket_add_mul_sub_i1_bus_cntrl => ic_socket_add_mul_sub_i1_bus_cntrl_wire,
      socket_add_mul_sub_i2_data => ic_socket_add_mul_sub_i2_data_wire,
      socket_add_mul_sub_i2_bus_cntrl => ic_socket_add_mul_sub_i2_bus_cntrl_wire,
      socket_RF32B_i1_data => ic_socket_RF32B_i1_data_wire,
      socket_RF32B_i1_bus_cntrl => ic_socket_RF32B_i1_bus_cntrl_wire,
      socket_FMA_i1_data => ic_socket_FMA_i1_data_wire,
      socket_FMA_i1_bus_cntrl => ic_socket_FMA_i1_bus_cntrl_wire,
      socket_FMA_i2_data => ic_socket_FMA_i2_data_wire,
      socket_FMA_i3_data => ic_socket_FMA_i3_data_wire,
      socket_vOPS_i1_data => ic_socket_vOPS_i1_data_wire,
      socket_vOPS_i1_bus_cntrl => ic_socket_vOPS_i1_bus_cntrl_wire,
      socket_vOPS_i2_data => ic_socket_vOPS_i2_data_wire,
      socket_vOPS_i2_bus_cntrl => ic_socket_vOPS_i2_bus_cntrl_wire,
      socket_vOPS_i3_data => ic_socket_vOPS_i3_data_wire,
      socket_LSU2_i2_data => ic_socket_LSU2_i2_data_wire,
      socket_LSU2_i2_bus_cntrl => ic_socket_LSU2_i2_bus_cntrl_wire,
      socket_LSU2_i1_data => ic_socket_LSU2_i1_data_wire,
      socket_RF32A_i1_data => ic_socket_RF32A_i1_data_wire,
      socket_RF32A_i1_bus_cntrl => ic_socket_RF32A_i1_bus_cntrl_wire,
      socket_DBG_i1_data => ic_socket_DBG_i1_data_wire,
      B1_mux_ctrl_in => ic_B1_mux_ctrl_in_wire,
      B1_data_0_in => ic_B1_data_0_in_wire,
      B1_data_1_in => ic_B1_data_1_in_wire,
      B1_data_2_in => ic_B1_data_2_in_wire,
      B1_data_3_in => ic_B1_data_3_in_wire,
      B1_data_4_in => ic_B1_data_4_in_wire,
      B1_data_5_in => ic_B1_data_5_in_wire,
      B1_data_6_in => ic_B1_data_6_in_wire,
      B2_mux_ctrl_in => ic_B2_mux_ctrl_in_wire,
      B2_data_0_in => ic_B2_data_0_in_wire,
      B2_data_1_in => ic_B2_data_1_in_wire,
      B2_data_2_in => ic_B2_data_2_in_wire,
      B2_data_3_in => ic_B2_data_3_in_wire,
      B2_data_4_in => ic_B2_data_4_in_wire,
      B2_data_5_in => ic_B2_data_5_in_wire,
      B2_data_6_in => ic_B2_data_6_in_wire,
      B2_data_7_in => ic_B2_data_7_in_wire,
      B2_data_8_in => ic_B2_data_8_in_wire,
      B2_data_9_in => ic_B2_data_9_in_wire,
      B3_mux_ctrl_in => ic_B3_mux_ctrl_in_wire,
      B3_data_0_in => ic_B3_data_0_in_wire,
      B3_data_1_in => ic_B3_data_1_in_wire,
      B3_data_2_in => ic_B3_data_2_in_wire,
      B3_data_3_in => ic_B3_data_3_in_wire,
      B3_data_4_in => ic_B3_data_4_in_wire,
      B4_mux_ctrl_in => ic_B4_mux_ctrl_in_wire,
      B4_data_0_in => ic_B4_data_0_in_wire,
      B4_data_1_in => ic_B4_data_1_in_wire,
      vB1024A_mux_ctrl_in => ic_vB1024A_mux_ctrl_in_wire,
      vB1024A_data_0_in => ic_vB1024A_data_0_in_wire,
      vB1024A_data_1_in => ic_vB1024A_data_1_in_wire,
      vB1024A_data_2_in => ic_vB1024A_data_2_in_wire,
      vB1024A_data_3_in => ic_vB1024A_data_3_in_wire,
      vB1024B_mux_ctrl_in => ic_vB1024B_mux_ctrl_in_wire,
      vB1024B_data_0_in => ic_vB1024B_data_0_in_wire,
      vB1024B_data_1_in => ic_vB1024B_data_1_in_wire,
      vB1024B_data_2_in => ic_vB1024B_data_2_in_wire,
      vB1024B_data_3_in => ic_vB1024B_data_3_in_wire,
      vB1024B_data_4_in => ic_vB1024B_data_4_in_wire,
      simm_B1 => ic_simm_B1_wire,
      simm_cntrl_B1 => ic_simm_cntrl_B1_wire,
      simm_B2 => ic_simm_B2_wire,
      simm_cntrl_B2 => ic_simm_cntrl_B2_wire,
      simm_B3 => ic_simm_B3_wire,
      simm_cntrl_B3 => ic_simm_cntrl_B3_wire,
      db_bustraces => db_bustraces);

end structural;
