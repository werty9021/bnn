library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tta0_globals.all;
use work.tta0_gcu_opcodes.all;
use work.tce_util.all;

entity tta0_decoder is

  port (
    instructionword : in std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
    pc_load : out std_logic;
    ra_load : out std_logic;
    pc_opcode : out std_logic_vector(0 downto 0);
    lock : in std_logic;
    lock_r : out std_logic;
    clk : in std_logic;
    rstx : in std_logic;
    locked : out std_logic;
    simm_B1 : out std_logic_vector(31 downto 0);
    simm_cntrl_B1 : out std_logic_vector(0 downto 0);
    simm_B1_1 : out std_logic_vector(31 downto 0);
    simm_cntrl_B1_1 : out std_logic_vector(0 downto 0);
    simm_B1_2 : out std_logic_vector(31 downto 0);
    simm_cntrl_B1_2 : out std_logic_vector(0 downto 0);
    socket_RF_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_RF_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_bool_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_bool_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_gcu_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_gcu_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_gcu_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_LSU_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_LSU_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_LSU_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_LSU_inp_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_LSU_inp_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_LSU_inp_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_ALU_i3_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_ALU_o2_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_ALU_i4_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_STREAM_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_cfi_cfiu_cif_cifu_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_cfi_cfiu_cif_cifu_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_divf_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_divf_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_divf_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_IMM1_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl : out std_logic_vector(1 downto 0);
    fu_FALU_in1_load : out std_logic;
    fu_FALU_in2t_load : out std_logic;
    fu_FALU_in3_load : out std_logic;
    fu_FALU_opc : out std_logic_vector(3 downto 0);
    fu_LSU_in1t_load : out std_logic;
    fu_LSU_in2_load : out std_logic;
    fu_LSU_opc : out std_logic_vector(2 downto 0);
    fu_LSU_inp_in1t_load : out std_logic;
    fu_LSU_inp_in2_load : out std_logic;
    fu_LSU_inp_opc : out std_logic_vector(2 downto 0);
    fu_ALU_in1t_load : out std_logic;
    fu_ALU_in2_load : out std_logic;
    fu_ALU_opc : out std_logic_vector(3 downto 0);
    fu_STREAM_in1t_load : out std_logic;
    fu_F32_I32_CONVERTER_in1t_load : out std_logic;
    fu_F32_I32_CONVERTER_opc : out std_logic_vector(1 downto 0);
    fu_divf_in1t_load : out std_logic;
    fu_divf_in2_load : out std_logic;
    fu_BNN_OPS_in1t_load : out std_logic;
    fu_BNN_OPS_in2_load : out std_logic;
    fu_BNN_OPS_in3_load : out std_logic;
    fu_BNN_OPS_opc : out std_logic_vector(1 downto 0);
    rf_RF_wr_load : out std_logic;
    rf_RF_wr_opc : out std_logic_vector(4 downto 0);
    rf_RF_rd_load : out std_logic;
    rf_RF_rd_opc : out std_logic_vector(4 downto 0);
    rf_BOOL_wr_load : out std_logic;
    rf_BOOL_wr_opc : out std_logic_vector(1 downto 0);
    rf_BOOL_rd_load : out std_logic;
    rf_BOOL_rd_opc : out std_logic_vector(1 downto 0);
    iu_IMM1_out1_read_load : out std_logic;
    iu_IMM1_out1_read_opc : out std_logic_vector(0 downto 0);
    iu_IMM1_write : out std_logic_vector(31 downto 0);
    iu_IMM1_write_load : out std_logic;
    iu_IMM1_write_opc : out std_logic_vector(0 downto 0);
    rf_guard_BOOL_0 : in std_logic;
    rf_guard_BOOL_1 : in std_logic;
    glock : out std_logic_vector(11 downto 0));

end tta0_decoder;

architecture rtl_andor of tta0_decoder is

  -- signals for source, destination and guard fields
  signal move_B1 : std_logic_vector(42 downto 0);
  signal src_B1 : std_logic_vector(32 downto 0);
  signal dst_B1 : std_logic_vector(6 downto 0);
  signal grd_B1 : std_logic_vector(2 downto 0);
  signal move_B1_1 : std_logic_vector(42 downto 0);
  signal src_B1_1 : std_logic_vector(32 downto 0);
  signal dst_B1_1 : std_logic_vector(6 downto 0);
  signal grd_B1_1 : std_logic_vector(2 downto 0);
  signal move_B1_2 : std_logic_vector(42 downto 0);
  signal src_B1_2 : std_logic_vector(32 downto 0);
  signal dst_B1_2 : std_logic_vector(6 downto 0);
  signal grd_B1_2 : std_logic_vector(2 downto 0);

  -- signals for dedicated immediate slots


  -- squash signals
  signal squash_B1 : std_logic;
  signal squash_B1_1 : std_logic;
  signal squash_B1_2 : std_logic;

  -- socket control signals
  signal socket_RF_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_RF_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_bool_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_bool_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_gcu_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_gcu_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_gcu_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_LSU_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_LSU_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_LSU_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_LSU_inp_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_LSU_inp_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_LSU_inp_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_ALU_i3_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_ALU_o2_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_ALU_i4_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_STREAM_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_divf_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_divf_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_divf_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_IMM1_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal simm_B1_reg : std_logic_vector(31 downto 0);
  signal simm_cntrl_B1_reg : std_logic_vector(0 downto 0);
  signal simm_B1_1_reg : std_logic_vector(31 downto 0);
  signal simm_cntrl_B1_1_reg : std_logic_vector(0 downto 0);
  signal simm_B1_2_reg : std_logic_vector(31 downto 0);
  signal simm_cntrl_B1_2_reg : std_logic_vector(0 downto 0);

  -- FU control signals
  signal fu_FALU_in1_load_reg : std_logic;
  signal fu_FALU_in2t_load_reg : std_logic;
  signal fu_FALU_in3_load_reg : std_logic;
  signal fu_FALU_opc_reg : std_logic_vector(3 downto 0);
  signal fu_LSU_in1t_load_reg : std_logic;
  signal fu_LSU_in2_load_reg : std_logic;
  signal fu_LSU_opc_reg : std_logic_vector(2 downto 0);
  signal fu_LSU_inp_in1t_load_reg : std_logic;
  signal fu_LSU_inp_in2_load_reg : std_logic;
  signal fu_LSU_inp_opc_reg : std_logic_vector(2 downto 0);
  signal fu_ALU_in1t_load_reg : std_logic;
  signal fu_ALU_in2_load_reg : std_logic;
  signal fu_ALU_opc_reg : std_logic_vector(3 downto 0);
  signal fu_STREAM_in1t_load_reg : std_logic;
  signal fu_F32_I32_CONVERTER_in1t_load_reg : std_logic;
  signal fu_F32_I32_CONVERTER_opc_reg : std_logic_vector(1 downto 0);
  signal fu_divf_in1t_load_reg : std_logic;
  signal fu_divf_in2_load_reg : std_logic;
  signal fu_BNN_OPS_in1t_load_reg : std_logic;
  signal fu_BNN_OPS_in2_load_reg : std_logic;
  signal fu_BNN_OPS_in3_load_reg : std_logic;
  signal fu_BNN_OPS_opc_reg : std_logic_vector(1 downto 0);
  signal fu_gcu_pc_load_reg : std_logic;
  signal fu_gcu_ra_load_reg : std_logic;
  signal fu_gcu_opc_reg : std_logic_vector(0 downto 0);

  -- RF control signals
  signal rf_RF_wr_load_reg : std_logic;
  signal rf_RF_wr_opc_reg : std_logic_vector(4 downto 0);
  signal rf_RF_rd_load_reg : std_logic;
  signal rf_RF_rd_opc_reg : std_logic_vector(4 downto 0);
  signal rf_BOOL_wr_load_reg : std_logic;
  signal rf_BOOL_wr_opc_reg : std_logic_vector(1 downto 0);
  signal rf_BOOL_rd_load_reg : std_logic;
  signal rf_BOOL_rd_opc_reg : std_logic_vector(1 downto 0);

  signal merged_glock_req : std_logic;
  signal pre_decode_merged_glock : std_logic;
  signal post_decode_merged_glock : std_logic;
  signal post_decode_merged_glock_r : std_logic;

  signal decode_fill_lock_reg : std_logic;
begin

  -- dismembering of instruction
  process (instructionword)
  begin --process
    move_B1 <= instructionword(43-1 downto 0);
    src_B1 <= instructionword(39 downto 7);
    dst_B1 <= instructionword(6 downto 0);
    grd_B1 <= instructionword(42 downto 40);
    move_B1_1 <= instructionword(86-1 downto 43);
    src_B1_1 <= instructionword(82 downto 50);
    dst_B1_1 <= instructionword(49 downto 43);
    grd_B1_1 <= instructionword(85 downto 83);
    move_B1_2 <= instructionword(129-1 downto 86);
    src_B1_2 <= instructionword(125 downto 93);
    dst_B1_2 <= instructionword(92 downto 86);
    grd_B1_2 <= instructionword(128 downto 126);

  end process;

  -- map control registers to outputs
  fu_FALU_in1_load <= fu_FALU_in1_load_reg;
  fu_FALU_in2t_load <= fu_FALU_in2t_load_reg;
  fu_FALU_in3_load <= fu_FALU_in3_load_reg;
  fu_FALU_opc <= fu_FALU_opc_reg;

  fu_LSU_in1t_load <= fu_LSU_in1t_load_reg;
  fu_LSU_in2_load <= fu_LSU_in2_load_reg;
  fu_LSU_opc <= fu_LSU_opc_reg;

  fu_LSU_inp_in1t_load <= fu_LSU_inp_in1t_load_reg;
  fu_LSU_inp_in2_load <= fu_LSU_inp_in2_load_reg;
  fu_LSU_inp_opc <= fu_LSU_inp_opc_reg;

  fu_ALU_in1t_load <= fu_ALU_in1t_load_reg;
  fu_ALU_in2_load <= fu_ALU_in2_load_reg;
  fu_ALU_opc <= fu_ALU_opc_reg;

  fu_STREAM_in1t_load <= fu_STREAM_in1t_load_reg;

  fu_F32_I32_CONVERTER_in1t_load <= fu_F32_I32_CONVERTER_in1t_load_reg;
  fu_F32_I32_CONVERTER_opc <= fu_F32_I32_CONVERTER_opc_reg;

  fu_divf_in1t_load <= fu_divf_in1t_load_reg;
  fu_divf_in2_load <= fu_divf_in2_load_reg;

  fu_BNN_OPS_in1t_load <= fu_BNN_OPS_in1t_load_reg;
  fu_BNN_OPS_in2_load <= fu_BNN_OPS_in2_load_reg;
  fu_BNN_OPS_in3_load <= fu_BNN_OPS_in3_load_reg;
  fu_BNN_OPS_opc <= fu_BNN_OPS_opc_reg;

  ra_load <= fu_gcu_ra_load_reg;
  pc_load <= fu_gcu_pc_load_reg;
  pc_opcode <= fu_gcu_opc_reg;
  rf_RF_wr_load <= rf_RF_wr_load_reg;
  rf_RF_wr_opc <= rf_RF_wr_opc_reg;
  rf_RF_rd_load <= rf_RF_rd_load_reg;
  rf_RF_rd_opc <= rf_RF_rd_opc_reg;
  rf_BOOL_wr_load <= rf_BOOL_wr_load_reg;
  rf_BOOL_wr_opc <= rf_BOOL_wr_opc_reg;
  rf_BOOL_rd_load <= rf_BOOL_rd_load_reg;
  rf_BOOL_rd_opc <= rf_BOOL_rd_opc_reg;
  iu_IMM1_out1_read_opc <= "0";
  iu_IMM1_write_opc <= "0";
  socket_RF_i1_bus_cntrl <= socket_RF_i1_bus_cntrl_reg;
  socket_RF_o1_bus_cntrl <= socket_RF_o1_bus_cntrl_reg;
  socket_bool_i1_bus_cntrl <= socket_bool_i1_bus_cntrl_reg;
  socket_bool_o1_bus_cntrl <= socket_bool_o1_bus_cntrl_reg;
  socket_gcu_i1_bus_cntrl <= socket_gcu_i1_bus_cntrl_reg;
  socket_gcu_i2_bus_cntrl <= socket_gcu_i2_bus_cntrl_reg;
  socket_gcu_o1_bus_cntrl <= socket_gcu_o1_bus_cntrl_reg;
  socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl <= socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_reg;
  socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl <= socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_reg;
  socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl <= socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_reg;
  socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl <= socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_reg;
  socket_LSU_i1_bus_cntrl <= socket_LSU_i1_bus_cntrl_reg;
  socket_LSU_o1_bus_cntrl <= socket_LSU_o1_bus_cntrl_reg;
  socket_LSU_i2_bus_cntrl <= socket_LSU_i2_bus_cntrl_reg;
  socket_LSU_inp_i1_bus_cntrl <= socket_LSU_inp_i1_bus_cntrl_reg;
  socket_LSU_inp_o1_bus_cntrl <= socket_LSU_inp_o1_bus_cntrl_reg;
  socket_LSU_inp_i2_bus_cntrl <= socket_LSU_inp_i2_bus_cntrl_reg;
  socket_ALU_i3_bus_cntrl <= socket_ALU_i3_bus_cntrl_reg;
  socket_ALU_o2_bus_cntrl <= socket_ALU_o2_bus_cntrl_reg;
  socket_ALU_i4_bus_cntrl <= socket_ALU_i4_bus_cntrl_reg;
  socket_STREAM_i2_bus_cntrl <= socket_STREAM_i2_bus_cntrl_reg;
  socket_cfi_cfiu_cif_cifu_i1_bus_cntrl <= socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_reg;
  socket_cfi_cfiu_cif_cifu_o1_bus_cntrl <= socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_reg;
  socket_divf_i1_bus_cntrl <= socket_divf_i1_bus_cntrl_reg;
  socket_divf_i2_bus_cntrl <= socket_divf_i2_bus_cntrl_reg;
  socket_divf_o1_bus_cntrl <= socket_divf_o1_bus_cntrl_reg;
  socket_IMM1_o1_bus_cntrl <= socket_IMM1_o1_bus_cntrl_reg;
  socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl <= socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_reg;
  socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl <= socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_reg;
  socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl <= socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_reg;
  socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl <= socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_reg;
  simm_cntrl_B1 <= simm_cntrl_B1_reg;
  simm_B1 <= simm_B1_reg;
  simm_cntrl_B1_1 <= simm_cntrl_B1_1_reg;
  simm_B1_1 <= simm_B1_1_reg;
  simm_cntrl_B1_2 <= simm_cntrl_B1_2_reg;
  simm_B1_2 <= simm_B1_2_reg;

  -- generate signal squash_B1
  process (grd_B1, move_B1, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_B1(42 downto 40))) = 5) then
      squash_B1 <= '1';
    else
      sel := conv_integer(unsigned(grd_B1));
      case sel is
        when 1 =>
          squash_B1 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_B1 <= rf_guard_BOOL_0;
        when 3 =>
          squash_B1 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_B1 <= rf_guard_BOOL_1;
        when others =>
          squash_B1 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_B1_1
  process (grd_B1_1, move_B1_1, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_B1_1(42 downto 40))) = 5) then
      squash_B1_1 <= '1';
    else
      sel := conv_integer(unsigned(grd_B1_1));
      case sel is
        when 1 =>
          squash_B1_1 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_B1_1 <= rf_guard_BOOL_0;
        when 3 =>
          squash_B1_1 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_B1_1 <= rf_guard_BOOL_1;
        when others =>
          squash_B1_1 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_B1_2
  process (grd_B1_2, move_B1_2, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_B1_2(42 downto 40))) = 5) then
      squash_B1_2 <= '1';
    else
      sel := conv_integer(unsigned(grd_B1_2));
      case sel is
        when 1 =>
          squash_B1_2 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_B1_2 <= rf_guard_BOOL_0;
        when 3 =>
          squash_B1_2 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_B1_2 <= rf_guard_BOOL_1;
        when others =>
          squash_B1_2 <= '0';
      end case;
    end if;
  end process;




  -- main decoding process
  process (clk, rstx)
  begin
    if (rstx = '0') then
      socket_RF_i1_bus_cntrl_reg <= (others => '0');
      socket_RF_o1_bus_cntrl_reg <= (others => '0');
      socket_bool_i1_bus_cntrl_reg <= (others => '0');
      socket_bool_o1_bus_cntrl_reg <= (others => '0');
      socket_gcu_i1_bus_cntrl_reg <= (others => '0');
      socket_gcu_i2_bus_cntrl_reg <= (others => '0');
      socket_gcu_o1_bus_cntrl_reg <= (others => '0');
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_reg <= (others => '0');
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_reg <= (others => '0');
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_reg <= (others => '0');
      socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_reg <= (others => '0');
      socket_LSU_i1_bus_cntrl_reg <= (others => '0');
      socket_LSU_o1_bus_cntrl_reg <= (others => '0');
      socket_LSU_i2_bus_cntrl_reg <= (others => '0');
      socket_LSU_inp_i1_bus_cntrl_reg <= (others => '0');
      socket_LSU_inp_o1_bus_cntrl_reg <= (others => '0');
      socket_LSU_inp_i2_bus_cntrl_reg <= (others => '0');
      socket_ALU_i3_bus_cntrl_reg <= (others => '0');
      socket_ALU_o2_bus_cntrl_reg <= (others => '0');
      socket_ALU_i4_bus_cntrl_reg <= (others => '0');
      socket_STREAM_i2_bus_cntrl_reg <= (others => '0');
      socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_reg <= (others => '0');
      socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_reg <= (others => '0');
      socket_divf_i1_bus_cntrl_reg <= (others => '0');
      socket_divf_i2_bus_cntrl_reg <= (others => '0');
      socket_divf_o1_bus_cntrl_reg <= (others => '0');
      socket_IMM1_o1_bus_cntrl_reg <= (others => '0');
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_reg <= (others => '0');
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_reg <= (others => '0');
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_reg <= (others => '0');
      socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_reg <= (others => '0');
      simm_B1_reg <= (others => '0');
      simm_cntrl_B1_reg <= (others => '0');
      simm_B1_1_reg <= (others => '0');
      simm_cntrl_B1_1_reg <= (others => '0');
      simm_B1_2_reg <= (others => '0');
      simm_cntrl_B1_2_reg <= (others => '0');
      fu_FALU_opc_reg <= (others => '0');
      fu_LSU_opc_reg <= (others => '0');
      fu_LSU_inp_opc_reg <= (others => '0');
      fu_ALU_opc_reg <= (others => '0');
      fu_F32_I32_CONVERTER_opc_reg <= (others => '0');
      fu_BNN_OPS_opc_reg <= (others => '0');
      fu_gcu_opc_reg <= (others => '0');
      rf_RF_wr_opc_reg <= (others => '0');
      rf_RF_rd_opc_reg <= (others => '0');
      rf_BOOL_wr_opc_reg <= (others => '0');
      rf_BOOL_rd_opc_reg <= (others => '0');

      fu_FALU_in1_load_reg <= '0';
      fu_FALU_in2t_load_reg <= '0';
      fu_FALU_in3_load_reg <= '0';
      fu_LSU_in1t_load_reg <= '0';
      fu_LSU_in2_load_reg <= '0';
      fu_LSU_inp_in1t_load_reg <= '0';
      fu_LSU_inp_in2_load_reg <= '0';
      fu_ALU_in1t_load_reg <= '0';
      fu_ALU_in2_load_reg <= '0';
      fu_STREAM_in1t_load_reg <= '0';
      fu_F32_I32_CONVERTER_in1t_load_reg <= '0';
      fu_divf_in1t_load_reg <= '0';
      fu_divf_in2_load_reg <= '0';
      fu_BNN_OPS_in1t_load_reg <= '0';
      fu_BNN_OPS_in2_load_reg <= '0';
      fu_BNN_OPS_in3_load_reg <= '0';
      fu_gcu_pc_load_reg <= '0';
      fu_gcu_ra_load_reg <= '0';
      rf_RF_wr_load_reg <= '0';
      rf_RF_rd_load_reg <= '0';
      rf_BOOL_wr_load_reg <= '0';
      rf_BOOL_rd_load_reg <= '0';
      iu_IMM1_out1_read_load <= '0';


    elsif (clk'event and clk = '1') then -- rising clock edge
    if (pre_decode_merged_glock = '0') then

        -- bus control signals for output mux
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 16) then
          socket_RF_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_RF_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 16) then
          socket_RF_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_RF_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 16) then
          socket_RF_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_RF_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 17) then
          socket_bool_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_bool_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 17) then
          socket_bool_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_bool_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 17) then
          socket_bool_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_bool_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 18) then
          socket_gcu_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_gcu_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 18) then
          socket_gcu_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_gcu_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 18) then
          socket_gcu_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_gcu_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 19) then
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 19) then
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 19) then
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 20) then
          socket_LSU_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_LSU_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 20) then
          socket_LSU_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_LSU_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 20) then
          socket_LSU_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_LSU_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 21) then
          socket_LSU_inp_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_LSU_inp_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 21) then
          socket_LSU_inp_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_LSU_inp_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 21) then
          socket_LSU_inp_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_LSU_inp_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 22) then
          socket_ALU_o2_bus_cntrl_reg(1) <= '1';
        else
          socket_ALU_o2_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 22) then
          socket_ALU_o2_bus_cntrl_reg(2) <= '1';
        else
          socket_ALU_o2_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 22) then
          socket_ALU_o2_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o2_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 23) then
          socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 23) then
          socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 23) then
          socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_cfi_cfiu_cif_cifu_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 24) then
          socket_divf_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_divf_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 24) then
          socket_divf_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_divf_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 24) then
          socket_divf_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_divf_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 25) then
          socket_IMM1_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_IMM1_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 25) then
          socket_IMM1_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_IMM1_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 25) then
          socket_IMM1_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_IMM1_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 26) then
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 26) then
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 26) then
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 32))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(31 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 32))) = 0) then
          simm_cntrl_B1_1_reg(0) <= '1';
        simm_B1_1_reg <= tce_ext(src_B1_1(31 downto 0), simm_B1_1_reg'length);
        else
          simm_cntrl_B1_1_reg(0) <= '0';
        end if;
        if (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 32))) = 0) then
          simm_cntrl_B1_2_reg(0) <= '1';
        simm_B1_2_reg <= tce_ext(src_B1_2(31 downto 0), simm_B1_2_reg'length);
        else
          simm_cntrl_B1_2_reg(0) <= '0';
        end if;
        -- data control signals for output sockets connected to FUs
        -- control signals for RF read ports
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 16 and true) then
          rf_RF_rd_load_reg <= '1';
          rf_RF_rd_opc_reg <= tce_ext(src_B1_1(4 downto 0), rf_RF_rd_opc_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 16 and true) then
          rf_RF_rd_load_reg <= '1';
          rf_RF_rd_opc_reg <= tce_ext(src_B1_2(4 downto 0), rf_RF_rd_opc_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 16 and true) then
          rf_RF_rd_load_reg <= '1';
          rf_RF_rd_opc_reg <= tce_ext(src_B1(4 downto 0), rf_RF_rd_opc_reg'length);
        else
          rf_RF_rd_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 17 and true) then
          rf_BOOL_rd_load_reg <= '1';
          rf_BOOL_rd_opc_reg <= tce_ext(src_B1_1(1 downto 0), rf_BOOL_rd_opc_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 17 and true) then
          rf_BOOL_rd_load_reg <= '1';
          rf_BOOL_rd_opc_reg <= tce_ext(src_B1_2(1 downto 0), rf_BOOL_rd_opc_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 17 and true) then
          rf_BOOL_rd_load_reg <= '1';
          rf_BOOL_rd_opc_reg <= tce_ext(src_B1(1 downto 0), rf_BOOL_rd_opc_reg'length);
        else
          rf_BOOL_rd_load_reg <= '0';
        end if;

        --control signals for IU read ports
        -- control signals for IU read ports
        if (squash_B1_1 = '0' and conv_integer(unsigned(src_B1_1(32 downto 28))) = 25) then
          iu_IMM1_out1_read_load <= '1';
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(src_B1_2(32 downto 28))) = 25) then
          iu_IMM1_out1_read_load <= '1';
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(32 downto 28))) = 25) then
          iu_IMM1_out1_read_load <= '1';
        else
          iu_IMM1_out1_read_load <= '0';
        end if;

        -- control signals for FU inputs
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 95) then
          fu_FALU_in1_load_reg <= '1';
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 95) then
          fu_FALU_in1_load_reg <= '1';
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 95) then
          fu_FALU_in1_load_reg <= '1';
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i1_bus_cntrl_reg'length);
        else
          fu_FALU_in1_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 4))) = 2) then
          fu_FALU_in2t_load_reg <= '1';
          fu_FALU_opc_reg <= dst_B1_1(3 downto 0);
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 4))) = 2) then
          fu_FALU_in2t_load_reg <= '1';
          fu_FALU_opc_reg <= dst_B1_2(3 downto 0);
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 4))) = 2) then
          fu_FALU_in2t_load_reg <= '1';
          fu_FALU_opc_reg <= dst_B1(3 downto 0);
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i2_bus_cntrl_reg'length);
        else
          fu_FALU_in2t_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 96) then
          fu_FALU_in3_load_reg <= '1';
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_reg <= conv_std_logic_vector(1, socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 96) then
          fu_FALU_in3_load_reg <= '1';
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_reg <= conv_std_logic_vector(2, socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 96) then
          fu_FALU_in3_load_reg <= '1';
          socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_reg <= conv_std_logic_vector(0, socket_macf_addf_subf_mulf_eqf_shr_shl_gtf_ltf_add_mul_mac_sub_eq_gt_lt_i3_bus_cntrl_reg'length);
        else
          fu_FALU_in3_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 3))) = 8) then
          fu_LSU_in1t_load_reg <= '1';
          fu_LSU_opc_reg <= dst_B1_1(2 downto 0);
          socket_LSU_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_LSU_i1_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 3))) = 8) then
          fu_LSU_in1t_load_reg <= '1';
          fu_LSU_opc_reg <= dst_B1_2(2 downto 0);
          socket_LSU_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_LSU_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 3))) = 8) then
          fu_LSU_in1t_load_reg <= '1';
          fu_LSU_opc_reg <= dst_B1(2 downto 0);
          socket_LSU_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_LSU_i1_bus_cntrl_reg'length);
        else
          fu_LSU_in1t_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 97) then
          fu_LSU_in2_load_reg <= '1';
          socket_LSU_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_LSU_i2_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 97) then
          fu_LSU_in2_load_reg <= '1';
          socket_LSU_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_LSU_i2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 97) then
          fu_LSU_in2_load_reg <= '1';
          socket_LSU_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_LSU_i2_bus_cntrl_reg'length);
        else
          fu_LSU_in2_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 3))) = 9) then
          fu_LSU_inp_in1t_load_reg <= '1';
          fu_LSU_inp_opc_reg <= dst_B1_1(2 downto 0);
          socket_LSU_inp_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_LSU_inp_i1_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 3))) = 9) then
          fu_LSU_inp_in1t_load_reg <= '1';
          fu_LSU_inp_opc_reg <= dst_B1_2(2 downto 0);
          socket_LSU_inp_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_LSU_inp_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 3))) = 9) then
          fu_LSU_inp_in1t_load_reg <= '1';
          fu_LSU_inp_opc_reg <= dst_B1(2 downto 0);
          socket_LSU_inp_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_LSU_inp_i1_bus_cntrl_reg'length);
        else
          fu_LSU_inp_in1t_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 98) then
          fu_LSU_inp_in2_load_reg <= '1';
          socket_LSU_inp_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_LSU_inp_i2_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 98) then
          fu_LSU_inp_in2_load_reg <= '1';
          socket_LSU_inp_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_LSU_inp_i2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 98) then
          fu_LSU_inp_in2_load_reg <= '1';
          socket_LSU_inp_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_LSU_inp_i2_bus_cntrl_reg'length);
        else
          fu_LSU_inp_in2_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 4))) = 3) then
          fu_ALU_in1t_load_reg <= '1';
          fu_ALU_opc_reg <= dst_B1_1(3 downto 0);
          socket_ALU_i3_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i3_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 4))) = 3) then
          fu_ALU_in1t_load_reg <= '1';
          fu_ALU_opc_reg <= dst_B1_2(3 downto 0);
          socket_ALU_i3_bus_cntrl_reg <= conv_std_logic_vector(2, socket_ALU_i3_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 4))) = 3) then
          fu_ALU_in1t_load_reg <= '1';
          fu_ALU_opc_reg <= dst_B1(3 downto 0);
          socket_ALU_i3_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i3_bus_cntrl_reg'length);
        else
          fu_ALU_in1t_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 99) then
          fu_ALU_in2_load_reg <= '1';
          socket_ALU_i4_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i4_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 99) then
          fu_ALU_in2_load_reg <= '1';
          socket_ALU_i4_bus_cntrl_reg <= conv_std_logic_vector(2, socket_ALU_i4_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 99) then
          fu_ALU_in2_load_reg <= '1';
          socket_ALU_i4_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i4_bus_cntrl_reg'length);
        else
          fu_ALU_in2_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 100) then
          fu_STREAM_in1t_load_reg <= '1';
          socket_STREAM_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_STREAM_i2_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 100) then
          fu_STREAM_in1t_load_reg <= '1';
          socket_STREAM_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_STREAM_i2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 100) then
          fu_STREAM_in1t_load_reg <= '1';
          socket_STREAM_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_STREAM_i2_bus_cntrl_reg'length);
        else
          fu_STREAM_in1t_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 2))) = 21) then
          fu_F32_I32_CONVERTER_in1t_load_reg <= '1';
          fu_F32_I32_CONVERTER_opc_reg <= dst_B1_1(1 downto 0);
          socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 2))) = 21) then
          fu_F32_I32_CONVERTER_in1t_load_reg <= '1';
          fu_F32_I32_CONVERTER_opc_reg <= dst_B1_2(1 downto 0);
          socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 2))) = 21) then
          fu_F32_I32_CONVERTER_in1t_load_reg <= '1';
          fu_F32_I32_CONVERTER_opc_reg <= dst_B1(1 downto 0);
          socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_cfi_cfiu_cif_cifu_i1_bus_cntrl_reg'length);
        else
          fu_F32_I32_CONVERTER_in1t_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 101) then
          fu_divf_in1t_load_reg <= '1';
          socket_divf_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_divf_i1_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 101) then
          fu_divf_in1t_load_reg <= '1';
          socket_divf_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_divf_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 101) then
          fu_divf_in1t_load_reg <= '1';
          socket_divf_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_divf_i1_bus_cntrl_reg'length);
        else
          fu_divf_in1t_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 102) then
          fu_divf_in2_load_reg <= '1';
          socket_divf_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_divf_i2_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 102) then
          fu_divf_in2_load_reg <= '1';
          socket_divf_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_divf_i2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 102) then
          fu_divf_in2_load_reg <= '1';
          socket_divf_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_divf_i2_bus_cntrl_reg'length);
        else
          fu_divf_in2_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 2))) = 22) then
          fu_BNN_OPS_in1t_load_reg <= '1';
          fu_BNN_OPS_opc_reg <= dst_B1_1(1 downto 0);
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 2))) = 22) then
          fu_BNN_OPS_in1t_load_reg <= '1';
          fu_BNN_OPS_opc_reg <= dst_B1_2(1 downto 0);
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 2))) = 22) then
          fu_BNN_OPS_in1t_load_reg <= '1';
          fu_BNN_OPS_opc_reg <= dst_B1(1 downto 0);
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_popcount_popcountacc_xnorpopcntacc_set_bit_i1_bus_cntrl_reg'length);
        else
          fu_BNN_OPS_in1t_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 103) then
          fu_BNN_OPS_in2_load_reg <= '1';
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 103) then
          fu_BNN_OPS_in2_load_reg <= '1';
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 103) then
          fu_BNN_OPS_in2_load_reg <= '1';
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_popcount_popcountacc_xnorpopcntacc_set_bit_i2_bus_cntrl_reg'length);
        else
          fu_BNN_OPS_in2_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 104) then
          fu_BNN_OPS_in3_load_reg <= '1';
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_reg <= conv_std_logic_vector(1, socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 104) then
          fu_BNN_OPS_in3_load_reg <= '1';
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_reg <= conv_std_logic_vector(2, socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 104) then
          fu_BNN_OPS_in3_load_reg <= '1';
          socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_reg <= conv_std_logic_vector(0, socket_popcount_popcountacc_xnorpopcntacc_set_bit_i3_bus_cntrl_reg'length);
        else
          fu_BNN_OPS_in3_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 1))) = 46) then
          fu_gcu_pc_load_reg <= '1';
          fu_gcu_opc_reg <= dst_B1_1(0 downto 0);
          socket_gcu_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_gcu_i1_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 1))) = 46) then
          fu_gcu_pc_load_reg <= '1';
          fu_gcu_opc_reg <= dst_B1_2(0 downto 0);
          socket_gcu_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_gcu_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 1))) = 46) then
          fu_gcu_pc_load_reg <= '1';
          fu_gcu_opc_reg <= dst_B1(0 downto 0);
          socket_gcu_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_gcu_i1_bus_cntrl_reg'length);
        else
          fu_gcu_pc_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 0))) = 94) then
          fu_gcu_ra_load_reg <= '1';
          socket_gcu_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_gcu_i2_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 0))) = 94) then
          fu_gcu_ra_load_reg <= '1';
          socket_gcu_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_gcu_i2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 0))) = 94) then
          fu_gcu_ra_load_reg <= '1';
          socket_gcu_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_gcu_i2_bus_cntrl_reg'length);
        else
          fu_gcu_ra_load_reg <= '0';
        end if;
        -- control signals for RF inputs
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 5))) = 0 and true) then
          rf_RF_wr_load_reg <= '1';
          rf_RF_wr_opc_reg <= dst_B1_1(4 downto 0);
          socket_RF_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_RF_i1_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 5))) = 0 and true) then
          rf_RF_wr_load_reg <= '1';
          rf_RF_wr_opc_reg <= dst_B1_2(4 downto 0);
          socket_RF_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_RF_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 5))) = 0 and true) then
          rf_RF_wr_load_reg <= '1';
          rf_RF_wr_opc_reg <= dst_B1(4 downto 0);
          socket_RF_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_RF_i1_bus_cntrl_reg'length);
        else
          rf_RF_wr_load_reg <= '0';
        end if;
        if (squash_B1_1 = '0' and conv_integer(unsigned(dst_B1_1(6 downto 2))) = 20 and true) then
          rf_BOOL_wr_load_reg <= '1';
          rf_BOOL_wr_opc_reg <= dst_B1_1(1 downto 0);
          socket_bool_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_bool_i1_bus_cntrl_reg'length);
        elsif (squash_B1_2 = '0' and conv_integer(unsigned(dst_B1_2(6 downto 2))) = 20 and true) then
          rf_BOOL_wr_load_reg <= '1';
          rf_BOOL_wr_opc_reg <= dst_B1_2(1 downto 0);
          socket_bool_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_bool_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 2))) = 20 and true) then
          rf_BOOL_wr_load_reg <= '1';
          rf_BOOL_wr_opc_reg <= dst_B1(1 downto 0);
          socket_bool_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_bool_i1_bus_cntrl_reg'length);
        else
          rf_BOOL_wr_load_reg <= '0';
        end if;
      end if;
    end if;
  end process;

  lock_reg_proc : process (clk, rstx)
  begin
    if (rstx = '0') then
      -- Locked during active reset      post_decode_merged_glock_r <= '1';
    elsif (clk'event and clk = '1') then
      post_decode_merged_glock_r <= post_decode_merged_glock;
    end if;
  end process lock_reg_proc;

  lock_r <= merged_glock_req;
  merged_glock_req <= '0';
  pre_decode_merged_glock <= lock;
  post_decode_merged_glock <= pre_decode_merged_glock or decode_fill_lock_reg;
  locked <= post_decode_merged_glock_r;
  glock(0) <= post_decode_merged_glock; -- to FALU
  glock(1) <= post_decode_merged_glock; -- to LSU
  glock(2) <= post_decode_merged_glock; -- to LSU_inp
  glock(3) <= post_decode_merged_glock; -- to ALU
  glock(4) <= post_decode_merged_glock; -- to STREAM
  glock(5) <= post_decode_merged_glock; -- to F32_I32_CONVERTER
  glock(6) <= post_decode_merged_glock; -- to divf
  glock(7) <= post_decode_merged_glock; -- to BNN_OPS
  glock(8) <= post_decode_merged_glock; -- to RF
  glock(9) <= post_decode_merged_glock; -- to BOOL
  glock(10) <= post_decode_merged_glock; -- to IMM1
  glock(11) <= post_decode_merged_glock;

  decode_pipeline_fill_lock: process (clk, rstx)
  begin
    if rstx = '0' then
      decode_fill_lock_reg <= '1';
    elsif clk'event and clk = '1' then
      if lock = '0' then
        decode_fill_lock_reg <= '0';
      end if;
    end if;
  end process decode_pipeline_fill_lock;

end rtl_andor;
