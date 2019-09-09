library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tta_core_globals.all;
use work.tta_core_gcu_opcodes.all;
use work.tce_util.all;

entity tta_core_decoder is

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
    simm_B1 : out std_logic_vector(19 downto 0);
    simm_B2 : out std_logic_vector(3 downto 0);
    simm_B3 : out std_logic_vector(6 downto 0);
    socket_ALU_i1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_i2_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_LSU1_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_LSU1_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_RF32A_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_vRF1024_i1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_add_mul_sub_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_add_i1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_RF32B_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_FMA_i1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_vOPS_i1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_vOPS_i2_bus_cntrl : out std_logic_vector(0 downto 0);
    B1_src_sel : out std_logic_vector(2 downto 0);
    B2_src_sel : out std_logic_vector(3 downto 0);
    B3_src_sel : out std_logic_vector(2 downto 0);
    B5_src_sel : out std_logic_vector(1 downto 0);
    vB1024B_src_sel : out std_logic_vector(1 downto 0);
    vB1024c_src_sel : out std_logic_vector(1 downto 0);
    fu_ALU_in1t_load : out std_logic;
    fu_ALU_in2_load : out std_logic;
    fu_ALU_opc : out std_logic_vector(3 downto 0);
    fu_FMA_ACT_in1t_load : out std_logic;
    fu_FMA_ACT_in2_load : out std_logic;
    fu_FMA_ACT_in3_load : out std_logic;
    fu_FMA_ACT_opc : out std_logic_vector(2 downto 0);
    fu_vOPS_in1t_load : out std_logic;
    fu_vOPS_in2_load : out std_logic;
    fu_vOPS_in3_load : out std_logic;
    fu_vOPS_opc : out std_logic_vector(2 downto 0);
    fu_dmem_LSU_in1t_load : out std_logic;
    fu_dmem_LSU_in2_load : out std_logic;
    fu_dmem_LSU_opc : out std_logic_vector(3 downto 0);
    fu_DMA_in1t_load : out std_logic;
    fu_DMA_in2_load : out std_logic;
    fu_DMA_in3_load : out std_logic;
    fu_DMA_opc : out std_logic_vector(1 downto 0);
    fu_add_mul_sub_in1t_load : out std_logic;
    fu_add_mul_sub_in2_load : out std_logic;
    fu_add_mul_sub_opc : out std_logic_vector(1 downto 0);
    fu_add_in1t_load : out std_logic;
    fu_add_in2_load : out std_logic;
    rf_RF_BOOL_rd_load : out std_logic;
    rf_RF_BOOL_rd_opc : out std_logic_vector(0 downto 0);
    rf_RF_BOOL_wr_load : out std_logic;
    rf_RF_BOOL_wr_opc : out std_logic_vector(0 downto 0);
    rf_RF32A_rd_load : out std_logic;
    rf_RF32A_rd_opc : out std_logic_vector(2 downto 0);
    rf_RF32A_wr_load : out std_logic;
    rf_RF32A_wr_opc : out std_logic_vector(2 downto 0);
    rf_RF32B_rd_load : out std_logic;
    rf_RF32B_rd_opc : out std_logic_vector(3 downto 0);
    rf_RF32B_wr_load : out std_logic;
    rf_RF32B_wr_opc : out std_logic_vector(3 downto 0);
    rf_vRF1024_rd_load : out std_logic;
    rf_vRF1024_rd_opc : out std_logic_vector(1 downto 0);
    rf_vRF1024_wr_load : out std_logic;
    rf_vRF1024_wr_opc : out std_logic_vector(1 downto 0);
    iu_IMM_out1_read_load : out std_logic;
    iu_IMM_out1_read_opc : out std_logic_vector(0 downto 0);
    iu_IMM_write : out std_logic_vector(31 downto 0);
    iu_IMM_write_load : out std_logic;
    iu_IMM_write_opc : out std_logic_vector(0 downto 0);
    rf_guard_RF_BOOL_0 : in std_logic;
    rf_guard_RF_BOOL_1 : in std_logic;
    lock_req : in std_logic_vector(4 downto 0);
    glock : out std_logic_vector(12 downto 0);
    db_tta_nreset : in std_logic);

end tta_core_decoder;

architecture rtl_andor of tta_core_decoder is

  -- signals for source, destination and guard fields
  signal move_B1 : std_logic_vector(31 downto 0);
  signal src_B1 : std_logic_vector(20 downto 0);
  signal dst_B1 : std_logic_vector(6 downto 0);
  signal grd_B1 : std_logic_vector(3 downto 0);
  signal move_B2 : std_logic_vector(11 downto 0);
  signal src_B2 : std_logic_vector(5 downto 0);
  signal dst_B2 : std_logic_vector(5 downto 0);
  signal move_B3 : std_logic_vector(13 downto 0);
  signal src_B3 : std_logic_vector(7 downto 0);
  signal dst_B3 : std_logic_vector(5 downto 0);
  signal move_B4 : std_logic_vector(2 downto 0);
  signal dst_B4 : std_logic_vector(2 downto 0);
  signal move_B5 : std_logic_vector(8 downto 0);
  signal src_B5 : std_logic_vector(3 downto 0);
  signal dst_B5 : std_logic_vector(4 downto 0);
  signal move_vB1024B : std_logic_vector(7 downto 0);
  signal src_vB1024B : std_logic_vector(2 downto 0);
  signal dst_vB1024B : std_logic_vector(4 downto 0);
  signal move_vB1024c : std_logic_vector(5 downto 0);
  signal src_vB1024c : std_logic_vector(2 downto 0);
  signal dst_vB1024c : std_logic_vector(2 downto 0);

  -- signals for dedicated immediate slots

  -- signal for long immediate tag
  signal limm_tag : std_logic_vector(0 downto 0);

  -- squash signals
  signal squash_B1 : std_logic;
  signal squash_B2 : std_logic;
  signal squash_B3 : std_logic;
  signal squash_B4 : std_logic;
  signal squash_B5 : std_logic;
  signal squash_vB1024B : std_logic;
  signal squash_vB1024c : std_logic;

  -- socket control signals
  signal socket_ALU_i1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_ALU_i2_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_LSU1_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_LSU1_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_LSU1_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_IMM_o1_bus_cntrl_reg : std_logic_vector(3 downto 0);
  signal socket_RF_BOOL_o1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_RF32A_o1_bus_cntrl_reg : std_logic_vector(3 downto 0);
  signal socket_RF32A_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_vRF1024_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_vRF1024_i1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_gcu_o1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_LSU1_o2_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_dma_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_add_mul_sub_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_add_mul_sub_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_add_i1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_add_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_RF32B_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_RF32B_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_FMA_i1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_FMA_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_vOPS_i1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_vOPS_i2_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_vOPS_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal simm_B1_reg : std_logic_vector(19 downto 0);
  signal B1_src_sel_reg : std_logic_vector(2 downto 0);
  signal simm_B2_reg : std_logic_vector(3 downto 0);
  signal B2_src_sel_reg : std_logic_vector(3 downto 0);
  signal simm_B3_reg : std_logic_vector(6 downto 0);
  signal B3_src_sel_reg : std_logic_vector(2 downto 0);
  signal B5_src_sel_reg : std_logic_vector(1 downto 0);
  signal vB1024B_src_sel_reg : std_logic_vector(1 downto 0);
  signal vB1024c_src_sel_reg : std_logic_vector(1 downto 0);

  -- FU control signals
  signal fu_ALU_in1t_load_reg : std_logic;
  signal fu_ALU_in2_load_reg : std_logic;
  signal fu_ALU_opc_reg : std_logic_vector(3 downto 0);
  signal fu_FMA_ACT_in1t_load_reg : std_logic;
  signal fu_FMA_ACT_in2_load_reg : std_logic;
  signal fu_FMA_ACT_in3_load_reg : std_logic;
  signal fu_FMA_ACT_opc_reg : std_logic_vector(2 downto 0);
  signal fu_vOPS_in1t_load_reg : std_logic;
  signal fu_vOPS_in2_load_reg : std_logic;
  signal fu_vOPS_in3_load_reg : std_logic;
  signal fu_vOPS_opc_reg : std_logic_vector(2 downto 0);
  signal fu_dmem_LSU_in1t_load_reg : std_logic;
  signal fu_dmem_LSU_in2_load_reg : std_logic;
  signal fu_dmem_LSU_opc_reg : std_logic_vector(3 downto 0);
  signal fu_DMA_in1t_load_reg : std_logic;
  signal fu_DMA_in2_load_reg : std_logic;
  signal fu_DMA_in3_load_reg : std_logic;
  signal fu_DMA_opc_reg : std_logic_vector(1 downto 0);
  signal fu_add_mul_sub_in1t_load_reg : std_logic;
  signal fu_add_mul_sub_in2_load_reg : std_logic;
  signal fu_add_mul_sub_opc_reg : std_logic_vector(1 downto 0);
  signal fu_add_in1t_load_reg : std_logic;
  signal fu_add_in2_load_reg : std_logic;
  signal fu_gcu_pc_load_reg : std_logic;
  signal fu_gcu_ra_load_reg : std_logic;
  signal fu_gcu_opc_reg : std_logic_vector(0 downto 0);

  -- RF control signals
  signal rf_RF_BOOL_rd_load_reg : std_logic;
  signal rf_RF_BOOL_rd_opc_reg : std_logic_vector(0 downto 0);
  signal rf_RF_BOOL_wr_load_reg : std_logic;
  signal rf_RF_BOOL_wr_opc_reg : std_logic_vector(0 downto 0);
  signal rf_RF32A_rd_load_reg : std_logic;
  signal rf_RF32A_rd_opc_reg : std_logic_vector(2 downto 0);
  signal rf_RF32A_wr_load_reg : std_logic;
  signal rf_RF32A_wr_opc_reg : std_logic_vector(2 downto 0);
  signal rf_RF32B_rd_load_reg : std_logic;
  signal rf_RF32B_rd_opc_reg : std_logic_vector(3 downto 0);
  signal rf_RF32B_wr_load_reg : std_logic;
  signal rf_RF32B_wr_opc_reg : std_logic_vector(3 downto 0);
  signal rf_vRF1024_rd_load_reg : std_logic;
  signal rf_vRF1024_rd_opc_reg : std_logic_vector(1 downto 0);
  signal rf_vRF1024_wr_load_reg : std_logic;
  signal rf_vRF1024_wr_opc_reg : std_logic_vector(1 downto 0);

  signal merged_glock_req : std_logic;
  signal pre_decode_merged_glock : std_logic;
  signal post_decode_merged_glock : std_logic;
  signal post_decode_merged_glock_r : std_logic;

  signal decode_fill_lock_reg : std_logic;
begin

  -- dismembering of instruction
  process (instructionword)
  begin --process
    move_B1 <= instructionword(32-1 downto 0);
    src_B1 <= instructionword(27 downto 7);
    dst_B1 <= instructionword(6 downto 0);
    grd_B1 <= instructionword(31 downto 28);
    move_B2 <= instructionword(44-1 downto 32);
    src_B2 <= instructionword(43 downto 38);
    dst_B2 <= instructionword(37 downto 32);
    move_B3 <= instructionword(58-1 downto 44);
    src_B3 <= instructionword(57 downto 50);
    dst_B3 <= instructionword(49 downto 44);
    move_B4 <= instructionword(61-1 downto 58);
    dst_B4 <= instructionword(60 downto 58);
    move_B5 <= instructionword(70-1 downto 61);
    src_B5 <= instructionword(69 downto 66);
    dst_B5 <= instructionword(65 downto 61);
    move_vB1024B <= instructionword(78-1 downto 70);
    src_vB1024B <= instructionword(77 downto 75);
    dst_vB1024B <= instructionword(74 downto 70);
    move_vB1024c <= instructionword(84-1 downto 78);
    src_vB1024c <= instructionword(83 downto 81);
    dst_vB1024c <= instructionword(80 downto 78);

    limm_tag <= instructionword(84 downto 84);
  end process;

  -- map control registers to outputs
  fu_ALU_in1t_load <= fu_ALU_in1t_load_reg;
  fu_ALU_in2_load <= fu_ALU_in2_load_reg;
  fu_ALU_opc <= fu_ALU_opc_reg;

  fu_FMA_ACT_in1t_load <= fu_FMA_ACT_in1t_load_reg;
  fu_FMA_ACT_in2_load <= fu_FMA_ACT_in2_load_reg;
  fu_FMA_ACT_in3_load <= fu_FMA_ACT_in3_load_reg;
  fu_FMA_ACT_opc <= fu_FMA_ACT_opc_reg;

  fu_vOPS_in1t_load <= fu_vOPS_in1t_load_reg;
  fu_vOPS_in2_load <= fu_vOPS_in2_load_reg;
  fu_vOPS_in3_load <= fu_vOPS_in3_load_reg;
  fu_vOPS_opc <= fu_vOPS_opc_reg;

  fu_dmem_LSU_in1t_load <= fu_dmem_LSU_in1t_load_reg;
  fu_dmem_LSU_in2_load <= fu_dmem_LSU_in2_load_reg;
  fu_dmem_LSU_opc <= fu_dmem_LSU_opc_reg;

  fu_DMA_in1t_load <= fu_DMA_in1t_load_reg;
  fu_DMA_in2_load <= fu_DMA_in2_load_reg;
  fu_DMA_in3_load <= fu_DMA_in3_load_reg;
  fu_DMA_opc <= fu_DMA_opc_reg;

  fu_add_mul_sub_in1t_load <= fu_add_mul_sub_in1t_load_reg;
  fu_add_mul_sub_in2_load <= fu_add_mul_sub_in2_load_reg;
  fu_add_mul_sub_opc <= fu_add_mul_sub_opc_reg;

  fu_add_in1t_load <= fu_add_in1t_load_reg;
  fu_add_in2_load <= fu_add_in2_load_reg;

  ra_load <= fu_gcu_ra_load_reg;
  pc_load <= fu_gcu_pc_load_reg;
  pc_opcode <= fu_gcu_opc_reg;
  rf_RF_BOOL_rd_load <= rf_RF_BOOL_rd_load_reg;
  rf_RF_BOOL_rd_opc <= rf_RF_BOOL_rd_opc_reg;
  rf_RF_BOOL_wr_load <= rf_RF_BOOL_wr_load_reg;
  rf_RF_BOOL_wr_opc <= rf_RF_BOOL_wr_opc_reg;
  rf_RF32A_rd_load <= rf_RF32A_rd_load_reg;
  rf_RF32A_rd_opc <= rf_RF32A_rd_opc_reg;
  rf_RF32A_wr_load <= rf_RF32A_wr_load_reg;
  rf_RF32A_wr_opc <= rf_RF32A_wr_opc_reg;
  rf_RF32B_rd_load <= rf_RF32B_rd_load_reg;
  rf_RF32B_rd_opc <= rf_RF32B_rd_opc_reg;
  rf_RF32B_wr_load <= rf_RF32B_wr_load_reg;
  rf_RF32B_wr_opc <= rf_RF32B_wr_opc_reg;
  rf_vRF1024_rd_load <= rf_vRF1024_rd_load_reg;
  rf_vRF1024_rd_opc <= rf_vRF1024_rd_opc_reg;
  rf_vRF1024_wr_load <= rf_vRF1024_wr_load_reg;
  rf_vRF1024_wr_opc <= rf_vRF1024_wr_opc_reg;
  iu_IMM_out1_read_opc <= "0";
  iu_IMM_write_opc <= "0";
  socket_ALU_i1_bus_cntrl <= socket_ALU_i1_bus_cntrl_reg;
  socket_ALU_i2_bus_cntrl <= socket_ALU_i2_bus_cntrl_reg;
  socket_LSU1_i1_bus_cntrl <= socket_LSU1_i1_bus_cntrl_reg;
  socket_LSU1_i2_bus_cntrl <= socket_LSU1_i2_bus_cntrl_reg;
  socket_RF32A_i1_bus_cntrl <= socket_RF32A_i1_bus_cntrl_reg;
  socket_vRF1024_i1_bus_cntrl <= socket_vRF1024_i1_bus_cntrl_reg;
  socket_add_mul_sub_i1_bus_cntrl <= socket_add_mul_sub_i1_bus_cntrl_reg;
  socket_add_i1_bus_cntrl <= socket_add_i1_bus_cntrl_reg;
  socket_RF32B_i1_bus_cntrl <= socket_RF32B_i1_bus_cntrl_reg;
  socket_FMA_i1_bus_cntrl <= socket_FMA_i1_bus_cntrl_reg;
  socket_vOPS_i1_bus_cntrl <= socket_vOPS_i1_bus_cntrl_reg;
  socket_vOPS_i2_bus_cntrl <= socket_vOPS_i2_bus_cntrl_reg;
  B1_src_sel <= B1_src_sel_reg;
  B2_src_sel <= B2_src_sel_reg;
  B3_src_sel <= B3_src_sel_reg;
  B5_src_sel <= B5_src_sel_reg;
  vB1024B_src_sel <= vB1024B_src_sel_reg;
  vB1024c_src_sel <= vB1024c_src_sel_reg;
  simm_B1 <= simm_B1_reg;
  simm_B2 <= simm_B2_reg;
  simm_B3 <= simm_B3_reg;

  -- generate signal squash_B1
  process (grd_B1, limm_tag, move_B1, rf_guard_RF_BOOL_0, rf_guard_RF_BOOL_1)
    variable sel : integer;
  begin --process
    if (conv_integer(unsigned(limm_tag)) = 1) then
      squash_B1 <= '1';
    -- squash by move NOP encoding
    elsif (conv_integer(unsigned(move_B1(30 downto 28))) = 5) then
      squash_B1 <= '1';
    else
      sel := conv_integer(unsigned(grd_B1));
      case sel is
        when 1 =>
          squash_B1 <= not rf_guard_RF_BOOL_0;
        when 2 =>
          squash_B1 <= rf_guard_RF_BOOL_0;
        when 3 =>
          squash_B1 <= not rf_guard_RF_BOOL_1;
        when 4 =>
          squash_B1 <= rf_guard_RF_BOOL_1;
        when others =>
          squash_B1 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_B2
  process (move_B2)
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_B2(11 downto 7))) = 28) then
      squash_B2 <= '1';
    else
      squash_B2 <= '0';
    end if;
  end process;

  -- generate signal squash_B3
  process (move_B3)
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_B3(13 downto 10))) = 14) then
      squash_B3 <= '1';
    else
      squash_B3 <= '0';
    end if;
  end process;

  -- generate signal squash_B4
  process (move_B4)
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_B4(2 downto 0))) = 3) then
      squash_B4 <= '1';
    else
      squash_B4 <= '0';
    end if;
  end process;

  -- generate signal squash_B5
  process (move_B5)
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_B5(8 downto 6))) = 5) then
      squash_B5 <= '1';
    else
      squash_B5 <= '0';
    end if;
  end process;

  -- generate signal squash_vB1024B
  process (move_vB1024B)
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_vB1024B(7 downto 5))) = 5) then
      squash_vB1024B <= '1';
    else
      squash_vB1024B <= '0';
    end if;
  end process;

  -- generate signal squash_vB1024c
  process (move_vB1024c)
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_vB1024c(5 downto 3))) = 5) then
      squash_vB1024c <= '1';
    else
      squash_vB1024c <= '0';
    end if;
  end process;


  --long immediate write process
  process (clk)
  begin --process
    if (clk'event and clk = '1') then
      if (rstx = '0') then
        iu_IMM_write_load <= '0';
        iu_IMM_write <= (others => '0');
      elsif pre_decode_merged_glock = '0' then
        if (conv_integer(unsigned(limm_tag)) = 0) then
          iu_IMM_write_load <= '0';
          iu_IMM_write(31 downto 0) <= tce_sxt("0", 32);
        else
          iu_IMM_write(31 downto 0) <= tce_ext(instructionword(31 downto 0), 32);
          iu_IMM_write_load <= '1';
        end if;
      end if;
    end if;
  end process;


  -- main decoding process
  process (clk)
  begin
    if (clk'event and clk = '1') then
    if (rstx = '0') then
      socket_ALU_i1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i2_bus_cntrl_reg <= (others => '0');
      socket_LSU1_i1_bus_cntrl_reg <= (others => '0');
      socket_LSU1_i2_bus_cntrl_reg <= (others => '0');
      socket_LSU1_o1_bus_cntrl_reg <= (others => '0');
      socket_IMM_o1_bus_cntrl_reg <= (others => '0');
      socket_RF_BOOL_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32A_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32A_i1_bus_cntrl_reg <= (others => '0');
      socket_vRF1024_o1_bus_cntrl_reg <= (others => '0');
      socket_vRF1024_i1_bus_cntrl_reg <= (others => '0');
      socket_gcu_o1_bus_cntrl_reg <= (others => '0');
      socket_LSU1_o2_bus_cntrl_reg <= (others => '0');
      socket_dma_o1_bus_cntrl_reg <= (others => '0');
      socket_add_mul_sub_i1_bus_cntrl_reg <= (others => '0');
      socket_add_mul_sub_o1_bus_cntrl_reg <= (others => '0');
      socket_add_i1_bus_cntrl_reg <= (others => '0');
      socket_add_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32B_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32B_i1_bus_cntrl_reg <= (others => '0');
      socket_FMA_i1_bus_cntrl_reg <= (others => '0');
      socket_FMA_o1_bus_cntrl_reg <= (others => '0');
      socket_vOPS_i1_bus_cntrl_reg <= (others => '0');
      socket_vOPS_i2_bus_cntrl_reg <= (others => '0');
      socket_vOPS_o1_bus_cntrl_reg <= (others => '0');
      simm_B1_reg <= (others => '0');
      B1_src_sel_reg <= (others => '0');
      simm_B2_reg <= (others => '0');
      B2_src_sel_reg <= (others => '0');
      simm_B3_reg <= (others => '0');
      B3_src_sel_reg <= (others => '0');
      B5_src_sel_reg <= (others => '0');
      vB1024B_src_sel_reg <= (others => '0');
      vB1024c_src_sel_reg <= (others => '0');
      fu_ALU_opc_reg <= (others => '0');
      fu_FMA_ACT_opc_reg <= (others => '0');
      fu_vOPS_opc_reg <= (others => '0');
      fu_dmem_LSU_opc_reg <= (others => '0');
      fu_DMA_opc_reg <= (others => '0');
      fu_add_mul_sub_opc_reg <= (others => '0');
      fu_gcu_opc_reg <= (others => '0');
      rf_RF_BOOL_rd_opc_reg <= (others => '0');
      rf_RF_BOOL_wr_opc_reg <= (others => '0');
      rf_RF32A_rd_opc_reg <= (others => '0');
      rf_RF32A_wr_opc_reg <= (others => '0');
      rf_RF32B_rd_opc_reg <= (others => '0');
      rf_RF32B_wr_opc_reg <= (others => '0');
      rf_vRF1024_rd_opc_reg <= (others => '0');
      rf_vRF1024_wr_opc_reg <= (others => '0');

      fu_ALU_in1t_load_reg <= '0';
      fu_ALU_in2_load_reg <= '0';
      fu_FMA_ACT_in1t_load_reg <= '0';
      fu_FMA_ACT_in2_load_reg <= '0';
      fu_FMA_ACT_in3_load_reg <= '0';
      fu_vOPS_in1t_load_reg <= '0';
      fu_vOPS_in2_load_reg <= '0';
      fu_vOPS_in3_load_reg <= '0';
      fu_dmem_LSU_in1t_load_reg <= '0';
      fu_dmem_LSU_in2_load_reg <= '0';
      fu_DMA_in1t_load_reg <= '0';
      fu_DMA_in2_load_reg <= '0';
      fu_DMA_in3_load_reg <= '0';
      fu_add_mul_sub_in1t_load_reg <= '0';
      fu_add_mul_sub_in2_load_reg <= '0';
      fu_add_in1t_load_reg <= '0';
      fu_add_in2_load_reg <= '0';
      fu_gcu_pc_load_reg <= '0';
      fu_gcu_ra_load_reg <= '0';
      rf_RF_BOOL_rd_load_reg <= '0';
      rf_RF_BOOL_wr_load_reg <= '0';
      rf_RF32A_rd_load_reg <= '0';
      rf_RF32A_wr_load_reg <= '0';
      rf_RF32B_rd_load_reg <= '0';
      rf_RF32B_wr_load_reg <= '0';
      rf_vRF1024_rd_load_reg <= '0';
      rf_vRF1024_wr_load_reg <= '0';
      iu_IMM_out1_read_load <= '0';


    else
      if (db_tta_nreset = '0') then
      socket_ALU_i1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i2_bus_cntrl_reg <= (others => '0');
      socket_LSU1_i1_bus_cntrl_reg <= (others => '0');
      socket_LSU1_i2_bus_cntrl_reg <= (others => '0');
      socket_LSU1_o1_bus_cntrl_reg <= (others => '0');
      socket_IMM_o1_bus_cntrl_reg <= (others => '0');
      socket_RF_BOOL_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32A_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32A_i1_bus_cntrl_reg <= (others => '0');
      socket_vRF1024_o1_bus_cntrl_reg <= (others => '0');
      socket_vRF1024_i1_bus_cntrl_reg <= (others => '0');
      socket_gcu_o1_bus_cntrl_reg <= (others => '0');
      socket_LSU1_o2_bus_cntrl_reg <= (others => '0');
      socket_dma_o1_bus_cntrl_reg <= (others => '0');
      socket_add_mul_sub_i1_bus_cntrl_reg <= (others => '0');
      socket_add_mul_sub_o1_bus_cntrl_reg <= (others => '0');
      socket_add_i1_bus_cntrl_reg <= (others => '0');
      socket_add_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32B_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32B_i1_bus_cntrl_reg <= (others => '0');
      socket_FMA_i1_bus_cntrl_reg <= (others => '0');
      socket_FMA_o1_bus_cntrl_reg <= (others => '0');
      socket_vOPS_i1_bus_cntrl_reg <= (others => '0');
      socket_vOPS_i2_bus_cntrl_reg <= (others => '0');
      socket_vOPS_o1_bus_cntrl_reg <= (others => '0');
      simm_B1_reg <= (others => '0');
      B1_src_sel_reg <= (others => '0');
      simm_B2_reg <= (others => '0');
      B2_src_sel_reg <= (others => '0');
      simm_B3_reg <= (others => '0');
      B3_src_sel_reg <= (others => '0');
      B5_src_sel_reg <= (others => '0');
      vB1024B_src_sel_reg <= (others => '0');
      vB1024c_src_sel_reg <= (others => '0');
      fu_ALU_opc_reg <= (others => '0');
      fu_FMA_ACT_opc_reg <= (others => '0');
      fu_vOPS_opc_reg <= (others => '0');
      fu_dmem_LSU_opc_reg <= (others => '0');
      fu_DMA_opc_reg <= (others => '0');
      fu_add_mul_sub_opc_reg <= (others => '0');
      fu_gcu_opc_reg <= (others => '0');
      rf_RF_BOOL_rd_opc_reg <= (others => '0');
      rf_RF_BOOL_wr_opc_reg <= (others => '0');
      rf_RF32A_rd_opc_reg <= (others => '0');
      rf_RF32A_wr_opc_reg <= (others => '0');
      rf_RF32B_rd_opc_reg <= (others => '0');
      rf_RF32B_wr_opc_reg <= (others => '0');
      rf_vRF1024_rd_opc_reg <= (others => '0');
      rf_vRF1024_wr_opc_reg <= (others => '0');

      fu_ALU_in1t_load_reg <= '0';
      fu_ALU_in2_load_reg <= '0';
      fu_FMA_ACT_in1t_load_reg <= '0';
      fu_FMA_ACT_in2_load_reg <= '0';
      fu_FMA_ACT_in3_load_reg <= '0';
      fu_vOPS_in1t_load_reg <= '0';
      fu_vOPS_in2_load_reg <= '0';
      fu_vOPS_in3_load_reg <= '0';
      fu_dmem_LSU_in1t_load_reg <= '0';
      fu_dmem_LSU_in2_load_reg <= '0';
      fu_DMA_in1t_load_reg <= '0';
      fu_DMA_in2_load_reg <= '0';
      fu_DMA_in3_load_reg <= '0';
      fu_add_mul_sub_in1t_load_reg <= '0';
      fu_add_mul_sub_in2_load_reg <= '0';
      fu_add_in1t_load_reg <= '0';
      fu_add_in2_load_reg <= '0';
      fu_gcu_pc_load_reg <= '0';
      fu_gcu_ra_load_reg <= '0';
      rf_RF_BOOL_rd_load_reg <= '0';
      rf_RF_BOOL_wr_load_reg <= '0';
      rf_RF32A_rd_load_reg <= '0';
      rf_RF32A_wr_load_reg <= '0';
      rf_RF32B_rd_load_reg <= '0';
      rf_RF32B_wr_load_reg <= '0';
      rf_vRF1024_rd_load_reg <= '0';
      rf_vRF1024_wr_load_reg <= '0';
      iu_IMM_out1_read_load <= '0';

      elsif (pre_decode_merged_glock = '0') then

        -- bus control signals for output mux
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 10) then
          B1_src_sel_reg <= std_logic_vector(conv_unsigned(0, B1_src_sel_reg'length));
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 11) then
          B1_src_sel_reg <= std_logic_vector(conv_unsigned(1, B1_src_sel_reg'length));
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 9) then
          B1_src_sel_reg <= std_logic_vector(conv_unsigned(2, B1_src_sel_reg'length));
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 12) then
          B1_src_sel_reg <= std_logic_vector(conv_unsigned(3, B1_src_sel_reg'length));
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 13) then
          B1_src_sel_reg <= std_logic_vector(conv_unsigned(4, B1_src_sel_reg'length));
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 8) then
          B1_src_sel_reg <= std_logic_vector(conv_unsigned(5, B1_src_sel_reg'length));
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 14) then
          B1_src_sel_reg <= std_logic_vector(conv_unsigned(6, B1_src_sel_reg'length));
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          B1_src_sel_reg <= std_logic_vector(conv_unsigned(7, B1_src_sel_reg'length));
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 21) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(0, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 22) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(1, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 20) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(2, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 3))) = 4) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(3, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 23) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(4, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 24) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(5, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 25) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(6, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 26) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(7, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 4))) = 1) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(8, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 27) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(9, B2_src_sel_reg'length));
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 4))) = 0) then
          B2_src_sel_reg <= std_logic_vector(conv_unsigned(10, B2_src_sel_reg'length));
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 4))) = 0) then
        simm_B2_reg <= tce_ext(src_B2(3 downto 0), simm_B2_reg'length);
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 10) then
          B3_src_sel_reg <= std_logic_vector(conv_unsigned(0, B3_src_sel_reg'length));
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 11) then
          B3_src_sel_reg <= std_logic_vector(conv_unsigned(1, B3_src_sel_reg'length));
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 9) then
          B3_src_sel_reg <= std_logic_vector(conv_unsigned(2, B3_src_sel_reg'length));
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 12) then
          B3_src_sel_reg <= std_logic_vector(conv_unsigned(3, B3_src_sel_reg'length));
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 13) then
          B3_src_sel_reg <= std_logic_vector(conv_unsigned(4, B3_src_sel_reg'length));
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 8) then
          B3_src_sel_reg <= std_logic_vector(conv_unsigned(5, B3_src_sel_reg'length));
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          B3_src_sel_reg <= std_logic_vector(conv_unsigned(6, B3_src_sel_reg'length));
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        end if;
        if (squash_B5 = '0' and conv_integer(unsigned(src_B5(3 downto 3))) = 0) then
          B5_src_sel_reg <= std_logic_vector(conv_unsigned(0, B5_src_sel_reg'length));
        elsif (squash_B5 = '0' and conv_integer(unsigned(src_B5(3 downto 1))) = 4) then
          B5_src_sel_reg <= std_logic_vector(conv_unsigned(1, B5_src_sel_reg'length));
        elsif (squash_B5 = '0' and conv_integer(unsigned(src_B5(3 downto 2))) = 3) then
          B5_src_sel_reg <= std_logic_vector(conv_unsigned(2, B5_src_sel_reg'length));
        end if;
        if (squash_vB1024B = '0' and conv_integer(unsigned(src_vB1024B(2 downto 0))) = 4) then
          vB1024B_src_sel_reg <= std_logic_vector(conv_unsigned(0, vB1024B_src_sel_reg'length));
        elsif (squash_vB1024B = '0' and conv_integer(unsigned(src_vB1024B(2 downto 2))) = 0) then
          vB1024B_src_sel_reg <= std_logic_vector(conv_unsigned(1, vB1024B_src_sel_reg'length));
        elsif (squash_vB1024B = '0' and conv_integer(unsigned(src_vB1024B(2 downto 1))) = 3) then
          vB1024B_src_sel_reg <= std_logic_vector(conv_unsigned(2, vB1024B_src_sel_reg'length));
        end if;
        if (squash_vB1024c = '0' and conv_integer(unsigned(src_vB1024c(2 downto 0))) = 4) then
          vB1024c_src_sel_reg <= std_logic_vector(conv_unsigned(0, vB1024c_src_sel_reg'length));
        elsif (squash_vB1024c = '0' and conv_integer(unsigned(src_vB1024c(2 downto 2))) = 0) then
          vB1024c_src_sel_reg <= std_logic_vector(conv_unsigned(1, vB1024c_src_sel_reg'length));
        elsif (squash_vB1024c = '0' and conv_integer(unsigned(src_vB1024c(2 downto 1))) = 3) then
          vB1024c_src_sel_reg <= std_logic_vector(conv_unsigned(2, vB1024c_src_sel_reg'length));
        end if;
        -- data control signals for output sockets connected to FUs
        -- control signals for RF read ports
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 20 and true) then
          rf_RF_BOOL_rd_load_reg <= '1';
          rf_RF_BOOL_rd_opc_reg <= tce_ext(src_B2(0 downto 0), rf_RF_BOOL_rd_opc_reg'length);
        else
          rf_RF_BOOL_rd_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 9 and true) then
          rf_RF32A_rd_load_reg <= '1';
          rf_RF32A_rd_opc_reg <= tce_ext(src_B1(2 downto 0), rf_RF32A_rd_opc_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 3))) = 4 and true) then
          rf_RF32A_rd_load_reg <= '1';
          rf_RF32A_rd_opc_reg <= tce_ext(src_B2(2 downto 0), rf_RF32A_rd_opc_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 9 and true) then
          rf_RF32A_rd_load_reg <= '1';
          rf_RF32A_rd_opc_reg <= tce_ext(src_B3(2 downto 0), rf_RF32A_rd_opc_reg'length);
        elsif (squash_B5 = '0' and conv_integer(unsigned(src_B5(3 downto 3))) = 0 and true) then
          rf_RF32A_rd_load_reg <= '1';
          rf_RF32A_rd_opc_reg <= tce_ext(src_B5(2 downto 0), rf_RF32A_rd_opc_reg'length);
        else
          rf_RF32A_rd_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 8 and true) then
          rf_RF32B_rd_load_reg <= '1';
          rf_RF32B_rd_opc_reg <= tce_ext(src_B1(3 downto 0), rf_RF32B_rd_opc_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 4))) = 1 and true) then
          rf_RF32B_rd_load_reg <= '1';
          rf_RF32B_rd_opc_reg <= tce_ext(src_B2(3 downto 0), rf_RF32B_rd_opc_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 8 and true) then
          rf_RF32B_rd_load_reg <= '1';
          rf_RF32B_rd_opc_reg <= tce_ext(src_B3(3 downto 0), rf_RF32B_rd_opc_reg'length);
        else
          rf_RF32B_rd_load_reg <= '0';
        end if;
        if (squash_vB1024B = '0' and conv_integer(unsigned(src_vB1024B(2 downto 2))) = 0 and true) then
          rf_vRF1024_rd_load_reg <= '1';
          rf_vRF1024_rd_opc_reg <= tce_ext(src_vB1024B(1 downto 0), rf_vRF1024_rd_opc_reg'length);
        elsif (squash_vB1024c = '0' and conv_integer(unsigned(src_vB1024c(2 downto 2))) = 0 and true) then
          rf_vRF1024_rd_load_reg <= '1';
          rf_vRF1024_rd_opc_reg <= tce_ext(src_vB1024c(1 downto 0), rf_vRF1024_rd_opc_reg'length);
        else
          rf_vRF1024_rd_load_reg <= '0';
        end if;

        --control signals for IU read ports
        -- control signals for IU read ports
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 11) then
          iu_IMM_out1_read_load <= '1';
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(5 downto 1))) = 22) then
          iu_IMM_out1_read_load <= '1';
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 11) then
          iu_IMM_out1_read_load <= '1';
        elsif (squash_B4 = '0' and true) then
          iu_IMM_out1_read_load <= '1';
        else
          iu_IMM_out1_read_load <= '0';
        end if;

        -- control signals for FU inputs
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 4))) = 0) then
          fu_ALU_in1t_load_reg <= '1';
          fu_ALU_opc_reg <= dst_B1(3 downto 0);
          socket_ALU_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i1_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 4))) = 0) then
          fu_ALU_in1t_load_reg <= '1';
          fu_ALU_opc_reg <= dst_B3(3 downto 0);
          socket_ALU_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i1_bus_cntrl_reg'length);
        else
          fu_ALU_in1t_load_reg <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 1))) = 27) then
          fu_ALU_in2_load_reg <= '1';
          socket_ALU_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i2_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 0))) = 60) then
          fu_ALU_in2_load_reg <= '1';
          socket_ALU_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i2_bus_cntrl_reg'length);
        else
          fu_ALU_in2_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 3))) = 7) then
          fu_FMA_ACT_in1t_load_reg <= '1';
          fu_FMA_ACT_opc_reg <= dst_B1(2 downto 0);
          socket_FMA_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_FMA_i1_bus_cntrl_reg'length);
        elsif (squash_vB1024B = '0' and conv_integer(unsigned(dst_vB1024B(4 downto 3))) = 0) then
          fu_FMA_ACT_in1t_load_reg <= '1';
          fu_FMA_ACT_opc_reg <= dst_vB1024B(2 downto 0);
          socket_FMA_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_FMA_i1_bus_cntrl_reg'length);
        else
          fu_FMA_ACT_in1t_load_reg <= '0';
        end if;
        if (squash_vB1024B = '0' and conv_integer(unsigned(dst_vB1024B(4 downto 3))) = 3) then
          fu_FMA_ACT_in2_load_reg <= '1';
        else
          fu_FMA_ACT_in2_load_reg <= '0';
        end if;
        if (squash_vB1024c = '0' and conv_integer(unsigned(dst_vB1024c(2 downto 0))) = 5) then
          fu_FMA_ACT_in3_load_reg <= '1';
        else
          fu_FMA_ACT_in3_load_reg <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 3))) = 5) then
          fu_vOPS_in1t_load_reg <= '1';
          fu_vOPS_opc_reg <= dst_B2(2 downto 0);
          socket_vOPS_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_vOPS_i1_bus_cntrl_reg'length);
        elsif (squash_vB1024B = '0' and conv_integer(unsigned(dst_vB1024B(4 downto 3))) = 1) then
          fu_vOPS_in1t_load_reg <= '1';
          fu_vOPS_opc_reg <= dst_vB1024B(2 downto 0);
          socket_vOPS_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_vOPS_i1_bus_cntrl_reg'length);
        else
          fu_vOPS_in1t_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 3))) = 12) then
          fu_vOPS_in2_load_reg <= '1';
          socket_vOPS_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_vOPS_i2_bus_cntrl_reg'length);
        elsif (squash_vB1024c = '0' and conv_integer(unsigned(dst_vB1024c(2 downto 0))) = 6) then
          fu_vOPS_in2_load_reg <= '1';
          socket_vOPS_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_vOPS_i2_bus_cntrl_reg'length);
        else
          fu_vOPS_in2_load_reg <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 0))) = 63) then
          fu_vOPS_in3_load_reg <= '1';
        else
          fu_vOPS_in3_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 4))) = 1) then
          fu_dmem_LSU_in1t_load_reg <= '1';
          fu_dmem_LSU_opc_reg <= dst_B1(3 downto 0);
          socket_LSU1_i1_bus_cntrl_reg <= conv_std_logic_vector(3, socket_LSU1_i1_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 4))) = 0) then
          fu_dmem_LSU_in1t_load_reg <= '1';
          fu_dmem_LSU_opc_reg <= dst_B2(3 downto 0);
          socket_LSU1_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_LSU1_i1_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 4))) = 1) then
          fu_dmem_LSU_in1t_load_reg <= '1';
          fu_dmem_LSU_opc_reg <= dst_B3(3 downto 0);
          socket_LSU1_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_LSU1_i1_bus_cntrl_reg'length);
        elsif (squash_B5 = '0' and conv_integer(unsigned(dst_B5(4 downto 4))) = 0) then
          fu_dmem_LSU_in1t_load_reg <= '1';
          fu_dmem_LSU_opc_reg <= dst_B5(3 downto 0);
          socket_LSU1_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_LSU1_i1_bus_cntrl_reg'length);
        else
          fu_dmem_LSU_in1t_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 3))) = 9) then
          fu_dmem_LSU_in2_load_reg <= '1';
          socket_LSU1_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_LSU1_i2_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 1))) = 28) then
          fu_dmem_LSU_in2_load_reg <= '1';
          socket_LSU1_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_LSU1_i2_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 0))) = 61) then
          fu_dmem_LSU_in2_load_reg <= '1';
          socket_LSU1_i2_bus_cntrl_reg <= conv_std_logic_vector(3, socket_LSU1_i2_bus_cntrl_reg'length);
        elsif (squash_vB1024c = '0' and conv_integer(unsigned(dst_vB1024c(2 downto 0))) = 4) then
          fu_dmem_LSU_in2_load_reg <= '1';
          socket_LSU1_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_LSU1_i2_bus_cntrl_reg'length);
        else
          fu_dmem_LSU_in2_load_reg <= '0';
        end if;
        if (squash_B5 = '0' and conv_integer(unsigned(dst_B5(4 downto 3))) = 3) then
          fu_DMA_in1t_load_reg <= '1';
          fu_DMA_opc_reg <= dst_B5(1 downto 0);
        else
          fu_DMA_in1t_load_reg <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 1))) = 30) then
          fu_DMA_in2_load_reg <= '1';
        else
          fu_DMA_in2_load_reg <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 0))) = 62) then
          fu_DMA_in3_load_reg <= '1';
        else
          fu_DMA_in3_load_reg <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 2))) = 12) then
          fu_add_mul_sub_in1t_load_reg <= '1';
          fu_add_mul_sub_opc_reg <= dst_B2(1 downto 0);
          socket_add_mul_sub_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_add_mul_sub_i1_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 2))) = 14) then
          fu_add_mul_sub_in1t_load_reg <= '1';
          fu_add_mul_sub_opc_reg <= dst_B3(1 downto 0);
          socket_add_mul_sub_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_add_mul_sub_i1_bus_cntrl_reg'length);
        elsif (squash_B4 = '0' and conv_integer(unsigned(dst_B4(2 downto 2))) = 0) then
          fu_add_mul_sub_in1t_load_reg <= '1';
          fu_add_mul_sub_opc_reg <= dst_B4(1 downto 0);
          socket_add_mul_sub_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_add_mul_sub_i1_bus_cntrl_reg'length);
        else
          fu_add_mul_sub_in1t_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 3))) = 10) then
          fu_add_mul_sub_in2_load_reg <= '1';
        else
          fu_add_mul_sub_in2_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 3))) = 11) then
          fu_add_in1t_load_reg <= '1';
          socket_add_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_add_i1_bus_cntrl_reg'length);
        elsif (squash_B4 = '0' and conv_integer(unsigned(dst_B4(2 downto 2))) = 1) then
          fu_add_in1t_load_reg <= '1';
          socket_add_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_add_i1_bus_cntrl_reg'length);
        else
          fu_add_in1t_load_reg <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 1))) = 31) then
          fu_add_in2_load_reg <= '1';
        else
          fu_add_in2_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 3))) = 8) then
          fu_gcu_pc_load_reg <= '1';
          fu_gcu_opc_reg <= dst_B1(0 downto 0);
        else
          fu_gcu_pc_load_reg <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 1))) = 29) then
          fu_gcu_ra_load_reg <= '1';
        else
          fu_gcu_ra_load_reg <= '0';
        end if;
        -- control signals for RF inputs
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 1))) = 26 and true) then
          rf_RF_BOOL_wr_load_reg <= '1';
          rf_RF_BOOL_wr_opc_reg <= dst_B2(0 downto 0);
        else
          rf_RF_BOOL_wr_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 3))) = 6 and true) then
          rf_RF32A_wr_load_reg <= '1';
          rf_RF32A_wr_opc_reg <= dst_B1(2 downto 0);
          socket_RF32A_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_RF32A_i1_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 3))) = 4 and true) then
          rf_RF32A_wr_load_reg <= '1';
          rf_RF32A_wr_opc_reg <= dst_B2(2 downto 0);
          socket_RF32A_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_RF32A_i1_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 3))) = 6 and true) then
          rf_RF32A_wr_load_reg <= '1';
          rf_RF32A_wr_opc_reg <= dst_B3(2 downto 0);
          socket_RF32A_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_RF32A_i1_bus_cntrl_reg'length);
        elsif (squash_B5 = '0' and conv_integer(unsigned(dst_B5(4 downto 3))) = 2 and true) then
          rf_RF32A_wr_load_reg <= '1';
          rf_RF32A_wr_opc_reg <= dst_B5(2 downto 0);
          socket_RF32A_i1_bus_cntrl_reg <= conv_std_logic_vector(3, socket_RF32A_i1_bus_cntrl_reg'length);
        else
          rf_RF32A_wr_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(6 downto 4))) = 2 and true) then
          rf_RF32B_wr_load_reg <= '1';
          rf_RF32B_wr_opc_reg <= dst_B1(3 downto 0);
          socket_RF32B_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_RF32B_i1_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 4))) = 1 and true) then
          rf_RF32B_wr_load_reg <= '1';
          rf_RF32B_wr_opc_reg <= dst_B2(3 downto 0);
          socket_RF32B_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_RF32B_i1_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 4))) = 2 and true) then
          rf_RF32B_wr_load_reg <= '1';
          rf_RF32B_wr_opc_reg <= dst_B3(3 downto 0);
          socket_RF32B_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_RF32B_i1_bus_cntrl_reg'length);
        else
          rf_RF32B_wr_load_reg <= '0';
        end if;
        if (squash_vB1024B = '0' and conv_integer(unsigned(dst_vB1024B(4 downto 3))) = 2 and true) then
          rf_vRF1024_wr_load_reg <= '1';
          rf_vRF1024_wr_opc_reg <= dst_vB1024B(1 downto 0);
          socket_vRF1024_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_vRF1024_i1_bus_cntrl_reg'length);
        elsif (squash_vB1024c = '0' and conv_integer(unsigned(dst_vB1024c(2 downto 2))) = 0 and true) then
          rf_vRF1024_wr_load_reg <= '1';
          rf_vRF1024_wr_opc_reg <= dst_vB1024c(1 downto 0);
          socket_vRF1024_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_vRF1024_i1_bus_cntrl_reg'length);
        else
          rf_vRF1024_wr_load_reg <= '0';
        end if;
      end if;
      end if;
    end if;
  end process;

  lock_reg_proc : process (clk)
  begin
    if (clk'event and clk = '1') then
      if (rstx = '0') then
      -- Locked during active reset        post_decode_merged_glock_r <= '1';
      else
        post_decode_merged_glock_r <= post_decode_merged_glock;
      end if;
    end if;
  end process lock_reg_proc;

  lock_r <= merged_glock_req;
  merged_glock_req <= lock_req(0) or lock_req(1) or lock_req(2) or lock_req(3) or lock_req(4);
  pre_decode_merged_glock <= lock or merged_glock_req;
  post_decode_merged_glock <= pre_decode_merged_glock or decode_fill_lock_reg;
  locked <= post_decode_merged_glock_r;
  glock(0) <= post_decode_merged_glock; -- to ALU
  glock(1) <= post_decode_merged_glock; -- to FMA_ACT
  glock(2) <= post_decode_merged_glock; -- to vOPS
  glock(3) <= post_decode_merged_glock; -- to dmem_LSU
  glock(4) <= post_decode_merged_glock; -- to DMA
  glock(5) <= post_decode_merged_glock; -- to add_mul_sub
  glock(6) <= post_decode_merged_glock; -- to add
  glock(7) <= post_decode_merged_glock; -- to RF_BOOL
  glock(8) <= post_decode_merged_glock; -- to RF32A
  glock(9) <= post_decode_merged_glock; -- to RF32B
  glock(10) <= post_decode_merged_glock; -- to vRF1024
  glock(11) <= post_decode_merged_glock; -- to IMM
  glock(12) <= post_decode_merged_glock;

  decode_pipeline_fill_lock: process (clk)
  begin
    if clk'event and clk = '1' then
      if rstx = '0' then
        decode_fill_lock_reg <= '1';
      elsif lock = '0' then
        decode_fill_lock_reg <= '0';
      end if;
    end if;
  end process decode_pipeline_fill_lock;

end rtl_andor;
