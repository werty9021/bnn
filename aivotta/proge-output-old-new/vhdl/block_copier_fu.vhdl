-- Copyright (c) 2016 Tampere University.
--
-- This file is part of TTA-Based Codesign Environment (TCE).
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
-------------------------------------------------------------------------------
-- Title      : Block transfer function unit for AXI4 bus
-- Project    : Almarvi
-------------------------------------------------------------------------------
-- File       : block_mover_fu.vhdl
-- Author     : Aleksi Tervo  <aleksi.tervo@tut.fi>
-- Company    : TUT/CPC
-- Created    : 2016-10-19
-- Last update: 2017-03-31
-- Platform   :
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-10-19  0.1      tervoa  Created
-- 2017-01-24  0.2      tervoa  Added FU wrapper with shadow regs
-- 2017-03-31  1.0      tervoa  Throughput improvements
-- 2017-03-31  1.1      tervoa  Fix LD32 bug
-- 2017-05-26  1.2      tervoa  Restructure, add command FIFOs
-------------------------------------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity fu_axi_bc is
  generic (
    data_width_g          : integer := 32;
    addr_width_g          : integer := 32;
    max_burst_log2_g      : integer := 10
  );
  port (
    -- Global signals:
    clk          : in std_logic;
    rstx         : in std_logic;

    -- AXI4 Write channel:
    m_axi_awaddr  : out std_logic_vector(addr_width_g - 1 downto 0);
    m_axi_awcache : out std_logic_vector(4 - 1 downto 0);
    m_axi_awlen   : out std_logic_vector(8 - 1 downto 0);
    m_axi_awsize  : out std_logic_vector(3 - 1 downto 0);
    m_axi_awburst : out std_logic_vector(2 - 1 downto 0);
    m_axi_awprot  : out std_logic_vector(3 - 1 downto 0);
    m_axi_awvalid : out std_logic_vector(0 downto 0);
    m_axi_awready : in  std_logic_vector(0 downto 0);
    m_axi_wdata   : out std_logic_vector(data_width_g - 1 downto 0);
    m_axi_wstrb   : out std_logic_vector(data_width_g/8 - 1 downto 0);
    m_axi_wlast   : out std_logic_vector(0 downto 0);
    m_axi_wvalid  : out std_logic_vector(0 downto 0);
    m_axi_wready  : in  std_logic_vector(0 downto 0);
    -- m_axi_bresp : in std_logic_vector(2 - 1 downto 0);
    m_axi_bvalid  : in  std_logic_vector(0 downto 0);
    m_axi_bready  : out std_logic_vector(0 downto 0);
    -- AXI4 Read channel
    m_axi_araddr  : out std_logic_vector(addr_width_g - 1 downto 0);
    m_axi_arcache : out std_logic_vector(4 - 1 downto 0);
    m_axi_arlen   : out std_logic_vector(8 - 1 downto 0);
    m_axi_arsize  : out std_logic_vector(3 - 1 downto 0);
    m_axi_arburst : out std_logic_vector(2 - 1 downto 0);
    m_axi_arprot  : out std_logic_vector(3 - 1 downto 0);
    m_axi_arvalid : out std_logic_vector(0 downto 0);
    m_axi_arready : in  std_logic_vector(0 downto 0);
    m_axi_rdata   : in  std_logic_vector(data_width_g - 1 downto 0);
    --m_axi_rresp   : in std_logic_vector(2 - 1 downto 0);
    m_axi_rvalid  : in  std_logic_vector(0 downto 0);
    m_axi_rlast   : in  std_logic_vector(0 downto 0);
    m_axi_rready  : out std_logic_vector(0 downto 0);

    t1load   : in std_logic;
    t1data   : in std_logic_vector(32-1 downto 0);
    t1opcode : in std_logic_vector(1 downto 0);
    o1load   : in std_logic;
    o1data   : in std_logic_vector(32 - 1 downto 0);
    o2load   : in std_logic;
    o2data   : in std_logic_vector(32 - 1 downto 0);
    r1data   : out std_logic_vector(32 - 1 downto 0);

    glock   : in std_logic;
    lockreq : out std_logic
  );
end fu_axi_bc;

architecture rtl of fu_axi_bc is
  constant byte_count_c : integer := data_width_g/8;

  function write_strobe(offset : integer; invert : boolean)
      return std_logic_vector is

    variable wstrb : std_logic_vector(byte_count_c-1 downto 0);
  begin
    for I in 0 to byte_count_c-1 loop
      if (I > offset xor invert) or I = offset then
        wstrb(I) := '1';
      else
        wstrb(I) := '0';
      end if;
    end loop;
    return wstrb;
  end function write_strobe;

  component read_channel_axi4_master is
    generic (
      data_width_g          : integer;
      addr_width_g          : integer
    );
    port (
      -- Global signals:
      clk          : in std_logic;
      rstx         : in std_logic;

      -- AXI4 Read address channel
      m_axi_araddr  : out std_logic_vector(addr_width_g - 1 downto 0);
      m_axi_arcache : out std_logic_vector(4 - 1 downto 0);
      m_axi_arlen   : out std_logic_vector(8 - 1 downto 0);
      m_axi_arsize  : out std_logic_vector(3 - 1 downto 0);
      m_axi_arburst : out std_logic_vector(2 - 1 downto 0);
      m_axi_arprot  : out std_logic_vector(3 - 1 downto 0);
      m_axi_arvalid : out std_logic;
      m_axi_arready : in  std_logic;
      -- AXI4 Read channel
      m_axi_rdata   : in  std_logic_vector(data_width_g - 1 downto 0);
      --m_axi_rresp   : in std_logic_vector(2 - 1 downto 0);
      m_axi_rvalid  : in  std_logic;
      m_axi_rlast   : in  std_logic;
      m_axi_rready  : out std_logic;

      -- Control interface
      data_out         : out std_logic_vector(data_width_g - 1 downto 0);
      data_valid_out   : out std_logic;
      data_ready_in    : in std_logic;
      data_last_out    : out std_logic;
      ar_ack_out       : out std_logic;

      cmd_valid_in     : in std_logic;
      cmd_length_in    : in std_logic_vector(8 - 1 downto 0);
      cmd_address_in   : in std_logic_vector(addr_width_g - 1 downto 0);
      cmd_ready_out      : out std_logic;

      ready_out        : out std_logic;
      init_done_out    : out std_logic
  );
  end component;

  component write_channel_axi4_master is
  generic (
    data_width_g          : integer;
    addr_width_g          : integer
  );
  port (
    -- Global signals:
    clk          : in std_logic;
    rstx         : in std_logic;

    -- AXI4 Write address channel:
    m_axi_awaddr  : out std_logic_vector(addr_width_g - 1 downto 0);
    m_axi_awcache : out std_logic_vector(4 - 1 downto 0);
    m_axi_awlen   : out std_logic_vector(8 - 1 downto 0);
    m_axi_awsize  : out std_logic_vector(3 - 1 downto 0);
    m_axi_awburst : out std_logic_vector(2 - 1 downto 0);
    m_axi_awprot  : out std_logic_vector(3 - 1 downto 0);
    m_axi_awvalid : out std_logic;
    m_axi_awready : in  std_logic;
    -- AXI4 Write channel:
    m_axi_wdata   : out std_logic_vector(data_width_g - 1 downto 0);
    m_axi_wstrb   : out std_logic_vector(data_width_g/8 - 1 downto 0);
    m_axi_wlast   : out std_logic;
    m_axi_wvalid  : out std_logic;
    m_axi_wready  : in  std_logic;
    -- AXI4 Write response channel
    -- m_axi_bresp : in std_logic_vector(2 - 1 downto 0);
    m_axi_bvalid  : in  std_logic;
    m_axi_bready  : out std_logic;

    -- Control interface
    data_in          : in std_logic_vector(data_width_g - 1 downto 0);
    data_valid_in    : in std_logic;
    data_ready_out   : out std_logic;

    cmd_valid_in       : in std_logic;
    cmd_length_in      : in std_logic_vector(8 - 1 downto 0);
    cmd_address_in     : in std_logic_vector(addr_width_g - 1 downto 0);
    cmd_wstrb_first_in : in std_logic_vector(data_width_g/8 - 1 downto 0);
    cmd_wstrb_last_in  : in std_logic_vector(data_width_g/8 - 1 downto 0);
    cmd_ready_out        : out std_logic;

    ready_out        : out std_logic
  );
  end component;

  component dual_port_fifo
  generic (
    addrw_g : integer := 15;
    dataw_g : integer := 32);
  port (
    clk          : in std_logic;
    rstx         : in std_logic;

    write_valid_in  : in std_logic;
    write_ready_out : out std_logic;
    write_data_in   : in std_logic_vector(dataw_g-1 downto 0);

    read_ready_in   : in std_logic;
    read_valid_out  : out std_logic;
    read_data_out   : out std_logic_vector(dataw_g-1 downto 0)
    );
  end component;

  function need_last_burst(shift : std_logic_vector;
                           last_address : std_logic_vector)
  return boolean is
    variable shift_unsigned : unsigned(shift'high downto 0);
    variable addr_unsigned  : unsigned(last_address'high + 1 downto 0);
  begin
    shift_unsigned := unsigned("0" & shift(shift'high-1 downto 0));
    addr_unsigned  := unsigned("0" & last_address);
    if shift_unsigned = 0 or addr_unsigned = 0 then
      return false;
    elsif shift_unsigned + addr_unsigned > byte_count_c then
      return false;
    else
      return true;
    end if;
  end function;

  constant axburst_length_c   : integer := 8;
  constant command_fifo_addrw : integer := 3;
  constant sel_width_c        : integer := 1;
  constant byte_count_log2_c  : integer := integer(log2(real(byte_count_c)));
  -- Signed, range is -bytecount+1 to bytecount-1
  constant shift_width_c : integer := byte_count_log2_c + 1;
  constant BURST  : std_logic_vector(sel_width_c - 1 downto 0) := "0";
  constant SINGLE : std_logic_vector(sel_width_c - 1 downto 0) := "1";


  -- Write command fifo contains:
  --  * Address
  --  * Data (for single bursts)
  --  * Burst length
  --  * first and last wstrb
  --  * source
  constant write_cmd_width : integer := data_width_g + addr_width_g
                          + axburst_length_c + 2*byte_count_c + sel_width_c;
  constant write_cmd_addr_low  : integer := 0;
  constant write_cmd_addr_high : integer := write_cmd_addr_low + addr_width_g - 1;
  constant write_cmd_data_low  : integer := write_cmd_addr_high + 1;
  constant write_cmd_data_high : integer := write_cmd_data_low + data_width_g - 1;
  constant write_cmd_len_low   : integer := write_cmd_data_high + 1;
  constant write_cmd_len_high  : integer := write_cmd_len_low + axburst_length_c - 1;

  constant write_cmd_first_wstrb_low  : integer := write_cmd_len_high + 1;
  constant write_cmd_first_wstrb_high : integer := write_cmd_first_wstrb_low
                                                   + byte_count_c - 1;
  constant write_cmd_last_wstrb_low  : integer := write_cmd_first_wstrb_high
                                                  + 1;
  constant write_cmd_last_wstrb_high : integer := write_cmd_last_wstrb_low
                                                  + byte_count_c- 1;

  constant write_cmd_sel_low  : integer := write_cmd_last_wstrb_high + 1;
  constant write_cmd_sel_high : integer := write_cmd_sel_low + sel_width_c - 1;

  -- Read command fifo contains:
  --  * Address
  --  * Burst length
  --  * destination
  --  * Shift amount
  constant read_cmd_width : integer := addr_width_g + axburst_length_c
                                       + sel_width_c + shift_width_c + byte_count_log2_c;
  constant read_cmd_addr_low   : integer := 0;
  constant read_cmd_addr_high  : integer := read_cmd_addr_low + addr_width_g - 1;
  constant read_cmd_len_low    : integer := read_cmd_addr_high + 1;
  constant read_cmd_len_high   : integer := read_cmd_len_low + axburst_length_c -1;
  constant read_cmd_shift_low  : integer := read_cmd_len_high + 1;
  constant read_cmd_shift_high : integer := read_cmd_shift_low + shift_width_c - 1;
  constant read_cmd_sel_low    : integer := read_cmd_shift_high + 1;
  constant read_cmd_sel_high   : integer := read_cmd_sel_low + sel_width_c - 1;
  constant read_cmd_last_low   : integer := read_cmd_sel_high + 1;
  constant read_cmd_last_high  : integer := read_cmd_last_low + byte_count_log2_c - 1;


  signal read_ready   : std_logic;
  signal write_ready  : std_logic;
  signal r1data_r     : std_logic_vector(addr_width_g-1 downto 0);
  signal o1data_r     : std_logic_vector(addr_width_g-1 downto 0);
  signal o2data_r     : std_logic_vector(addr_width_g-1 downto 0);
  signal o1data_bp    : std_logic_vector(addr_width_g-1 downto 0);
  signal o2data_bp    : std_logic_vector(addr_width_g-1 downto 0);
  signal active_load_r : std_logic;
  signal lock_r       : std_logic;

  signal write_data        : std_logic_vector(data_width_g - 1 downto 0);
  signal write_data_valid  : std_logic;
  signal write_data_ready  : std_logic;
  signal write_length      : std_logic_vector(axburst_length_c-1 downto 0);
  signal write_address     : std_logic_vector(addr_width_g-1 downto 0);
  signal write_wstrb_first : std_logic_vector(byte_count_c-1 downto 0);
  signal write_wstrb_last  : std_logic_vector(byte_count_c-1 downto 0);
  signal write_cmd_ready   : std_logic;
  signal write_cmd_valid   : std_logic;
  signal write_cmd_fifo_ready   : std_logic;
  signal write_cmd_fifo_valid   : std_logic;
  signal write_source      : std_logic_vector(sel_width_c - 1 downto 0);

  signal read_data        : std_logic_vector(data_width_g - 1 downto 0);
  signal read_data_valid  : std_logic;
  signal read_data_last   : std_logic;
  signal read_data_ready  : std_logic;
  signal read_cmd_valid   : std_logic;
  signal read_length      : std_logic_vector(axburst_length_c-1 downto 0);
  signal read_address     : std_logic_vector(addr_width_g-1 downto 0);
  signal read_cmd_ready   : std_logic;


  signal destination_sel_r  : std_logic_vector(sel_width_c - 1 downto 0);
  signal last_address_r     : std_logic_vector(byte_count_log2_c - 1 downto 0);
  signal source_sel_r       : std_logic_vector(sel_width_c - 1 downto 0);
  signal read_shift_r       : std_logic_vector(shift_width_c-1 downto 0);

  signal reads_initiated    : unsigned(command_fifo_addrw - 1 downto 0);
  signal ar_acknowledged    : std_logic;
  signal write_started      : std_logic;


  signal burst_fifo_write_valid : std_logic;
  signal burst_fifo_write_ready : std_logic;
  signal burst_fifo_read_valid  : std_logic;
  signal burst_fifo_read_ready  : std_logic;
  signal burst_fifo_read_data   : std_logic_vector(data_width_g - 1 downto 0);

  signal shift_write_valid      : std_logic;
  signal shift_write_ready      : std_logic;
  signal shift_result           : std_logic_vector(data_width_g - 1 downto 0);
  signal shift_data_r           : std_logic_vector(data_width_g - 1 downto 0);
  signal shift_data_reset       : std_logic;
  signal shift_data_load        : std_logic;
  signal shift_data_valid_r     : std_logic;
  signal last_write             : std_logic;
  signal last_write_r           : std_logic;

  signal read_cmd_in_valid_r     : std_logic;
  signal read_cmd_in_ready       : std_logic;
  signal read_command_write_data : std_logic_vector(read_cmd_width-1 downto 0);
  signal read_command_read_data  : std_logic_vector(read_cmd_width-1 downto 0);

  signal read_cmd_in_address_r : std_logic_vector(addr_width_g-1 downto 0);
  signal read_cmd_in_length_r  : std_logic_vector(axburst_length_c-1 downto 0);
  signal read_cmd_in_shift_r   : std_logic_vector(shift_width_c-1 downto 0);
  signal read_cmd_in_sel_r     : std_logic_vector(sel_width_c - 1 downto 0);
  signal read_cmd_in_last_r    : std_logic_vector(byte_count_log2_c - 1 downto 0);

  signal result_load           : std_logic;

  signal write_cmd_in_address_r : std_logic_vector(addr_width_g-1 downto 0);
  signal write_cmd_in_data_r    : std_logic_vector(data_width_g - 1 downto 0);
  signal write_cmd_in_length_r  : std_logic_vector(axburst_length_c-1 downto 0);
  signal write_cmd_in_sel_r     : std_logic_vector(sel_width_c - 1 downto 0);

  signal single_write_data_r    : std_logic_vector(data_width_g - 1 downto 0);

  signal write_cmd_in_first_wstrb_r : std_logic_vector(byte_count_c-1 downto 0);
  signal write_cmd_in_last_wstrb_r  : std_logic_vector(byte_count_c-1 downto 0);

  signal write_cmd_in_valid_r     : std_logic;
  signal write_cmd_in_ready       : std_logic;
  signal write_command_write_data :std_logic_vector(write_cmd_width-1 downto 0);
  signal write_command_read_data  :std_logic_vector(write_cmd_width-1 downto 0);


  constant BURST_OPC  : std_logic_vector(2 - 1 downto 0) := "00";
  constant LD32_OPC   : std_logic_vector(2 - 1 downto 0) := "01";
  constant ST32_OPC   : std_logic_vector(2 - 1 downto 0) := "10";
  constant STATUS_OPC : std_logic_vector(2 - 1 downto 0) := "11";


begin

  write_channel : write_channel_axi4_master
  generic map (
    data_width_g => data_width_g,
    addr_width_g => addr_width_g)
  port map (
    clk  => clk,
    rstx => rstx,

    m_axi_awaddr  => m_axi_awaddr,
    m_axi_awcache => m_axi_awcache,
    m_axi_awlen   => m_axi_awlen,
    m_axi_awsize  => m_axi_awsize,
    m_axi_awburst => m_axi_awburst,
    m_axi_awprot  => m_axi_awprot,
    m_axi_awvalid => m_axi_awvalid(0),
    m_axi_awready => m_axi_awready(0),
    m_axi_wdata   => m_axi_wdata,
    m_axi_wstrb   => m_axi_wstrb,
    m_axi_wlast   => m_axi_wlast(0),
    m_axi_wvalid  => m_axi_wvalid(0),
    m_axi_wready  => m_axi_wready(0),
    m_axi_bvalid  => m_axi_bvalid(0),
    m_axi_bready  => m_axi_bready(0),

    data_in         => write_data,
    data_valid_in   => write_data_valid,
    data_ready_out  => write_data_ready,

    cmd_valid_in       => write_cmd_valid,
    cmd_length_in      => write_length,
    cmd_address_in     => write_address,
    cmd_wstrb_first_in => write_wstrb_first,
    cmd_wstrb_last_in  => write_wstrb_last,
    cmd_ready_out      => write_cmd_ready,

    ready_out          => write_ready
  );

  read_channel : read_channel_axi4_master
  generic map (
    data_width_g => data_width_g,
    addr_width_g => addr_width_g)
  port map (
    clk  => clk,
    rstx => rstx,

    m_axi_araddr  => m_axi_araddr,
    m_axi_arcache => m_axi_arcache,
    m_axi_arlen   => m_axi_arlen,
    m_axi_arsize  => m_axi_arsize,
    m_axi_arburst => m_axi_arburst,
    m_axi_arprot  => m_axi_arprot,
    m_axi_arvalid => m_axi_arvalid(0),
    m_axi_arready => m_axi_arready(0),

    m_axi_rdata   => m_axi_rdata,
    m_axi_rvalid  => m_axi_rvalid(0),
    m_axi_rlast   => m_axi_rlast(0),
    m_axi_rready  => m_axi_rready(0),

    data_out       => read_data,
    data_valid_out => read_data_valid,
    data_ready_in  => read_data_ready,
    data_last_out  => read_data_last,
    ar_ack_out     => ar_acknowledged,

    cmd_valid_in       => read_cmd_valid,
    cmd_length_in      => read_length,
    cmd_address_in     => read_address,
    cmd_ready_out      => read_cmd_ready,

    ready_out          => read_ready
  );

  burst_fifo : dual_port_fifo
  generic map (
   addrw_g => 9,
   dataw_g => data_width_g
  ) port map (
    clk          => clk,
    rstx         => rstx,

    write_valid_in  => burst_fifo_write_valid,
    write_ready_out => burst_fifo_write_ready,
    write_data_in   => read_data,

    read_valid_out  => burst_fifo_read_valid,
    read_ready_in   => burst_fifo_read_ready,
    read_data_out   => burst_fifo_read_data
  );

  read_command_fifo : dual_port_fifo
  generic map (
   addrw_g => command_fifo_addrw,
   dataw_g => read_cmd_width
  ) port map (
    clk          => clk,
    rstx         => rstx,

    write_valid_in  => read_cmd_in_valid_r,
    write_ready_out => read_cmd_in_ready,
    write_data_in   => read_command_write_data,

    read_valid_out  => read_cmd_valid,
    read_ready_in   => read_cmd_ready,
    read_data_out   => read_command_read_data
  );

  read_command_write_data(read_cmd_addr_high downto
                          read_cmd_addr_low) <= read_cmd_in_address_r;
  read_command_write_data(read_cmd_len_high downto
                          read_cmd_len_low) <= read_cmd_in_length_r;
  read_command_write_data(read_cmd_shift_high downto
                          read_cmd_shift_low) <= read_cmd_in_shift_r;
  read_command_write_data(read_cmd_sel_high downto
                          read_cmd_sel_low) <= read_cmd_in_sel_r;
  read_command_write_data(read_cmd_last_high downto
                          read_cmd_last_low) <= read_cmd_in_last_r;

  read_length  <= read_command_read_data(read_cmd_len_high downto
                                         read_cmd_len_low);
  read_address <= read_command_read_data(read_cmd_addr_high downto
                                         read_cmd_addr_low);

  write_command_fifo : dual_port_fifo
  generic map (
   addrw_g => command_fifo_addrw,
   dataw_g => write_cmd_width
  ) port map (
    clk          => clk,
    rstx         => rstx,

    write_valid_in  => write_cmd_in_valid_r,
    write_ready_out => write_cmd_in_ready,
    write_data_in   => write_command_write_data,

    read_valid_out  => write_cmd_fifo_valid,
    read_ready_in   => write_cmd_fifo_ready,
    read_data_out   => write_command_read_data
  );

  write_command_write_data(write_cmd_addr_high downto
                        write_cmd_addr_low) <= write_cmd_in_address_r;
  write_command_write_data(write_cmd_data_high downto
                        write_cmd_data_low) <= write_cmd_in_data_r;
  write_command_write_data(write_cmd_len_high downto
                        write_cmd_len_low) <= write_cmd_in_length_r;
  write_command_write_data(write_cmd_first_wstrb_high downto
                        write_cmd_first_wstrb_low) <= write_cmd_in_first_wstrb_r;
  write_command_write_data(write_cmd_last_wstrb_high downto
                        write_cmd_last_wstrb_low) <= write_cmd_in_last_wstrb_r;
  write_command_write_data(write_cmd_sel_high downto
                        write_cmd_sel_low) <= write_cmd_in_sel_r;

  write_length       <= write_command_read_data(write_cmd_len_high downto
                                               write_cmd_len_low);
  write_address      <= write_command_read_data(write_cmd_addr_high downto
                                               write_cmd_addr_low);
  write_wstrb_first  <= write_command_read_data(write_cmd_first_wstrb_high downto
                                               write_cmd_first_wstrb_low);
  write_wstrb_last   <= write_command_read_data(write_cmd_last_wstrb_high downto
                                               write_cmd_last_wstrb_low);
  write_source       <= write_command_read_data(write_cmd_sel_high downto
                                                write_cmd_sel_low);


  mux_demux : process(source_sel_r, destination_sel_r, single_write_data_r,
                      burst_fifo_read_data, write_data_ready,
                      burst_fifo_read_valid, read_data_valid, shift_write_ready)
  begin
     case source_sel_r is
       when SINGLE =>
         write_data            <= single_write_data_r;
         write_data_valid      <= '1';
         burst_fifo_read_ready <= '0';

       when others => -- BURST
         write_data            <= burst_fifo_read_data;
         write_data_valid      <= burst_fifo_read_valid;
         burst_fifo_read_ready <= write_data_ready;
     end case;

     case destination_sel_r is -- TODO: SHIFT
       when SINGLE =>
         result_load            <= read_data_valid;
         shift_write_valid      <= '0';
         read_data_ready        <= '1';

       when others => -- BURST
         result_load            <= '0';
         shift_write_valid      <= read_data_valid;
         read_data_ready        <= shift_write_ready;
     end case;
  end process;

  align_shift_comb : process(read_shift_r, read_data, burst_fifo_write_ready,
                             shift_write_valid, shift_data_r, shift_data_valid_r,
                             last_write_r, read_data_last, last_address_r)
    variable data_temp : std_logic_vector(data_width_g*2-1 downto 0);
    variable offset_temp : integer range 0 to byte_count_c;
  begin
    last_write       <= '0';
    shift_data_reset <= '0';
    if read_shift_r = std_logic_vector(to_unsigned(0, read_shift_r'length)) then
      shift_result           <= read_data;
      shift_write_ready      <= burst_fifo_write_ready;
      burst_fifo_write_valid <= shift_write_valid;
      shift_data_load        <= '0';
    else
      data_temp   := read_data & shift_data_r;
      offset_temp := to_integer(unsigned(read_shift_r(byte_count_log2_c-1 downto 0)));
      for I in 0 to byte_count_c - 1 loop
        shift_result(8*I+7 downto 8*I) <= data_temp(8*(I+4-offset_temp)+7 downto 8*(I+4-offset_temp));
      end loop;

      shift_write_ready      <= burst_fifo_write_ready;
      burst_fifo_write_valid <= shift_write_valid;
      shift_data_load        <= burst_fifo_write_ready and shift_write_valid;

      if last_write_r = '1' then -- The extra write scheduled in the next branch
        burst_fifo_write_valid <= '1';
        shift_write_ready      <= '0';
        shift_data_load        <= '0';
        if burst_fifo_write_ready = '1' then
          last_write       <= '0';
          shift_data_reset <= '1';
        end if;
      elsif read_data_last = '1' and shift_write_valid = '1' then
        -- On the last beat of current burst
        if need_last_burst(read_shift_r, last_address_r) then
          -- if the partial beat cut off by the shift is relevant,
          -- schedule an extra write
          last_write <= burst_fifo_write_ready and shift_write_valid;
        else -- otherwise reset the register
          shift_data_reset       <= '1';
        end if;
      elsif signed(read_shift_r) > 0 and shift_data_valid_r = '0' then
        -- First beat of current burst, and a need to
        -- wait for the next beat to have a full word
        burst_fifo_write_valid <= '0';
        shift_write_ready <= '1';
        shift_data_load <= shift_write_valid;
      end if;
    end if;
  end process;

  align_shift_sync : process(clk, rstx)
  begin
    if rstx = '0' then
      shift_data_r       <= (others => '0');
      shift_data_valid_r <= '0';
      last_write_r       <= '0';
    elsif rising_edge(clk) then
      if shift_data_reset = '1' then
        shift_data_r       <= (others => '0');
        shift_data_valid_r <= '0';
      elsif shift_data_load = '1' then
        shift_data_r       <= read_data;
        shift_data_valid_r <= '1';
      end if;
      last_write_r <= last_write;
    end if;
  end process;

  -- Stall burst write until the AR* packet has been acknowledged
  enforce_rw_ordering_comb : process(write_source, reads_initiated,
                                     write_cmd_ready, write_cmd_fifo_valid)
  begin
    write_started <= '0';
    if write_source = BURST and reads_initiated = 0 then
      write_cmd_fifo_ready <= '0';
      write_cmd_valid <= '0';
    else
      write_cmd_fifo_ready <= write_cmd_ready;
      write_cmd_valid <= write_cmd_fifo_valid;
      if write_source = BURST and write_cmd_fifo_valid = '1'
         and write_cmd_ready = '1' then
        write_started <= '1';
      end if;
    end if;
  end process;

  enforce_rw_ordering_sync : process(clk, rstx)
  begin
    if rstx = '0' then
      reads_initiated <= (others => '0');
    elsif rising_edge(clk) then
      if ar_acknowledged = '1' and destination_sel_r = BURST
         and not write_started = '1' then
        reads_initiated <= reads_initiated + 1;
      elsif write_started = '1' and not (ar_acknowledged = '1' and destination_sel_r = BURST) then
        reads_initiated <= reads_initiated - 1;
      end if;
    end if;
  end process;

  o1data_bp  <= o1data when o1load = '1' else o1data_r;
  o2data_bp  <= o2data when o2load = '1' else o2data_r;
  r1data     <= r1data_r;

  gen_lockreq : process (active_load_r, result_load, lock_r,
                         read_cmd_in_valid_r, read_cmd_in_ready,
                         write_cmd_in_valid_r, write_cmd_in_ready)
  begin
    lockreq <= '0';

    if active_load_r = '1' and result_load = '0' then
      lockreq <= '1';
    end if;

    if lock_r = '1' then
      lockreq <= '1';
    end if;

    -- Lock if full fifos are being written to
    if read_cmd_in_valid_r = '1' and read_cmd_in_ready = '0' then
      lockreq <= '1';
    end if;
    if write_cmd_in_valid_r = '1' and write_cmd_in_ready = '0' then
      lockreq <= '1';
    end if;
  end process gen_lockreq;

  fu_io_sync : process(clk, rstx)
    variable axi_burst_len   : std_logic_vector(max_burst_log2_g+1-1 downto 0);
  begin
    if rstx = '0' then
      o1data_r <= (others => '0');
      o2data_r <= (others => '0');
      r1data_r <= (others => '0');
      active_load_r    <= '0';
      lock_r           <= '0';

      read_cmd_in_address_r      <= (others => '0');
      read_cmd_in_sel_r          <= (others => '0');
      read_cmd_in_valid_r        <= '0';
      read_cmd_in_length_r       <= (others => '0');
      read_cmd_in_shift_r        <= (others => '0');
      read_cmd_in_last_r         <= (others => '0');
      write_cmd_in_length_r      <= (others => '0');
      write_cmd_in_address_r     <= (others => '0');
      write_cmd_in_sel_r         <= (others => '0');
      write_cmd_in_first_wstrb_r <= (others => '0');
      write_cmd_in_last_wstrb_r  <= (others => '0');
      write_cmd_in_valid_r       <= '0';
      write_cmd_in_data_r        <= (others => '0');

      destination_sel_r   <= (others => '0');
      single_write_data_r <= (others => '0');
      source_sel_r        <= (others => '0');
      read_shift_r        <= (others => '0');
      last_address_r      <= (others => '0');

    elsif rising_edge(clk) then
      lock_r  <= '0';
      if result_load = '1' then
        r1data_r <= read_data;
        active_load_r <= '0';
      end if;

      if     write_cmd_in_valid_r = '1'
         and write_cmd_in_ready   = '1' then
        write_cmd_in_valid_r <= '0';
      end if;

      if write_cmd_ready = '1' and write_cmd_valid = '1' then
        single_write_data_r <= write_command_read_data(write_cmd_data_high
                                                     downto write_cmd_data_low);
        source_sel_r <= write_source;
      end if;


      if     read_cmd_in_valid_r = '1'
         and read_cmd_in_ready   = '1' then
        read_cmd_in_valid_r <= '0';
      end if;

      if read_cmd_ready = '1' and read_cmd_valid = '1' then
        destination_sel_r <= read_command_read_data(read_cmd_sel_high downto
                                              read_cmd_sel_low);
        last_address_r    <= read_command_read_data(read_cmd_last_high downto
                                                    read_cmd_last_low);
        read_shift_r      <= read_command_read_data(read_cmd_shift_high downto
                                                    read_cmd_shift_low);
      end if;

      if glock = '0' then
        if o1load = '1' then
          o1data_r <= o1data;
        end if;

        if o2load = '1' then
          o2data_r <= o2data;
        end if;

        if t1load = '1' then
          case t1opcode is
            when BURST_OPC =>
              -- TODO: Cleanup
              read_cmd_in_address_r <= o1data_bp;
              read_cmd_in_sel_r     <= BURST;
              read_cmd_in_valid_r   <= '1';

              axi_burst_len :=  std_logic_vector(
                          unsigned('0' & t1data(max_burst_log2_g-1 downto 0))
                        + unsigned(o1data_bp(byte_count_log2_c-1 downto 0)));
              read_cmd_in_length_r <=
                  axi_burst_len(axi_burst_len'high-1 downto byte_count_log2_c);
              -- coverage off
              -- synthesis translate_off
              -- Should only happen with unaligned start/end points:
              assert axi_burst_len(axi_burst_len'high) = '0'
                report "A command gave a burst length of > 256"
                severity error;
              -- synthesis translate_on
              -- coverage on
              read_cmd_in_shift_r <=  std_logic_vector(
                        signed('0' & o1data_bp(byte_count_log2_c-1 downto 0))
                      - signed('0' & o2data_bp(byte_count_log2_c-1 downto 0)));

              axi_burst_len :=  std_logic_vector(
                          unsigned('0' & t1data(max_burst_log2_g-1 downto 0))
                        + unsigned(o2data_bp(byte_count_log2_c-1 downto 0)));
              write_cmd_in_length_r <=
                  axi_burst_len(axi_burst_len'high-1 downto byte_count_log2_c);
              -- coverage off
              -- synthesis translate_off
              -- Should only happen with unaligned start/end points:
              assert axi_burst_len(axi_burst_len'high) = '0'
                report "A command gave a burst length of > 256"
                severity error;
              -- synthesis translate_on
              -- coverage on
              write_cmd_in_address_r     <= o2data_bp;
              write_cmd_in_sel_r         <= BURST;
              write_cmd_in_first_wstrb_r <= write_strobe(to_integer(unsigned(o2data_bp(byte_count_log2_c-1 downto 0))), false);
              write_cmd_in_last_wstrb_r  <= write_strobe(to_integer(unsigned(axi_burst_len(byte_count_log2_c-1 downto 0))), true);
              write_cmd_in_valid_r       <= '1';

              read_cmd_in_last_r   <= axi_burst_len(byte_count_log2_c-1 downto 0);

            when LD32_OPC =>
              read_cmd_in_length_r  <= (others => '0');
              read_cmd_in_address_r <= t1data;
              read_cmd_in_sel_r     <= SINGLE;
              read_cmd_in_valid_r   <= '1';

              read_cmd_in_last_r    <= (others => '0');

              active_load_r    <= '1';
              lock_r           <= '1';

            when ST32_OPC =>

              write_cmd_in_length_r      <= (others => '0');
              write_cmd_in_address_r     <= t1data;
              write_cmd_in_sel_r         <= SINGLE;
              write_cmd_in_first_wstrb_r <= (others => '1');
              write_cmd_in_last_wstrb_r  <= (others => '1');
              write_cmd_in_data_r        <= o1data_bp;
              write_cmd_in_valid_r       <= '1';

            when others => -- STATUS_OPC
              r1data_r    <= (others => '0');
              if write_cmd_valid = '0' and write_cmd_in_valid_r = '0' and
                 read_cmd_valid  = '0' and write_cmd_in_valid_r = '0' and
                 read_ready = '1' and write_ready = '1' then
                r1data_r(0) <= '1';
              end if;
          end case;
        end if;

      end if;
    end if;
  end process fu_io_sync;

end rtl;

