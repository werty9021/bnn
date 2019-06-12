library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tce_util.all;
use work.tta0_globals.all;
use work.tta0_imem_mau.all;
use work.tta0_params.all;

entity tta0 is

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
    fu_LSU_inp_mem_en_x : out std_logic_vector(0 downto 0);
    fu_LSU_inp_wr_en_x : out std_logic_vector(0 downto 0);
    fu_LSU_inp_wr_mask_x : out std_logic_vector(fu_LSU_inp_dataw-1 downto 0);
    fu_LSU_inp_addr : out std_logic_vector(fu_LSU_inp_addrw-2-1 downto 0);
    fu_LSU_inp_data_in : in std_logic_vector(fu_LSU_inp_dataw-1 downto 0);
    fu_LSU_inp_data_out : out std_logic_vector(fu_LSU_inp_dataw-1 downto 0);
    fu_LSU_mem_en_x : out std_logic_vector(0 downto 0);
    fu_LSU_wr_en_x : out std_logic_vector(0 downto 0);
    fu_LSU_wr_mask_x : out std_logic_vector(fu_LSU_dataw-1 downto 0);
    fu_LSU_addr : out std_logic_vector(fu_LSU_addrw-2-1 downto 0);
    fu_LSU_data_in : in std_logic_vector(fu_LSU_dataw-1 downto 0);
    fu_LSU_data_out : out std_logic_vector(fu_LSU_dataw-1 downto 0));

end tta0;

architecture structural of tta0 is

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
  signal fu_BNN_OPS_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_BNN_OPS_t1load_wire : std_logic;
  signal fu_BNN_OPS_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_BNN_OPS_o2data_wire : std_logic_vector(31 downto 0);
  signal fu_BNN_OPS_o2load_wire : std_logic;
  signal fu_BNN_OPS_o3data_wire : std_logic_vector(31 downto 0);
  signal fu_BNN_OPS_o3load_wire : std_logic;
  signal fu_BNN_OPS_t1opcode_wire : std_logic_vector(1 downto 0);
  signal fu_BNN_OPS_glock_wire : std_logic;
  signal fu_F32_I32_CONVERTER_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_F32_I32_CONVERTER_t1load_wire : std_logic;
  signal fu_F32_I32_CONVERTER_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_F32_I32_CONVERTER_t1opcode_wire : std_logic_vector(1 downto 0);
  signal fu_F32_I32_CONVERTER_glock_wire : std_logic;
  signal fu_FALU_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_FALU_o1load_wire : std_logic;
  signal fu_FALU_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_FALU_t1load_wire : std_logic;
  signal fu_FALU_o2data_wire : std_logic_vector(31 downto 0);
  signal fu_FALU_o2load_wire : std_logic;
  signal fu_FALU_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_FALU_t1opcode_wire : std_logic_vector(3 downto 0);
  signal fu_FALU_glock_wire : std_logic;
  signal fu_LSU_inp_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_LSU_inp_t1load_wire : std_logic;
  signal fu_LSU_inp_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_LSU_inp_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_LSU_inp_o1load_wire : std_logic;
  signal fu_LSU_inp_t1opcode_wire : std_logic_vector(2 downto 0);
  signal fu_LSU_inp_glock_wire : std_logic;
  signal fu_LSU_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_LSU_t1load_wire : std_logic;
  signal fu_LSU_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_LSU_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_LSU_o1load_wire : std_logic;
  signal fu_LSU_t1opcode_wire : std_logic_vector(2 downto 0);
  signal fu_LSU_glock_wire : std_logic;
  signal fu_STREAM_t1data_wire : std_logic_vector(7 downto 0);
  signal fu_STREAM_t1load_wire : std_logic;
  signal fu_STREAM_glock_wire : std_logic;
  signal fu_divf_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_divf_t1load_wire : std_logic;
  signal fu_divf_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_divf_o1load_wire : std_logic;
  signal fu_divf_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_divf_glock_wire : std_logic;
  signal ic_glock_wire : std_logic;
  signal ic_socket_RF_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_RF_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_RF_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_RF_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_bool_i1_data_wire : std_logic_vector(0 downto 0);
  signal ic_socket_bool_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_bool_o1_data0_wire : std_logic_vector(0 downto 0);
  signal ic_socket_bool_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_gcu_i1_data_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_gcu_i2_data_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_gcu_o1_data0_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_LSU_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_LSU_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_LSU_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_LSU_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_LSU_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_LSU_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_LSU_inp_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_LSU_inp_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_LSU_inp_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_LSU_inp_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_LSU_inp_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_LSU_inp_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_ALU_i3_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_ALU_o2_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_o2_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_ALU_i4_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i4_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_STREAM_i2_data_wire : std_logic_vector(7 downto 0);
  signal ic_socket_STREAM_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_cfi_cfiu_cif_cifu_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_cfi_cfiu_cif_cifu_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_divf_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_divf_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_divf_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_divf_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_divf_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_divf_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_IMM1_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_IMM1_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_simm_B1_wire : std_logic_vector(31 downto 0);
  signal ic_simm_cntrl_B1_wire : std_logic_vector(0 downto 0);
  signal ic_simm_B1_1_wire : std_logic_vector(31 downto 0);
  signal ic_simm_cntrl_B1_1_wire : std_logic_vector(0 downto 0);
  signal ic_simm_B1_2_wire : std_logic_vector(31 downto 0);
  signal ic_simm_cntrl_B1_2_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_instructionword_wire : std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
  signal inst_decoder_pc_load_wire : std_logic;
  signal inst_decoder_ra_load_wire : std_logic;
  signal inst_decoder_pc_opcode_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_lock_wire : std_logic;
  signal inst_decoder_lock_r_wire : std_logic;
  signal inst_decoder_simm_B1_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_simm_cntrl_B1_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_simm_B1_1_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_simm_cntrl_B1_1_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_simm_B1_2_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_simm_cntrl_B1_2_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_RF_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_RF_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_bool_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_bool_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_gcu_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_gcu_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_gcu_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_LSU_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_LSU_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_LSU_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_LSU_inp_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_LSU_inp_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_LSU_inp_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_ALU_i3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_ALU_o2_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_ALU_i4_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_STREAM_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_divf_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_divf_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_divf_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_IMM1_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_fu_FALU_in1_load_wire : std_logic;
  signal inst_decoder_fu_FALU_in2t_load_wire : std_logic;
  signal inst_decoder_fu_FALU_in3_load_wire : std_logic;
  signal inst_decoder_fu_FALU_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_LSU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_LSU_in2_load_wire : std_logic;
  signal inst_decoder_fu_LSU_opc_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_fu_LSU_inp_in1t_load_wire : std_logic;
  signal inst_decoder_fu_LSU_inp_in2_load_wire : std_logic;
  signal inst_decoder_fu_LSU_inp_opc_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_fu_ALU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_ALU_in2_load_wire : std_logic;
  signal inst_decoder_fu_ALU_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_STREAM_in1t_load_wire : std_logic;
  signal inst_decoder_fu_F32_I32_CONVERTER_in1t_load_wire : std_logic;
  signal inst_decoder_fu_F32_I32_CONVERTER_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_fu_divf_in1t_load_wire : std_logic;
  signal inst_decoder_fu_divf_in2_load_wire : std_logic;
  signal inst_decoder_fu_BNN_OPS_in1t_load_wire : std_logic;
  signal inst_decoder_fu_BNN_OPS_in2_load_wire : std_logic;
  signal inst_decoder_fu_BNN_OPS_in3_load_wire : std_logic;
  signal inst_decoder_fu_BNN_OPS_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_rf_RF_wr_load_wire : std_logic;
  signal inst_decoder_rf_RF_wr_opc_wire : std_logic_vector(4 downto 0);
  signal inst_decoder_rf_RF_rd_load_wire : std_logic;
  signal inst_decoder_rf_RF_rd_opc_wire : std_logic_vector(4 downto 0);
  signal inst_decoder_rf_BOOL_wr_load_wire : std_logic;
  signal inst_decoder_rf_BOOL_wr_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_rf_BOOL_rd_load_wire : std_logic;
  signal inst_decoder_rf_BOOL_rd_opc_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_iu_IMM1_out1_read_load_wire : std_logic;
  signal inst_decoder_iu_IMM1_out1_read_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_iu_IMM1_write_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_iu_IMM1_write_load_wire : std_logic;
  signal inst_decoder_iu_IMM1_write_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_guard_BOOL_0_wire : std_logic;
  signal inst_decoder_rf_guard_BOOL_1_wire : std_logic;
  signal inst_decoder_glock_wire : std_logic_vector(11 downto 0);
  signal inst_fetch_ra_out_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal inst_fetch_ra_in_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal inst_fetch_pc_in_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal inst_fetch_pc_load_wire : std_logic;
  signal inst_fetch_ra_load_wire : std_logic;
  signal inst_fetch_pc_opcode_wire : std_logic_vector(0 downto 0);
  signal inst_fetch_fetch_en_wire : std_logic;
  signal inst_fetch_glock_wire : std_logic;
  signal inst_fetch_fetchblock_wire : std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
  signal iu_IMM1_r1data_wire : std_logic_vector(31 downto 0);
  signal iu_IMM1_r1load_wire : std_logic;
  signal iu_IMM1_r1opcode_wire : std_logic_vector(0 downto 0);
  signal iu_IMM1_t1data_wire : std_logic_vector(31 downto 0);
  signal iu_IMM1_t1load_wire : std_logic;
  signal iu_IMM1_t1opcode_wire : std_logic_vector(0 downto 0);
  signal iu_IMM1_guard_wire : std_logic_vector(0 downto 0);
  signal iu_IMM1_glock_wire : std_logic;
  signal rf_BOOL_r1data_wire : std_logic_vector(0 downto 0);
  signal rf_BOOL_r1load_wire : std_logic;
  signal rf_BOOL_r1opcode_wire : std_logic_vector(1 downto 0);
  signal rf_BOOL_t1data_wire : std_logic_vector(0 downto 0);
  signal rf_BOOL_t1load_wire : std_logic;
  signal rf_BOOL_t1opcode_wire : std_logic_vector(1 downto 0);
  signal rf_BOOL_guard_wire : std_logic_vector(3 downto 0);
  signal rf_BOOL_glock_wire : std_logic;
  signal rf_RF_r1data_wire : std_logic_vector(31 downto 0);
  signal rf_RF_r1load_wire : std_logic;
  signal rf_RF_r1opcode_wire : std_logic_vector(4 downto 0);
  signal rf_RF_t1data_wire : std_logic_vector(31 downto 0);
  signal rf_RF_t1load_wire : std_logic;
  signal rf_RF_t1opcode_wire : std_logic_vector(4 downto 0);
  signal rf_RF_guard_wire : std_logic_vector(31 downto 0);
  signal rf_RF_glock_wire : std_logic;
  signal ground_signal : std_logic_vector(31 downto 0);

  component tta0_ifetch
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
      fetchblock : out std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0));
  end component;

  component tta0_decompressor
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

  component tta0_decoder
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
      simm_cntrl_B1 : out std_logic_vector(1-1 downto 0);
      simm_B1_1 : out std_logic_vector(32-1 downto 0);
      simm_cntrl_B1_1 : out std_logic_vector(1-1 downto 0);
      simm_B1_2 : out std_logic_vector(32-1 downto 0);
      simm_cntrl_B1_2 : out std_logic_vector(1-1 downto 0);
      socket_RF_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_RF_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_bool_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_bool_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_gcu_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_gcu_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_gcu_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_LSU_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_LSU_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_LSU_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_LSU_inp_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_LSU_inp_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_LSU_inp_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_ALU_i3_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_ALU_o2_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_ALU_i4_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_STREAM_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_cfi_cfiu_cif_cifu_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_cfi_cfiu_cif_cifu_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_divf_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_divf_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_divf_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_IMM1_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl : out std_logic_vector(2-1 downto 0);
      fu_FALU_in1_load : out std_logic;
      fu_FALU_in2t_load : out std_logic;
      fu_FALU_in3_load : out std_logic;
      fu_FALU_opc : out std_logic_vector(4-1 downto 0);
      fu_LSU_in1t_load : out std_logic;
      fu_LSU_in2_load : out std_logic;
      fu_LSU_opc : out std_logic_vector(3-1 downto 0);
      fu_LSU_inp_in1t_load : out std_logic;
      fu_LSU_inp_in2_load : out std_logic;
      fu_LSU_inp_opc : out std_logic_vector(3-1 downto 0);
      fu_ALU_in1t_load : out std_logic;
      fu_ALU_in2_load : out std_logic;
      fu_ALU_opc : out std_logic_vector(4-1 downto 0);
      fu_STREAM_in1t_load : out std_logic;
      fu_F32_I32_CONVERTER_in1t_load : out std_logic;
      fu_F32_I32_CONVERTER_opc : out std_logic_vector(2-1 downto 0);
      fu_divf_in1t_load : out std_logic;
      fu_divf_in2_load : out std_logic;
      fu_BNN_OPS_in1t_load : out std_logic;
      fu_BNN_OPS_in2_load : out std_logic;
      fu_BNN_OPS_in3_load : out std_logic;
      fu_BNN_OPS_opc : out std_logic_vector(2-1 downto 0);
      rf_RF_wr_load : out std_logic;
      rf_RF_wr_opc : out std_logic_vector(5-1 downto 0);
      rf_RF_rd_load : out std_logic;
      rf_RF_rd_opc : out std_logic_vector(5-1 downto 0);
      rf_BOOL_wr_load : out std_logic;
      rf_BOOL_wr_opc : out std_logic_vector(2-1 downto 0);
      rf_BOOL_rd_load : out std_logic;
      rf_BOOL_rd_opc : out std_logic_vector(2-1 downto 0);
      iu_IMM1_out1_read_load : out std_logic;
      iu_IMM1_out1_read_opc : out std_logic_vector(0 downto 0);
      iu_IMM1_write : out std_logic_vector(32-1 downto 0);
      iu_IMM1_write_load : out std_logic;
      iu_IMM1_write_opc : out std_logic_vector(0 downto 0);
      rf_guard_BOOL_0 : in std_logic;
      rf_guard_BOOL_1 : in std_logic;
      glock : out std_logic_vector(12-1 downto 0));
  end component;

  component fu_lsu_le_always_3
    generic (
      dataw : integer;
      addrw : integer);
    port (
      t1data : in std_logic_vector(addrw-1 downto 0);
      t1load : in std_logic;
      r1data : out std_logic_vector(dataw-1 downto 0);
      o1data : in std_logic_vector(dataw-1 downto 0);
      o1load : in std_logic;
      t1opcode : in std_logic_vector(3-1 downto 0);
      mem_en_x : out std_logic_vector(1-1 downto 0);
      wr_en_x : out std_logic_vector(1-1 downto 0);
      wr_mask_x : out std_logic_vector(dataw-1 downto 0);
      addr : out std_logic_vector(addrw-2-1 downto 0);
      data_in : in std_logic_vector(dataw-1 downto 0);
      data_out : out std_logic_vector(dataw-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component printchar_always_1
    generic (
      dataw : integer);
    port (
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component fu_abs_add_and_eq_gt_gtu_ior_neg_shl_shl1add_shl2add_shr_shru_sub_sxhw_sxqw_xor_always_1
    generic (
      dataw : integer;
      busw : integer);
    port (
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      r1data : out std_logic_vector(busw-1 downto 0);
      o1data : in std_logic_vector(dataw-1 downto 0);
      o1load : in std_logic;
      t1opcode : in std_logic_vector(4-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component fpu_sp_conv
    generic (
      busw : integer);
    port (
      t1data : in std_logic_vector(busw-1 downto 0);
      t1load : in std_logic;
      r1data : out std_logic_vector(busw-1 downto 0);
      t1opcode : in std_logic_vector(2-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component sabrewing_tce
    generic (
      dataw : integer;
      busw : integer;
      bypass_2 : boolean);
    port (
      o1data : in std_logic_vector(dataw-1 downto 0);
      o1load : in std_logic;
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      o2data : in std_logic_vector(dataw-1 downto 0);
      o2load : in std_logic;
      r1data : out std_logic_vector(busw-1 downto 0);
      t1opcode : in std_logic_vector(4-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component fpu_sp_div
    generic (
      busw : integer);
    port (
      t1data : in std_logic_vector(busw-1 downto 0);
      t1load : in std_logic;
      o1data : in std_logic_vector(busw-1 downto 0);
      o1load : in std_logic;
      r1data : out std_logic_vector(busw-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component bnn_ops
    generic (
      busw : integer);
    port (
      t1data : in std_logic_vector(busw-1 downto 0);
      t1load : in std_logic;
      r1data : out std_logic_vector(busw-1 downto 0);
      o2data : in std_logic_vector(busw-1 downto 0);
      o2load : in std_logic;
      o3data : in std_logic_vector(busw-1 downto 0);
      o3load : in std_logic;
      t1opcode : in std_logic_vector(2-1 downto 0);
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

  component tta0_interconn
    port (
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic;
      socket_RF_i1_data : out std_logic_vector(32-1 downto 0);
      socket_RF_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_RF_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_RF_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_bool_i1_data : out std_logic_vector(1-1 downto 0);
      socket_bool_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_bool_o1_data0 : in std_logic_vector(1-1 downto 0);
      socket_bool_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_gcu_i1_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_gcu_i2_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_gcu_o1_data0 : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_data : out std_logic_vector(32-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_data : out std_logic_vector(32-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_data : out std_logic_vector(32-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_LSU_i1_data : out std_logic_vector(32-1 downto 0);
      socket_LSU_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_LSU_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_LSU_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_LSU_i2_data : out std_logic_vector(32-1 downto 0);
      socket_LSU_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_LSU_inp_i1_data : out std_logic_vector(32-1 downto 0);
      socket_LSU_inp_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_LSU_inp_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_LSU_inp_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_LSU_inp_i2_data : out std_logic_vector(32-1 downto 0);
      socket_LSU_inp_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_ALU_i3_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i3_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_ALU_o2_data0 : in std_logic_vector(32-1 downto 0);
      socket_ALU_o2_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_ALU_i4_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i4_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_STREAM_i2_data : out std_logic_vector(8-1 downto 0);
      socket_STREAM_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_cfi_cfiu_cif_cifu_i1_data : out std_logic_vector(32-1 downto 0);
      socket_cfi_cfiu_cif_cifu_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_cfi_cfiu_cif_cifu_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_cfi_cfiu_cif_cifu_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_divf_i1_data : out std_logic_vector(32-1 downto 0);
      socket_divf_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_divf_i2_data : out std_logic_vector(32-1 downto 0);
      socket_divf_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_divf_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_divf_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_IMM1_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_IMM1_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_data : out std_logic_vector(32-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_data : out std_logic_vector(32-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_data : out std_logic_vector(32-1 downto 0);
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl : in std_logic_vector(2-1 downto 0);
      simm_B1 : in std_logic_vector(32-1 downto 0);
      simm_cntrl_B1 : in std_logic_vector(1-1 downto 0);
      simm_B1_1 : in std_logic_vector(32-1 downto 0);
      simm_cntrl_B1_1 : in std_logic_vector(1-1 downto 0);
      simm_B1_2 : in std_logic_vector(32-1 downto 0);
      simm_cntrl_B1_2 : in std_logic_vector(1-1 downto 0));
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
  ic_simm_B1_1_wire <= inst_decoder_simm_B1_1_wire;
  ic_simm_cntrl_B1_1_wire <= inst_decoder_simm_cntrl_B1_1_wire;
  ic_simm_B1_2_wire <= inst_decoder_simm_B1_2_wire;
  ic_simm_cntrl_B1_2_wire <= inst_decoder_simm_cntrl_B1_2_wire;
  ic_socket_RF_i1_bus_cntrl_wire <= inst_decoder_socket_RF_i1_bus_cntrl_wire;
  ic_socket_RF_o1_bus_cntrl_wire <= inst_decoder_socket_RF_o1_bus_cntrl_wire;
  ic_socket_bool_i1_bus_cntrl_wire <= inst_decoder_socket_bool_i1_bus_cntrl_wire;
  ic_socket_bool_o1_bus_cntrl_wire <= inst_decoder_socket_bool_o1_bus_cntrl_wire;
  ic_socket_gcu_i1_bus_cntrl_wire <= inst_decoder_socket_gcu_i1_bus_cntrl_wire;
  ic_socket_gcu_i2_bus_cntrl_wire <= inst_decoder_socket_gcu_i2_bus_cntrl_wire;
  ic_socket_gcu_o1_bus_cntrl_wire <= inst_decoder_socket_gcu_o1_bus_cntrl_wire;
  ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_wire <= inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_wire;
  ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_wire <= inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_wire;
  ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_wire <= inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_wire;
  ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_wire <= inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_wire;
  ic_socket_LSU_i1_bus_cntrl_wire <= inst_decoder_socket_LSU_i1_bus_cntrl_wire;
  ic_socket_LSU_o1_bus_cntrl_wire <= inst_decoder_socket_LSU_o1_bus_cntrl_wire;
  ic_socket_LSU_i2_bus_cntrl_wire <= inst_decoder_socket_LSU_i2_bus_cntrl_wire;
  ic_socket_LSU_inp_i1_bus_cntrl_wire <= inst_decoder_socket_LSU_inp_i1_bus_cntrl_wire;
  ic_socket_LSU_inp_o1_bus_cntrl_wire <= inst_decoder_socket_LSU_inp_o1_bus_cntrl_wire;
  ic_socket_LSU_inp_i2_bus_cntrl_wire <= inst_decoder_socket_LSU_inp_i2_bus_cntrl_wire;
  ic_socket_ALU_i3_bus_cntrl_wire <= inst_decoder_socket_ALU_i3_bus_cntrl_wire;
  ic_socket_ALU_o2_bus_cntrl_wire <= inst_decoder_socket_ALU_o2_bus_cntrl_wire;
  ic_socket_ALU_i4_bus_cntrl_wire <= inst_decoder_socket_ALU_i4_bus_cntrl_wire;
  ic_socket_STREAM_i2_bus_cntrl_wire <= inst_decoder_socket_STREAM_i2_bus_cntrl_wire;
  ic_socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_wire <= inst_decoder_socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_wire;
  ic_socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_wire <= inst_decoder_socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_wire;
  ic_socket_divf_i1_bus_cntrl_wire <= inst_decoder_socket_divf_i1_bus_cntrl_wire;
  ic_socket_divf_i2_bus_cntrl_wire <= inst_decoder_socket_divf_i2_bus_cntrl_wire;
  ic_socket_divf_o1_bus_cntrl_wire <= inst_decoder_socket_divf_o1_bus_cntrl_wire;
  ic_socket_IMM1_o1_bus_cntrl_wire <= inst_decoder_socket_IMM1_o1_bus_cntrl_wire;
  ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_wire <= inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_wire;
  ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_wire <= inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_wire;
  ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_wire <= inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_wire;
  ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_wire <= inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_wire;
  fu_FALU_o1load_wire <= inst_decoder_fu_FALU_in1_load_wire;
  fu_FALU_t1load_wire <= inst_decoder_fu_FALU_in2t_load_wire;
  fu_FALU_o2load_wire <= inst_decoder_fu_FALU_in3_load_wire;
  fu_FALU_t1opcode_wire <= inst_decoder_fu_FALU_opc_wire;
  fu_LSU_t1load_wire <= inst_decoder_fu_LSU_in1t_load_wire;
  fu_LSU_o1load_wire <= inst_decoder_fu_LSU_in2_load_wire;
  fu_LSU_t1opcode_wire <= inst_decoder_fu_LSU_opc_wire;
  fu_LSU_inp_t1load_wire <= inst_decoder_fu_LSU_inp_in1t_load_wire;
  fu_LSU_inp_o1load_wire <= inst_decoder_fu_LSU_inp_in2_load_wire;
  fu_LSU_inp_t1opcode_wire <= inst_decoder_fu_LSU_inp_opc_wire;
  fu_ALU_t1load_wire <= inst_decoder_fu_ALU_in1t_load_wire;
  fu_ALU_o1load_wire <= inst_decoder_fu_ALU_in2_load_wire;
  fu_ALU_t1opcode_wire <= inst_decoder_fu_ALU_opc_wire;
  fu_STREAM_t1load_wire <= inst_decoder_fu_STREAM_in1t_load_wire;
  fu_F32_I32_CONVERTER_t1load_wire <= inst_decoder_fu_F32_I32_CONVERTER_in1t_load_wire;
  fu_F32_I32_CONVERTER_t1opcode_wire <= inst_decoder_fu_F32_I32_CONVERTER_opc_wire;
  fu_divf_t1load_wire <= inst_decoder_fu_divf_in1t_load_wire;
  fu_divf_o1load_wire <= inst_decoder_fu_divf_in2_load_wire;
  fu_BNN_OPS_t1load_wire <= inst_decoder_fu_BNN_OPS_in1t_load_wire;
  fu_BNN_OPS_o2load_wire <= inst_decoder_fu_BNN_OPS_in2_load_wire;
  fu_BNN_OPS_o3load_wire <= inst_decoder_fu_BNN_OPS_in3_load_wire;
  fu_BNN_OPS_t1opcode_wire <= inst_decoder_fu_BNN_OPS_opc_wire;
  rf_RF_t1load_wire <= inst_decoder_rf_RF_wr_load_wire;
  rf_RF_t1opcode_wire <= inst_decoder_rf_RF_wr_opc_wire;
  rf_RF_r1load_wire <= inst_decoder_rf_RF_rd_load_wire;
  rf_RF_r1opcode_wire <= inst_decoder_rf_RF_rd_opc_wire;
  rf_BOOL_t1load_wire <= inst_decoder_rf_BOOL_wr_load_wire;
  rf_BOOL_t1opcode_wire <= inst_decoder_rf_BOOL_wr_opc_wire;
  rf_BOOL_r1load_wire <= inst_decoder_rf_BOOL_rd_load_wire;
  rf_BOOL_r1opcode_wire <= inst_decoder_rf_BOOL_rd_opc_wire;
  iu_IMM1_r1load_wire <= inst_decoder_iu_IMM1_out1_read_load_wire;
  iu_IMM1_r1opcode_wire <= inst_decoder_iu_IMM1_out1_read_opc_wire;
  iu_IMM1_t1data_wire <= inst_decoder_iu_IMM1_write_wire;
  iu_IMM1_t1load_wire <= inst_decoder_iu_IMM1_write_load_wire;
  iu_IMM1_t1opcode_wire <= inst_decoder_iu_IMM1_write_opc_wire;
  inst_decoder_rf_guard_BOOL_0_wire <= rf_BOOL_guard_wire(0);
  inst_decoder_rf_guard_BOOL_1_wire <= rf_BOOL_guard_wire(1);
  fu_FALU_glock_wire <= inst_decoder_glock_wire(0);
  fu_LSU_glock_wire <= inst_decoder_glock_wire(1);
  fu_LSU_inp_glock_wire <= inst_decoder_glock_wire(2);
  fu_ALU_glock_wire <= inst_decoder_glock_wire(3);
  fu_STREAM_glock_wire <= inst_decoder_glock_wire(4);
  fu_F32_I32_CONVERTER_glock_wire <= inst_decoder_glock_wire(5);
  fu_divf_glock_wire <= inst_decoder_glock_wire(6);
  fu_BNN_OPS_glock_wire <= inst_decoder_glock_wire(7);
  rf_RF_glock_wire <= inst_decoder_glock_wire(8);
  rf_BOOL_glock_wire <= inst_decoder_glock_wire(9);
  iu_IMM1_glock_wire <= inst_decoder_glock_wire(10);
  ic_glock_wire <= inst_decoder_glock_wire(11);
  fu_LSU_inp_t1data_wire <= ic_socket_LSU_inp_i1_data_wire;
  ic_socket_LSU_inp_o1_data0_wire <= fu_LSU_inp_r1data_wire;
  fu_LSU_inp_o1data_wire <= ic_socket_LSU_inp_i2_data_wire;
  fu_LSU_t1data_wire <= ic_socket_LSU_i1_data_wire;
  ic_socket_LSU_o1_data0_wire <= fu_LSU_r1data_wire;
  fu_LSU_o1data_wire <= ic_socket_LSU_i2_data_wire;
  fu_STREAM_t1data_wire <= ic_socket_STREAM_i2_data_wire;
  fu_ALU_t1data_wire <= ic_socket_ALU_i3_data_wire;
  ic_socket_ALU_o2_data0_wire <= fu_ALU_r1data_wire;
  fu_ALU_o1data_wire <= ic_socket_ALU_i4_data_wire;
  fu_F32_I32_CONVERTER_t1data_wire <= ic_socket_cfi_cfiu_cif_cifu_i1_data_wire;
  ic_socket_cfi_cfiu_cif_cifu_o1_data0_wire <= fu_F32_I32_CONVERTER_r1data_wire;
  fu_FALU_o1data_wire <= ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_data_wire;
  fu_FALU_t1data_wire <= ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_data_wire;
  fu_FALU_o2data_wire <= ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_data_wire;
  ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_data0_wire <= fu_FALU_r1data_wire;
  fu_divf_t1data_wire <= ic_socket_divf_i1_data_wire;
  fu_divf_o1data_wire <= ic_socket_divf_i2_data_wire;
  ic_socket_divf_o1_data0_wire <= fu_divf_r1data_wire;
  fu_BNN_OPS_t1data_wire <= ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_data_wire;
  ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_data0_wire <= fu_BNN_OPS_r1data_wire;
  fu_BNN_OPS_o2data_wire <= ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_data_wire;
  fu_BNN_OPS_o3data_wire <= ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_data_wire;
  ic_socket_bool_o1_data0_wire <= rf_BOOL_r1data_wire;
  rf_BOOL_t1data_wire <= ic_socket_bool_i1_data_wire;
  ic_socket_RF_o1_data0_wire <= rf_RF_r1data_wire;
  rf_RF_t1data_wire <= ic_socket_RF_i1_data_wire;
  ic_socket_IMM1_o1_data0_wire <= iu_IMM1_r1data_wire;
  ground_signal <= (others => '0');

  inst_fetch : tta0_ifetch
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
      fetchblock => inst_fetch_fetchblock_wire);

  decomp : tta0_decompressor
    port map (
      fetch_en => decomp_fetch_en_wire,
      lock => decomp_lock_wire,
      fetchblock => decomp_fetchblock_wire,
      clk => clk,
      rstx => rstx,
      instructionword => decomp_instructionword_wire,
      glock => decomp_glock_wire,
      lock_r => decomp_lock_r_wire);

  inst_decoder : tta0_decoder
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
      simm_B1_1 => inst_decoder_simm_B1_1_wire,
      simm_cntrl_B1_1 => inst_decoder_simm_cntrl_B1_1_wire,
      simm_B1_2 => inst_decoder_simm_B1_2_wire,
      simm_cntrl_B1_2 => inst_decoder_simm_cntrl_B1_2_wire,
      socket_RF_i1_bus_cntrl => inst_decoder_socket_RF_i1_bus_cntrl_wire,
      socket_RF_o1_bus_cntrl => inst_decoder_socket_RF_o1_bus_cntrl_wire,
      socket_bool_i1_bus_cntrl => inst_decoder_socket_bool_i1_bus_cntrl_wire,
      socket_bool_o1_bus_cntrl => inst_decoder_socket_bool_o1_bus_cntrl_wire,
      socket_gcu_i1_bus_cntrl => inst_decoder_socket_gcu_i1_bus_cntrl_wire,
      socket_gcu_i2_bus_cntrl => inst_decoder_socket_gcu_i2_bus_cntrl_wire,
      socket_gcu_o1_bus_cntrl => inst_decoder_socket_gcu_o1_bus_cntrl_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl => inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl => inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl => inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl => inst_decoder_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_wire,
      socket_LSU_i1_bus_cntrl => inst_decoder_socket_LSU_i1_bus_cntrl_wire,
      socket_LSU_o1_bus_cntrl => inst_decoder_socket_LSU_o1_bus_cntrl_wire,
      socket_LSU_i2_bus_cntrl => inst_decoder_socket_LSU_i2_bus_cntrl_wire,
      socket_LSU_inp_i1_bus_cntrl => inst_decoder_socket_LSU_inp_i1_bus_cntrl_wire,
      socket_LSU_inp_o1_bus_cntrl => inst_decoder_socket_LSU_inp_o1_bus_cntrl_wire,
      socket_LSU_inp_i2_bus_cntrl => inst_decoder_socket_LSU_inp_i2_bus_cntrl_wire,
      socket_ALU_i3_bus_cntrl => inst_decoder_socket_ALU_i3_bus_cntrl_wire,
      socket_ALU_o2_bus_cntrl => inst_decoder_socket_ALU_o2_bus_cntrl_wire,
      socket_ALU_i4_bus_cntrl => inst_decoder_socket_ALU_i4_bus_cntrl_wire,
      socket_STREAM_i2_bus_cntrl => inst_decoder_socket_STREAM_i2_bus_cntrl_wire,
      socket_cfi_cfiu_cif_cifu_i1_bus_cntrl => inst_decoder_socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_wire,
      socket_cfi_cfiu_cif_cifu_o1_bus_cntrl => inst_decoder_socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_wire,
      socket_divf_i1_bus_cntrl => inst_decoder_socket_divf_i1_bus_cntrl_wire,
      socket_divf_i2_bus_cntrl => inst_decoder_socket_divf_i2_bus_cntrl_wire,
      socket_divf_o1_bus_cntrl => inst_decoder_socket_divf_o1_bus_cntrl_wire,
      socket_IMM1_o1_bus_cntrl => inst_decoder_socket_IMM1_o1_bus_cntrl_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl => inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl => inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl => inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl => inst_decoder_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_wire,
      fu_FALU_in1_load => inst_decoder_fu_FALU_in1_load_wire,
      fu_FALU_in2t_load => inst_decoder_fu_FALU_in2t_load_wire,
      fu_FALU_in3_load => inst_decoder_fu_FALU_in3_load_wire,
      fu_FALU_opc => inst_decoder_fu_FALU_opc_wire,
      fu_LSU_in1t_load => inst_decoder_fu_LSU_in1t_load_wire,
      fu_LSU_in2_load => inst_decoder_fu_LSU_in2_load_wire,
      fu_LSU_opc => inst_decoder_fu_LSU_opc_wire,
      fu_LSU_inp_in1t_load => inst_decoder_fu_LSU_inp_in1t_load_wire,
      fu_LSU_inp_in2_load => inst_decoder_fu_LSU_inp_in2_load_wire,
      fu_LSU_inp_opc => inst_decoder_fu_LSU_inp_opc_wire,
      fu_ALU_in1t_load => inst_decoder_fu_ALU_in1t_load_wire,
      fu_ALU_in2_load => inst_decoder_fu_ALU_in2_load_wire,
      fu_ALU_opc => inst_decoder_fu_ALU_opc_wire,
      fu_STREAM_in1t_load => inst_decoder_fu_STREAM_in1t_load_wire,
      fu_F32_I32_CONVERTER_in1t_load => inst_decoder_fu_F32_I32_CONVERTER_in1t_load_wire,
      fu_F32_I32_CONVERTER_opc => inst_decoder_fu_F32_I32_CONVERTER_opc_wire,
      fu_divf_in1t_load => inst_decoder_fu_divf_in1t_load_wire,
      fu_divf_in2_load => inst_decoder_fu_divf_in2_load_wire,
      fu_BNN_OPS_in1t_load => inst_decoder_fu_BNN_OPS_in1t_load_wire,
      fu_BNN_OPS_in2_load => inst_decoder_fu_BNN_OPS_in2_load_wire,
      fu_BNN_OPS_in3_load => inst_decoder_fu_BNN_OPS_in3_load_wire,
      fu_BNN_OPS_opc => inst_decoder_fu_BNN_OPS_opc_wire,
      rf_RF_wr_load => inst_decoder_rf_RF_wr_load_wire,
      rf_RF_wr_opc => inst_decoder_rf_RF_wr_opc_wire,
      rf_RF_rd_load => inst_decoder_rf_RF_rd_load_wire,
      rf_RF_rd_opc => inst_decoder_rf_RF_rd_opc_wire,
      rf_BOOL_wr_load => inst_decoder_rf_BOOL_wr_load_wire,
      rf_BOOL_wr_opc => inst_decoder_rf_BOOL_wr_opc_wire,
      rf_BOOL_rd_load => inst_decoder_rf_BOOL_rd_load_wire,
      rf_BOOL_rd_opc => inst_decoder_rf_BOOL_rd_opc_wire,
      iu_IMM1_out1_read_load => inst_decoder_iu_IMM1_out1_read_load_wire,
      iu_IMM1_out1_read_opc => inst_decoder_iu_IMM1_out1_read_opc_wire,
      iu_IMM1_write => inst_decoder_iu_IMM1_write_wire,
      iu_IMM1_write_load => inst_decoder_iu_IMM1_write_load_wire,
      iu_IMM1_write_opc => inst_decoder_iu_IMM1_write_opc_wire,
      rf_guard_BOOL_0 => inst_decoder_rf_guard_BOOL_0_wire,
      rf_guard_BOOL_1 => inst_decoder_rf_guard_BOOL_1_wire,
      glock => inst_decoder_glock_wire);

  fu_LSU_inp : fu_lsu_le_always_3
    generic map (
      dataw => fu_LSU_inp_dataw,
      addrw => fu_LSU_inp_addrw)
    port map (
      t1data => fu_LSU_inp_t1data_wire,
      t1load => fu_LSU_inp_t1load_wire,
      r1data => fu_LSU_inp_r1data_wire,
      o1data => fu_LSU_inp_o1data_wire,
      o1load => fu_LSU_inp_o1load_wire,
      t1opcode => fu_LSU_inp_t1opcode_wire,
      mem_en_x => fu_LSU_inp_mem_en_x,
      wr_en_x => fu_LSU_inp_wr_en_x,
      wr_mask_x => fu_LSU_inp_wr_mask_x,
      addr => fu_LSU_inp_addr,
      data_in => fu_LSU_inp_data_in,
      data_out => fu_LSU_inp_data_out,
      clk => clk,
      rstx => rstx,
      glock => fu_LSU_inp_glock_wire);

  fu_LSU : fu_lsu_le_always_3
    generic map (
      dataw => fu_LSU_dataw,
      addrw => fu_LSU_addrw)
    port map (
      t1data => fu_LSU_t1data_wire,
      t1load => fu_LSU_t1load_wire,
      r1data => fu_LSU_r1data_wire,
      o1data => fu_LSU_o1data_wire,
      o1load => fu_LSU_o1load_wire,
      t1opcode => fu_LSU_t1opcode_wire,
      mem_en_x => fu_LSU_mem_en_x,
      wr_en_x => fu_LSU_wr_en_x,
      wr_mask_x => fu_LSU_wr_mask_x,
      addr => fu_LSU_addr,
      data_in => fu_LSU_data_in,
      data_out => fu_LSU_data_out,
      clk => clk,
      rstx => rstx,
      glock => fu_LSU_glock_wire);

  fu_STREAM : printchar_always_1
    generic map (
      dataw => 8)
    port map (
      t1data => fu_STREAM_t1data_wire,
      t1load => fu_STREAM_t1load_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_STREAM_glock_wire);

  fu_ALU : fu_abs_add_and_eq_gt_gtu_ior_neg_shl_shl1add_shl2add_shr_shru_sub_sxhw_sxqw_xor_always_1
    generic map (
      dataw => 32,
      busw => 32)
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

  fu_F32_I32_CONVERTER : fpu_sp_conv
    generic map (
      busw => 32)
    port map (
      t1data => fu_F32_I32_CONVERTER_t1data_wire,
      t1load => fu_F32_I32_CONVERTER_t1load_wire,
      r1data => fu_F32_I32_CONVERTER_r1data_wire,
      t1opcode => fu_F32_I32_CONVERTER_t1opcode_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_F32_I32_CONVERTER_glock_wire);

  fu_FALU : sabrewing_tce
    generic map (
      dataw => 32,
      busw => 32,
      bypass_2 => True)
    port map (
      o1data => fu_FALU_o1data_wire,
      o1load => fu_FALU_o1load_wire,
      t1data => fu_FALU_t1data_wire,
      t1load => fu_FALU_t1load_wire,
      o2data => fu_FALU_o2data_wire,
      o2load => fu_FALU_o2load_wire,
      r1data => fu_FALU_r1data_wire,
      t1opcode => fu_FALU_t1opcode_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_FALU_glock_wire);

  fu_divf : fpu_sp_div
    generic map (
      busw => 32)
    port map (
      t1data => fu_divf_t1data_wire,
      t1load => fu_divf_t1load_wire,
      o1data => fu_divf_o1data_wire,
      o1load => fu_divf_o1load_wire,
      r1data => fu_divf_r1data_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_divf_glock_wire);

  fu_BNN_OPS : bnn_ops
    generic map (
      busw => 32)
    port map (
      t1data => fu_BNN_OPS_t1data_wire,
      t1load => fu_BNN_OPS_t1load_wire,
      r1data => fu_BNN_OPS_r1data_wire,
      o2data => fu_BNN_OPS_o2data_wire,
      o2load => fu_BNN_OPS_o2load_wire,
      o3data => fu_BNN_OPS_o3data_wire,
      o3load => fu_BNN_OPS_o3load_wire,
      t1opcode => fu_BNN_OPS_t1opcode_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_BNN_OPS_glock_wire);

  rf_BOOL : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 1,
      rf_size => 4)
    port map (
      r1data => rf_BOOL_r1data_wire,
      r1load => rf_BOOL_r1load_wire,
      r1opcode => rf_BOOL_r1opcode_wire,
      t1data => rf_BOOL_t1data_wire,
      t1load => rf_BOOL_t1load_wire,
      t1opcode => rf_BOOL_t1opcode_wire,
      guard => rf_BOOL_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => rf_BOOL_glock_wire);

  rf_RF : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 32,
      rf_size => 32)
    port map (
      r1data => rf_RF_r1data_wire,
      r1load => rf_RF_r1load_wire,
      r1opcode => rf_RF_r1opcode_wire,
      t1data => rf_RF_t1data_wire,
      t1load => rf_RF_t1load_wire,
      t1opcode => rf_RF_t1opcode_wire,
      guard => rf_RF_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => rf_RF_glock_wire);

  iu_IMM1 : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 32,
      rf_size => 1)
    port map (
      r1data => iu_IMM1_r1data_wire,
      r1load => iu_IMM1_r1load_wire,
      r1opcode => iu_IMM1_r1opcode_wire,
      t1data => iu_IMM1_t1data_wire,
      t1load => iu_IMM1_t1load_wire,
      t1opcode => iu_IMM1_t1opcode_wire,
      guard => iu_IMM1_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => iu_IMM1_glock_wire);

  ic : tta0_interconn
    port map (
      clk => clk,
      rstx => rstx,
      glock => ic_glock_wire,
      socket_RF_i1_data => ic_socket_RF_i1_data_wire,
      socket_RF_i1_bus_cntrl => ic_socket_RF_i1_bus_cntrl_wire,
      socket_RF_o1_data0 => ic_socket_RF_o1_data0_wire,
      socket_RF_o1_bus_cntrl => ic_socket_RF_o1_bus_cntrl_wire,
      socket_bool_i1_data => ic_socket_bool_i1_data_wire,
      socket_bool_i1_bus_cntrl => ic_socket_bool_i1_bus_cntrl_wire,
      socket_bool_o1_data0 => ic_socket_bool_o1_data0_wire,
      socket_bool_o1_bus_cntrl => ic_socket_bool_o1_bus_cntrl_wire,
      socket_gcu_i1_data => ic_socket_gcu_i1_data_wire,
      socket_gcu_i1_bus_cntrl => ic_socket_gcu_i1_bus_cntrl_wire,
      socket_gcu_i2_data => ic_socket_gcu_i2_data_wire,
      socket_gcu_i2_bus_cntrl => ic_socket_gcu_i2_bus_cntrl_wire,
      socket_gcu_o1_data0 => ic_socket_gcu_o1_data0_wire,
      socket_gcu_o1_bus_cntrl => ic_socket_gcu_o1_bus_cntrl_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_data => ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_data_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl => ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_data => ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_data_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl => ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_data => ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_data_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl => ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_data0 => ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_data0_wire,
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl => ic_socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_wire,
      socket_LSU_i1_data => ic_socket_LSU_i1_data_wire,
      socket_LSU_i1_bus_cntrl => ic_socket_LSU_i1_bus_cntrl_wire,
      socket_LSU_o1_data0 => ic_socket_LSU_o1_data0_wire,
      socket_LSU_o1_bus_cntrl => ic_socket_LSU_o1_bus_cntrl_wire,
      socket_LSU_i2_data => ic_socket_LSU_i2_data_wire,
      socket_LSU_i2_bus_cntrl => ic_socket_LSU_i2_bus_cntrl_wire,
      socket_LSU_inp_i1_data => ic_socket_LSU_inp_i1_data_wire,
      socket_LSU_inp_i1_bus_cntrl => ic_socket_LSU_inp_i1_bus_cntrl_wire,
      socket_LSU_inp_o1_data0 => ic_socket_LSU_inp_o1_data0_wire,
      socket_LSU_inp_o1_bus_cntrl => ic_socket_LSU_inp_o1_bus_cntrl_wire,
      socket_LSU_inp_i2_data => ic_socket_LSU_inp_i2_data_wire,
      socket_LSU_inp_i2_bus_cntrl => ic_socket_LSU_inp_i2_bus_cntrl_wire,
      socket_ALU_i3_data => ic_socket_ALU_i3_data_wire,
      socket_ALU_i3_bus_cntrl => ic_socket_ALU_i3_bus_cntrl_wire,
      socket_ALU_o2_data0 => ic_socket_ALU_o2_data0_wire,
      socket_ALU_o2_bus_cntrl => ic_socket_ALU_o2_bus_cntrl_wire,
      socket_ALU_i4_data => ic_socket_ALU_i4_data_wire,
      socket_ALU_i4_bus_cntrl => ic_socket_ALU_i4_bus_cntrl_wire,
      socket_STREAM_i2_data => ic_socket_STREAM_i2_data_wire,
      socket_STREAM_i2_bus_cntrl => ic_socket_STREAM_i2_bus_cntrl_wire,
      socket_cfi_cfiu_cif_cifu_i1_data => ic_socket_cfi_cfiu_cif_cifu_i1_data_wire,
      socket_cfi_cfiu_cif_cifu_i1_bus_cntrl => ic_socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_wire,
      socket_cfi_cfiu_cif_cifu_o1_data0 => ic_socket_cfi_cfiu_cif_cifu_o1_data0_wire,
      socket_cfi_cfiu_cif_cifu_o1_bus_cntrl => ic_socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_wire,
      socket_divf_i1_data => ic_socket_divf_i1_data_wire,
      socket_divf_i1_bus_cntrl => ic_socket_divf_i1_bus_cntrl_wire,
      socket_divf_i2_data => ic_socket_divf_i2_data_wire,
      socket_divf_i2_bus_cntrl => ic_socket_divf_i2_bus_cntrl_wire,
      socket_divf_o1_data0 => ic_socket_divf_o1_data0_wire,
      socket_divf_o1_bus_cntrl => ic_socket_divf_o1_bus_cntrl_wire,
      socket_IMM1_o1_data0 => ic_socket_IMM1_o1_data0_wire,
      socket_IMM1_o1_bus_cntrl => ic_socket_IMM1_o1_bus_cntrl_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_data => ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_data_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl => ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_data0 => ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_data0_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl => ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_data => ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_data_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl => ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_data => ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_data_wire,
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl => ic_socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_wire,
      simm_B1 => ic_simm_B1_wire,
      simm_cntrl_B1 => ic_simm_cntrl_B1_wire,
      simm_B1_1 => ic_simm_B1_1_wire,
      simm_cntrl_B1_1 => ic_simm_cntrl_B1_1_wire,
      simm_B1_2 => ic_simm_B1_2_wire,
      simm_cntrl_B1_2 => ic_simm_cntrl_B1_2_wire);

end structural;
