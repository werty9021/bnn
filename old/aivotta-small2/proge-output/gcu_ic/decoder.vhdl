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
    simm_cntrl_B1 : out std_logic_vector(0 downto 0);
    simm_B2 : out std_logic_vector(6 downto 0);
    simm_cntrl_B2 : out std_logic_vector(0 downto 0);
    simm_B3 : out std_logic_vector(6 downto 0);
    simm_cntrl_B3 : out std_logic_vector(0 downto 0);
    socket_ALU_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_ALU_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_ALU_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_vALU_i1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_vALU_i2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_vALU_i3_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_LSU1_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_LSU1_i2_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_LSU1_o1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_vALU_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_IMM_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_RF_BOOL_o1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_RF32A_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_RF32A_i1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_vRF512_o1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_vRF1024_o1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_gcu_o1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_LSU1_o2_bus_cntrl : out std_logic_vector(2 downto 0);
    fu_ALU_in1t_load : out std_logic;
    fu_ALU_in2_load : out std_logic;
    fu_ALU_opc : out std_logic_vector(3 downto 0);
    fu_vALU_in1t_load : out std_logic;
    fu_vALU_in2_load : out std_logic;
    fu_vALU_in3_load : out std_logic;
    fu_vALU_opc : out std_logic_vector(3 downto 0);
    fu_LSU1_in1t_load : out std_logic;
    fu_LSU1_in2_load : out std_logic;
    fu_LSU1_opc : out std_logic_vector(2 downto 0);
    rf_RF_BOOL_rd_load : out std_logic;
    rf_RF_BOOL_rd_opc : out std_logic_vector(0 downto 0);
    rf_RF_BOOL_wr_load : out std_logic;
    rf_RF_BOOL_wr_opc : out std_logic_vector(0 downto 0);
    rf_RF32A_rd_load : out std_logic;
    rf_RF32A_rd_opc : out std_logic_vector(2 downto 0);
    rf_RF32A_wr_load : out std_logic;
    rf_RF32A_wr_opc : out std_logic_vector(2 downto 0);
    rf_vRF512_rd_load : out std_logic;
    rf_vRF512_rd_opc : out std_logic_vector(1 downto 0);
    rf_vRF512_wr_load : out std_logic;
    rf_vRF512_wr_opc : out std_logic_vector(1 downto 0);
    rf_vRF1024_rd_load : out std_logic;
    rf_vRF1024_rd_opc : out std_logic_vector(1 downto 0);
    rf_vRF1024_wr_load : out std_logic;
    rf_vRF1024_wr_opc : out std_logic_vector(1 downto 0);
    iu_IMM_out1_read_load : out std_logic;
    iu_IMM_out1_read_opc : out std_logic_vector(1 downto 0);
    iu_IMM_write : out std_logic_vector(31 downto 0);
    iu_IMM_write_load : out std_logic;
    iu_IMM_write_opc : out std_logic_vector(1 downto 0);
    rf_guard_RF_BOOL_0 : in std_logic;
    rf_guard_RF_BOOL_1 : in std_logic;
    lock_req : in std_logic_vector(2 downto 0);
    glock : out std_logic_vector(8 downto 0);
    db_tta_nreset : in std_logic);

end tta_core_decoder;

architecture rtl_andor of tta_core_decoder is

  -- signals for source, destination and guard fields
  signal move_B1 : std_logic_vector(31 downto 0);
  signal src_B1 : std_logic_vector(20 downto 0);
  signal dst_B1 : std_logic_vector(5 downto 0);
  signal grd_B1 : std_logic_vector(4 downto 0);
  signal move_B2 : std_logic_vector(13 downto 0);
  signal src_B2 : std_logic_vector(7 downto 0);
  signal dst_B2 : std_logic_vector(5 downto 0);
  signal move_B3 : std_logic_vector(13 downto 0);
  signal src_B3 : std_logic_vector(7 downto 0);
  signal dst_B3 : std_logic_vector(5 downto 0);
  signal move_vB512A : std_logic_vector(7 downto 0);
  signal src_vB512A : std_logic_vector(2 downto 0);
  signal dst_vB512A : std_logic_vector(4 downto 0);
  signal move_vB1024A : std_logic_vector(7 downto 0);
  signal src_vB1024A : std_logic_vector(2 downto 0);
  signal dst_vB1024A : std_logic_vector(4 downto 0);

  -- signals for dedicated immediate slots

  -- signal for long immediate tag
  signal limm_tag : std_logic_vector(0 downto 0);

  -- squash signals
  signal squash_B1 : std_logic;
  signal squash_B2 : std_logic;
  signal squash_B3 : std_logic;
  signal squash_vB512A : std_logic;
  signal squash_vB1024A : std_logic;

  -- socket control signals
  signal socket_ALU_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_ALU_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_ALU_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_vALU_i1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_vALU_i2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_vALU_i3_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_LSU1_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_LSU1_i2_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_LSU1_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_vALU_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_IMM_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_RF_BOOL_o1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_RF32A_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_RF32A_i1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_vRF512_o1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_vRF1024_o1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_gcu_o1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_LSU1_o2_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal simm_B1_reg : std_logic_vector(19 downto 0);
  signal simm_cntrl_B1_reg : std_logic_vector(0 downto 0);
  signal simm_B2_reg : std_logic_vector(6 downto 0);
  signal simm_cntrl_B2_reg : std_logic_vector(0 downto 0);
  signal simm_B3_reg : std_logic_vector(6 downto 0);
  signal simm_cntrl_B3_reg : std_logic_vector(0 downto 0);

  -- FU control signals
  signal fu_ALU_in1t_load_reg : std_logic;
  signal fu_ALU_in2_load_reg : std_logic;
  signal fu_ALU_opc_reg : std_logic_vector(3 downto 0);
  signal fu_vALU_in1t_load_reg : std_logic;
  signal fu_vALU_in2_load_reg : std_logic;
  signal fu_vALU_in3_load_reg : std_logic;
  signal fu_vALU_opc_reg : std_logic_vector(3 downto 0);
  signal fu_LSU1_in1t_load_reg : std_logic;
  signal fu_LSU1_in2_load_reg : std_logic;
  signal fu_LSU1_opc_reg : std_logic_vector(2 downto 0);
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
  signal rf_vRF512_rd_load_reg : std_logic;
  signal rf_vRF512_rd_opc_reg : std_logic_vector(1 downto 0);
  signal rf_vRF512_wr_load_reg : std_logic;
  signal rf_vRF512_wr_opc_reg : std_logic_vector(1 downto 0);
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
    src_B1 <= instructionword(26 downto 6);
    dst_B1 <= instructionword(5 downto 0);
    grd_B1 <= instructionword(31 downto 27);
    move_B2 <= instructionword(46-1 downto 32);
    src_B2 <= instructionword(45 downto 38);
    dst_B2 <= instructionword(37 downto 32);
    move_B3 <= instructionword(60-1 downto 46);
    src_B3 <= instructionword(59 downto 52);
    dst_B3 <= instructionword(51 downto 46);
    move_vB512A <= instructionword(68-1 downto 60);
    src_vB512A <= instructionword(67 downto 65);
    dst_vB512A <= instructionword(64 downto 60);
    move_vB1024A <= instructionword(76-1 downto 68);
    src_vB1024A <= instructionword(75 downto 73);
    dst_vB1024A <= instructionword(72 downto 68);

    limm_tag <= instructionword(78 downto 78);
  end process;

  -- map control registers to outputs
  fu_ALU_in1t_load <= fu_ALU_in1t_load_reg;
  fu_ALU_in2_load <= fu_ALU_in2_load_reg;
  fu_ALU_opc <= fu_ALU_opc_reg;

  fu_vALU_in1t_load <= fu_vALU_in1t_load_reg;
  fu_vALU_in2_load <= fu_vALU_in2_load_reg;
  fu_vALU_in3_load <= fu_vALU_in3_load_reg;
  fu_vALU_opc <= fu_vALU_opc_reg;

  fu_LSU1_in1t_load <= fu_LSU1_in1t_load_reg;
  fu_LSU1_in2_load <= fu_LSU1_in2_load_reg;
  fu_LSU1_opc <= fu_LSU1_opc_reg;

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
  rf_vRF512_rd_load <= rf_vRF512_rd_load_reg;
  rf_vRF512_rd_opc <= rf_vRF512_rd_opc_reg;
  rf_vRF512_wr_load <= rf_vRF512_wr_load_reg;
  rf_vRF512_wr_opc <= rf_vRF512_wr_opc_reg;
  rf_vRF1024_rd_load <= rf_vRF1024_rd_load_reg;
  rf_vRF1024_rd_opc <= rf_vRF1024_rd_opc_reg;
  rf_vRF1024_wr_load <= rf_vRF1024_wr_load_reg;
  rf_vRF1024_wr_opc <= rf_vRF1024_wr_opc_reg;
  socket_ALU_i1_bus_cntrl <= socket_ALU_i1_bus_cntrl_reg;
  socket_ALU_o1_bus_cntrl <= socket_ALU_o1_bus_cntrl_reg;
  socket_ALU_i2_bus_cntrl <= socket_ALU_i2_bus_cntrl_reg;
  socket_vALU_i1_bus_cntrl <= socket_vALU_i1_bus_cntrl_reg;
  socket_vALU_i2_bus_cntrl <= socket_vALU_i2_bus_cntrl_reg;
  socket_vALU_i3_bus_cntrl <= socket_vALU_i3_bus_cntrl_reg;
  socket_LSU1_i1_bus_cntrl <= socket_LSU1_i1_bus_cntrl_reg;
  socket_LSU1_i2_bus_cntrl <= socket_LSU1_i2_bus_cntrl_reg;
  socket_LSU1_o1_bus_cntrl <= socket_LSU1_o1_bus_cntrl_reg;
  socket_vALU_o1_bus_cntrl <= socket_vALU_o1_bus_cntrl_reg;
  socket_IMM_o1_bus_cntrl <= socket_IMM_o1_bus_cntrl_reg;
  socket_RF_BOOL_o1_bus_cntrl <= socket_RF_BOOL_o1_bus_cntrl_reg;
  socket_RF32A_o1_bus_cntrl <= socket_RF32A_o1_bus_cntrl_reg;
  socket_RF32A_i1_bus_cntrl <= socket_RF32A_i1_bus_cntrl_reg;
  socket_vRF512_o1_bus_cntrl <= socket_vRF512_o1_bus_cntrl_reg;
  socket_vRF1024_o1_bus_cntrl <= socket_vRF1024_o1_bus_cntrl_reg;
  socket_gcu_o1_bus_cntrl <= socket_gcu_o1_bus_cntrl_reg;
  socket_LSU1_o2_bus_cntrl <= socket_LSU1_o2_bus_cntrl_reg;
  simm_cntrl_B1 <= simm_cntrl_B1_reg;
  simm_B1 <= simm_B1_reg;
  simm_cntrl_B2 <= simm_cntrl_B2_reg;
  simm_B2 <= simm_B2_reg;
  simm_cntrl_B3 <= simm_cntrl_B3_reg;
  simm_B3 <= simm_B3_reg;

  -- generate signal squash_B1
  process (grd_B1, limm_tag, move_B1, rf_guard_RF_BOOL_0, rf_guard_RF_BOOL_1)
    variable sel : integer;
  begin --process
    if (conv_integer(unsigned(limm_tag)) = 1) then
      squash_B1 <= '1';
    -- squash by move NOP encoding
    elsif (conv_integer(unsigned(move_B1(29 downto 27))) = 5) then
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
    if (conv_integer(unsigned(move_B2(13 downto 10))) = 14) then
      squash_B2 <= '1';
    else
      squash_B2 <= '0';
    end if;
  end process;

  -- generate signal squash_B3
  process (move_B3)
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_B3(13 downto 10))) = 9) then
      squash_B3 <= '1';
    else
      squash_B3 <= '0';
    end if;
  end process;

  -- generate signal squash_vB512A
  process (move_vB512A)
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_vB512A(7 downto 5))) = 5) then
      squash_vB512A <= '1';
    else
      squash_vB512A <= '0';
    end if;
  end process;

  -- generate signal squash_vB1024A
  process (move_vB1024A)
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_vB1024A(7 downto 5))) = 5) then
      squash_vB1024A <= '1';
    else
      squash_vB1024A <= '0';
    end if;
  end process;


  --long immediate write process
  process (clk, rstx)
  begin --process
    if (rstx = '0') then
      iu_IMM_write_load <= '0';
      iu_IMM_write <= (others => '0');
      iu_IMM_write_opc <= (others => '0');
    elsif (clk'event and clk = '1') then
      if pre_decode_merged_glock = '0' then
        if (conv_integer(unsigned(limm_tag)) = 0) then
          iu_IMM_write_load <= '0';
          iu_IMM_write(31 downto 0) <= tce_sxt("0", 32);
        else
          iu_IMM_write(31 downto 0) <= tce_ext(instructionword(31 downto 0), 32);
          iu_IMM_write_opc <= tce_ext(instructionword(77 downto 76), iu_IMM_write_opc'length);
          iu_IMM_write_load <= '1';
        end if;
      end if;
    end if;
  end process;


  -- main decoding process
  process (clk, rstx)
  begin
    if (rstx = '0') then
      socket_ALU_i1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i2_bus_cntrl_reg <= (others => '0');
      socket_vALU_i1_bus_cntrl_reg <= (others => '0');
      socket_vALU_i2_bus_cntrl_reg <= (others => '0');
      socket_vALU_i3_bus_cntrl_reg <= (others => '0');
      socket_LSU1_i1_bus_cntrl_reg <= (others => '0');
      socket_LSU1_i2_bus_cntrl_reg <= (others => '0');
      socket_LSU1_o1_bus_cntrl_reg <= (others => '0');
      socket_vALU_o1_bus_cntrl_reg <= (others => '0');
      socket_IMM_o1_bus_cntrl_reg <= (others => '0');
      socket_RF_BOOL_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32A_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32A_i1_bus_cntrl_reg <= (others => '0');
      socket_vRF512_o1_bus_cntrl_reg <= (others => '0');
      socket_vRF1024_o1_bus_cntrl_reg <= (others => '0');
      socket_gcu_o1_bus_cntrl_reg <= (others => '0');
      socket_LSU1_o2_bus_cntrl_reg <= (others => '0');
      simm_B1_reg <= (others => '0');
      simm_cntrl_B1_reg <= (others => '0');
      simm_B2_reg <= (others => '0');
      simm_cntrl_B2_reg <= (others => '0');
      simm_B3_reg <= (others => '0');
      simm_cntrl_B3_reg <= (others => '0');
      fu_ALU_opc_reg <= (others => '0');
      fu_vALU_opc_reg <= (others => '0');
      fu_LSU1_opc_reg <= (others => '0');
      fu_gcu_opc_reg <= (others => '0');
      rf_RF_BOOL_rd_opc_reg <= (others => '0');
      rf_RF_BOOL_wr_opc_reg <= (others => '0');
      rf_RF32A_rd_opc_reg <= (others => '0');
      rf_RF32A_wr_opc_reg <= (others => '0');
      rf_vRF512_rd_opc_reg <= (others => '0');
      rf_vRF512_wr_opc_reg <= (others => '0');
      rf_vRF1024_rd_opc_reg <= (others => '0');
      rf_vRF1024_wr_opc_reg <= (others => '0');
      iu_IMM_out1_read_opc <= (others => '0');

      fu_ALU_in1t_load_reg <= '0';
      fu_ALU_in2_load_reg <= '0';
      fu_vALU_in1t_load_reg <= '0';
      fu_vALU_in2_load_reg <= '0';
      fu_vALU_in3_load_reg <= '0';
      fu_LSU1_in1t_load_reg <= '0';
      fu_LSU1_in2_load_reg <= '0';
      fu_gcu_pc_load_reg <= '0';
      fu_gcu_ra_load_reg <= '0';
      rf_RF_BOOL_rd_load_reg <= '0';
      rf_RF_BOOL_wr_load_reg <= '0';
      rf_RF32A_rd_load_reg <= '0';
      rf_RF32A_wr_load_reg <= '0';
      rf_vRF512_rd_load_reg <= '0';
      rf_vRF512_wr_load_reg <= '0';
      rf_vRF1024_rd_load_reg <= '0';
      rf_vRF1024_wr_load_reg <= '0';
      iu_IMM_out1_read_load <= '0';


    elsif (clk'event and clk = '1') then -- rising clock edge
      if (db_tta_nreset = '0') then
      socket_ALU_i1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i2_bus_cntrl_reg <= (others => '0');
      socket_vALU_i1_bus_cntrl_reg <= (others => '0');
      socket_vALU_i2_bus_cntrl_reg <= (others => '0');
      socket_vALU_i3_bus_cntrl_reg <= (others => '0');
      socket_LSU1_i1_bus_cntrl_reg <= (others => '0');
      socket_LSU1_i2_bus_cntrl_reg <= (others => '0');
      socket_LSU1_o1_bus_cntrl_reg <= (others => '0');
      socket_vALU_o1_bus_cntrl_reg <= (others => '0');
      socket_IMM_o1_bus_cntrl_reg <= (others => '0');
      socket_RF_BOOL_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32A_o1_bus_cntrl_reg <= (others => '0');
      socket_RF32A_i1_bus_cntrl_reg <= (others => '0');
      socket_vRF512_o1_bus_cntrl_reg <= (others => '0');
      socket_vRF1024_o1_bus_cntrl_reg <= (others => '0');
      socket_gcu_o1_bus_cntrl_reg <= (others => '0');
      socket_LSU1_o2_bus_cntrl_reg <= (others => '0');
      simm_B1_reg <= (others => '0');
      simm_cntrl_B1_reg <= (others => '0');
      simm_B2_reg <= (others => '0');
      simm_cntrl_B2_reg <= (others => '0');
      simm_B3_reg <= (others => '0');
      simm_cntrl_B3_reg <= (others => '0');
      fu_ALU_opc_reg <= (others => '0');
      fu_vALU_opc_reg <= (others => '0');
      fu_LSU1_opc_reg <= (others => '0');
      fu_gcu_opc_reg <= (others => '0');
      rf_RF_BOOL_rd_opc_reg <= (others => '0');
      rf_RF_BOOL_wr_opc_reg <= (others => '0');
      rf_RF32A_rd_opc_reg <= (others => '0');
      rf_RF32A_wr_opc_reg <= (others => '0');
      rf_vRF512_rd_opc_reg <= (others => '0');
      rf_vRF512_wr_opc_reg <= (others => '0');
      rf_vRF1024_rd_opc_reg <= (others => '0');
      rf_vRF1024_wr_opc_reg <= (others => '0');
      iu_IMM_out1_read_opc <= (others => '0');

      fu_ALU_in1t_load_reg <= '0';
      fu_ALU_in2_load_reg <= '0';
      fu_vALU_in1t_load_reg <= '0';
      fu_vALU_in2_load_reg <= '0';
      fu_vALU_in3_load_reg <= '0';
      fu_LSU1_in1t_load_reg <= '0';
      fu_LSU1_in2_load_reg <= '0';
      fu_gcu_pc_load_reg <= '0';
      fu_gcu_ra_load_reg <= '0';
      rf_RF_BOOL_rd_load_reg <= '0';
      rf_RF_BOOL_wr_load_reg <= '0';
      rf_RF32A_rd_load_reg <= '0';
      rf_RF32A_wr_load_reg <= '0';
      rf_vRF512_rd_load_reg <= '0';
      rf_vRF512_wr_load_reg <= '0';
      rf_vRF1024_rd_load_reg <= '0';
      rf_vRF1024_wr_load_reg <= '0';
      iu_IMM_out1_read_load <= '0';

      elsif (pre_decode_merged_glock = '0') then

        -- bus control signals for output mux
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 10) then
          socket_ALU_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 4))) = 11) then
          socket_ALU_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_ALU_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 5))) = 6) then
          socket_ALU_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_ALU_o1_bus_cntrl_reg(2) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_vB512A = '0' and conv_integer(unsigned(src_vB512A(2 downto 0))) = 4) then
          socket_LSU1_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_LSU1_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_vB1024A = '0' and conv_integer(unsigned(src_vB1024A(2 downto 0))) = 4) then
          socket_LSU1_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_LSU1_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 11) then
          socket_vALU_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_vALU_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_vB512A = '0' and conv_integer(unsigned(src_vB512A(2 downto 1))) = 3) then
          socket_vALU_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_vALU_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_vB1024A = '0' and conv_integer(unsigned(src_vB1024A(2 downto 1))) = 3) then
          socket_vALU_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_vALU_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 9) then
          socket_IMM_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_IMM_o1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 4))) = 9) then
          socket_IMM_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_IMM_o1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 5))) = 5) then
          socket_IMM_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_IMM_o1_bus_cntrl_reg(2) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 4))) = 10) then
          socket_RF_BOOL_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_RF_BOOL_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 8) then
          socket_RF32A_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_RF32A_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 4))) = 8) then
          socket_RF32A_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_RF32A_o1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 8) then
          socket_RF32A_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_RF32A_o1_bus_cntrl_reg(1) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_vB512A = '0' and conv_integer(unsigned(src_vB512A(2 downto 2))) = 0) then
          socket_vRF512_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_vRF512_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_vB1024A = '0' and conv_integer(unsigned(src_vB1024A(2 downto 2))) = 0) then
          socket_vRF1024_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_vRF1024_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 4))) = 12) then
          socket_gcu_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_gcu_o1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 12) then
          socket_LSU1_o2_bus_cntrl_reg(0) <= '1';
        else
          socket_LSU1_o2_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 4))) = 13) then
          socket_LSU1_o2_bus_cntrl_reg(1) <= '1';
        else
          socket_LSU1_o2_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 5))) = 7) then
          socket_LSU1_o2_bus_cntrl_reg(2) <= '1';
        else
          socket_LSU1_o2_bus_cntrl_reg(2) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 20))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_ext(src_B1(19 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 7))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_ext(src_B2(6 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 7))) = 0) then
          simm_cntrl_B3_reg(0) <= '1';
        simm_B3_reg <= tce_ext(src_B3(6 downto 0), simm_B3_reg'length);
        else
          simm_cntrl_B3_reg(0) <= '0';
        end if;
        -- data control signals for output sockets connected to FUs
        -- control signals for RF read ports
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 4))) = 10 and true) then
          rf_RF_BOOL_rd_load_reg <= '1';
          rf_RF_BOOL_rd_opc_reg <= tce_ext(src_B2(0 downto 0), rf_RF_BOOL_rd_opc_reg'length);
        else
          rf_RF_BOOL_rd_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 8 and true) then
          rf_RF32A_rd_load_reg <= '1';
          rf_RF32A_rd_opc_reg <= tce_ext(src_B1(2 downto 0), rf_RF32A_rd_opc_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 4))) = 8 and true) then
          rf_RF32A_rd_load_reg <= '1';
          rf_RF32A_rd_opc_reg <= tce_ext(src_B2(2 downto 0), rf_RF32A_rd_opc_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 4))) = 8 and true) then
          rf_RF32A_rd_load_reg <= '1';
          rf_RF32A_rd_opc_reg <= tce_ext(src_B3(2 downto 0), rf_RF32A_rd_opc_reg'length);
        else
          rf_RF32A_rd_load_reg <= '0';
        end if;
        if (squash_vB512A = '0' and conv_integer(unsigned(src_vB512A(2 downto 2))) = 0 and true) then
          rf_vRF512_rd_load_reg <= '1';
          rf_vRF512_rd_opc_reg <= tce_ext(src_vB512A(1 downto 0), rf_vRF512_rd_opc_reg'length);
        else
          rf_vRF512_rd_load_reg <= '0';
        end if;
        if (squash_vB1024A = '0' and conv_integer(unsigned(src_vB1024A(2 downto 2))) = 0 and true) then
          rf_vRF1024_rd_load_reg <= '1';
          rf_vRF1024_rd_opc_reg <= tce_ext(src_vB1024A(1 downto 0), rf_vRF1024_rd_opc_reg'length);
        else
          rf_vRF1024_rd_load_reg <= '0';
        end if;

        --control signals for IU read ports
        -- control signals for IU read ports
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(20 downto 17))) = 9 and true) then
          iu_IMM_out1_read_load <= '1';
          iu_IMM_out1_read_opc <= tce_ext(src_B1(1 downto 0), iu_IMM_out1_read_opc'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(7 downto 4))) = 9 and true) then
          iu_IMM_out1_read_load <= '1';
          iu_IMM_out1_read_opc <= tce_ext(src_B2(1 downto 0), iu_IMM_out1_read_opc'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(src_B3(7 downto 5))) = 5 and true) then
          iu_IMM_out1_read_load <= '1';
          iu_IMM_out1_read_opc <= tce_ext(src_B3(1 downto 0), iu_IMM_out1_read_opc'length);
        else
          iu_IMM_out1_read_load <= '0';
        end if;

        -- control signals for FU inputs
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 4))) = 0) then
          fu_ALU_in1t_load_reg <= '1';
          fu_ALU_opc_reg <= dst_B1(3 downto 0);
          socket_ALU_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i1_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 4))) = 0) then
          fu_ALU_in1t_load_reg <= '1';
          fu_ALU_opc_reg <= dst_B2(3 downto 0);
          socket_ALU_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_ALU_i1_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 4))) = 0) then
          fu_ALU_in1t_load_reg <= '1';
          fu_ALU_opc_reg <= dst_B3(3 downto 0);
          socket_ALU_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i1_bus_cntrl_reg'length);
        else
          fu_ALU_in1t_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 2))) = 9) then
          fu_ALU_in2_load_reg <= '1';
          socket_ALU_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_ALU_i2_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 2))) = 9) then
          fu_ALU_in2_load_reg <= '1';
          socket_ALU_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i2_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 3))) = 4) then
          fu_ALU_in2_load_reg <= '1';
          socket_ALU_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i2_bus_cntrl_reg'length);
        else
          fu_ALU_in2_load_reg <= '0';
        end if;
        if (squash_vB512A = '0' and conv_integer(unsigned(dst_vB512A(4 downto 4))) = 0) then
          fu_vALU_in1t_load_reg <= '1';
          fu_vALU_opc_reg <= dst_vB512A(3 downto 0);
          socket_vALU_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_vALU_i1_bus_cntrl_reg'length);
        elsif (squash_vB1024A = '0' and conv_integer(unsigned(dst_vB1024A(4 downto 4))) = 0) then
          fu_vALU_in1t_load_reg <= '1';
          fu_vALU_opc_reg <= dst_vB1024A(3 downto 0);
          socket_vALU_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_vALU_i1_bus_cntrl_reg'length);
        else
          fu_vALU_in1t_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 2))) = 10) then
          fu_vALU_in2_load_reg <= '1';
          socket_vALU_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_vALU_i2_bus_cntrl_reg'length);
        elsif (squash_vB512A = '0' and conv_integer(unsigned(dst_vB512A(4 downto 2))) = 5) then
          fu_vALU_in2_load_reg <= '1';
          socket_vALU_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_vALU_i2_bus_cntrl_reg'length);
        elsif (squash_vB1024A = '0' and conv_integer(unsigned(dst_vB1024A(4 downto 2))) = 5) then
          fu_vALU_in2_load_reg <= '1';
          socket_vALU_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_vALU_i2_bus_cntrl_reg'length);
        else
          fu_vALU_in2_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 2))) = 11) then
          fu_vALU_in3_load_reg <= '1';
          socket_vALU_i3_bus_cntrl_reg <= conv_std_logic_vector(2, socket_vALU_i3_bus_cntrl_reg'length);
        elsif (squash_vB512A = '0' and conv_integer(unsigned(dst_vB512A(4 downto 2))) = 6) then
          fu_vALU_in3_load_reg <= '1';
          socket_vALU_i3_bus_cntrl_reg <= conv_std_logic_vector(0, socket_vALU_i3_bus_cntrl_reg'length);
        elsif (squash_vB1024A = '0' and conv_integer(unsigned(dst_vB1024A(4 downto 2))) = 6) then
          fu_vALU_in3_load_reg <= '1';
          socket_vALU_i3_bus_cntrl_reg <= conv_std_logic_vector(1, socket_vALU_i3_bus_cntrl_reg'length);
        else
          fu_vALU_in3_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 3))) = 2) then
          fu_LSU1_in1t_load_reg <= '1';
          fu_LSU1_opc_reg <= dst_B1(2 downto 0);
          socket_LSU1_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_LSU1_i1_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 3))) = 2) then
          fu_LSU1_in1t_load_reg <= '1';
          fu_LSU1_opc_reg <= dst_B2(2 downto 0);
          socket_LSU1_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_LSU1_i1_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 3))) = 2) then
          fu_LSU1_in1t_load_reg <= '1';
          fu_LSU1_opc_reg <= dst_B3(2 downto 0);
          socket_LSU1_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_LSU1_i1_bus_cntrl_reg'length);
        else
          fu_LSU1_in1t_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 2))) = 12) then
          fu_LSU1_in2_load_reg <= '1';
          socket_LSU1_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_LSU1_i2_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 2))) = 10) then
          fu_LSU1_in2_load_reg <= '1';
          socket_LSU1_i2_bus_cntrl_reg <= conv_std_logic_vector(2, socket_LSU1_i2_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 3))) = 5) then
          fu_LSU1_in2_load_reg <= '1';
          socket_LSU1_i2_bus_cntrl_reg <= conv_std_logic_vector(4, socket_LSU1_i2_bus_cntrl_reg'length);
        elsif (squash_vB512A = '0' and conv_integer(unsigned(dst_vB512A(4 downto 2))) = 7) then
          fu_LSU1_in2_load_reg <= '1';
          socket_LSU1_i2_bus_cntrl_reg <= conv_std_logic_vector(3, socket_LSU1_i2_bus_cntrl_reg'length);
        elsif (squash_vB1024A = '0' and conv_integer(unsigned(dst_vB1024A(4 downto 2))) = 7) then
          fu_LSU1_in2_load_reg <= '1';
          socket_LSU1_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_LSU1_i2_bus_cntrl_reg'length);
        else
          fu_LSU1_in2_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 2))) = 8) then
          fu_gcu_pc_load_reg <= '1';
          fu_gcu_opc_reg <= dst_B1(0 downto 0);
        else
          fu_gcu_pc_load_reg <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 2))) = 11) then
          fu_gcu_ra_load_reg <= '1';
        else
          fu_gcu_ra_load_reg <= '0';
        end if;
        -- control signals for RF inputs
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 2))) = 8 and true) then
          rf_RF_BOOL_wr_load_reg <= '1';
          rf_RF_BOOL_wr_opc_reg <= dst_B2(0 downto 0);
        else
          rf_RF_BOOL_wr_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 3))) = 3 and true) then
          rf_RF32A_wr_load_reg <= '1';
          rf_RF32A_wr_opc_reg <= dst_B1(2 downto 0);
          socket_RF32A_i1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_RF32A_i1_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 3))) = 3 and true) then
          rf_RF32A_wr_load_reg <= '1';
          rf_RF32A_wr_opc_reg <= dst_B2(2 downto 0);
          socket_RF32A_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_RF32A_i1_bus_cntrl_reg'length);
        elsif (squash_B3 = '0' and conv_integer(unsigned(dst_B3(5 downto 3))) = 3 and true) then
          rf_RF32A_wr_load_reg <= '1';
          rf_RF32A_wr_opc_reg <= dst_B3(2 downto 0);
          socket_RF32A_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_RF32A_i1_bus_cntrl_reg'length);
        else
          rf_RF32A_wr_load_reg <= '0';
        end if;
        if (squash_vB512A = '0' and conv_integer(unsigned(dst_vB512A(4 downto 2))) = 4 and true) then
          rf_vRF512_wr_load_reg <= '1';
          rf_vRF512_wr_opc_reg <= dst_vB512A(1 downto 0);
        else
          rf_vRF512_wr_load_reg <= '0';
        end if;
        if (squash_vB1024A = '0' and conv_integer(unsigned(dst_vB1024A(4 downto 2))) = 4 and true) then
          rf_vRF1024_wr_load_reg <= '1';
          rf_vRF1024_wr_opc_reg <= dst_vB1024A(1 downto 0);
        else
          rf_vRF1024_wr_load_reg <= '0';
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
  merged_glock_req <= lock_req(0) or lock_req(1) or lock_req(2);
  pre_decode_merged_glock <= lock or merged_glock_req;
  post_decode_merged_glock <= pre_decode_merged_glock or decode_fill_lock_reg;
  locked <= post_decode_merged_glock_r;
  glock(0) <= post_decode_merged_glock; -- to ALU
  glock(1) <= post_decode_merged_glock; -- to vALU
  glock(2) <= post_decode_merged_glock; -- to LSU1
  glock(3) <= post_decode_merged_glock; -- to RF_BOOL
  glock(4) <= post_decode_merged_glock; -- to RF32A
  glock(5) <= post_decode_merged_glock; -- to vRF512
  glock(6) <= post_decode_merged_glock; -- to vRF1024
  glock(7) <= post_decode_merged_glock; -- to IMM
  glock(8) <= post_decode_merged_glock;

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
