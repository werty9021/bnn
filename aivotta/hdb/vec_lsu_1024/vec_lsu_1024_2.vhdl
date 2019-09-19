-- Copyright (c) 2017 Tampere University of Technology.
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
-- Title      : LSU for AlmaIF Integrator. Modified for sync reset for FPGAs
-- Project    : Almarvi
-------------------------------------------------------------------------------
-- File       : fu_lsu_32b_sync.vhdl
-- Author     : Aleksi Tervo
-- Company    :
-- Created    : 2017-05-31
-- Last update: 2019-07-22
-- Platform   :
-------------------------------------------------------------------------------
-- Description: 32xN bit wide SIMD LSU with parametric endianness
--              External ports:
--  | Signal     | Comment
--  ---------------------------------------------------------------------------
--  |            | Access channel
--  | avalid_out | LSU asserts avalid when it has a valid command for the memory
--  | aready_in  | and considers the command accepted when both avalid and
--  |            | aready are asserted on the same clock cycle
--  |            |
--  | aaddr_out  | Address of the access, word-addressed
--  | awren_out  | High for write, low for read
--  | astrb_out  | Bytewise write strobe
--  | adata_out  | Data to write, if any
--  |            |
--  |            | Response channel
--  | rvalid_in  | Works like avalid/aready, in the other direction. The memory
--  | rready_out | must keep read accesses in order.
--  |            |
--  | rdata_in   | Read data, if any.
--  ---------------------------------------------------------------------------
--
-- Revisions  :
-- Date        Version  Author  Description
-- 2017-05-31  1.0      tervoa  Created
-- 2018-09-12  1.1      tervoa  Modified for synchronous reset
-- 2018-09-13  1.2      tervoa  Extended to SIMD operation, removed superfluous
--                              operations
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fu_lsu_simd_32 is
  generic (
    addrw_g           : integer := 11
  );
  port(
    clk           : in std_logic;
    rstx          : in std_logic;

    -- Control signals
    glock_in      : in std_logic;
    glockreq_out  : out std_logic;

    -- Address port, triggers
    t1_address_in : in  std_logic_vector(addrw_g-1 downto 0);
    t1_load_in    : in  std_logic;
    t1_opcode_in  : in  std_logic_vector(3 downto 0);
    -- Data operand and output ports
    o1_data_in    : in  std_logic_vector(1024-1 downto 0);
    o1_load_in    : in  std_logic;

    r1_data_out   : out std_logic_vector(1024-1 downto 0);
    r2_data_out   : out std_logic_vector(32-1 downto 0);
    -- external memory unit interface:
    -- Access channel
    avalid_out    : out std_logic_vector(0 downto 0);
    aready_in     : in  std_logic_vector(0 downto 0);
    aaddr_out     : out std_logic_vector(addrw_g-7-1 downto 0);
    awren_out     : out std_logic_vector(0 downto 0);
    astrb_out     : out std_logic_vector(1028/8-1 downto 0);
    adata_out     : out std_logic_vector(1024-1 downto 0);
    -- Read channel
    rvalid_in     : in  std_logic_vector(0 downto 0);
    rready_out    : out std_logic_vector(0 downto 0);
    rdata_in      : in  std_logic_vector(1024-1 downto 0)
  );
end fu_lsu_simd_32;

architecture rtl of fu_lsu_simd_32 is

  type operation_t is (LOAD, STORE, NOP);
  type width_t is (W_1024, W_512, W_32, W_16, W_8);
  type pipeline_state_t is record
      operation   : operation_t;
      width       : width_t;
      addr_low    : std_logic_vector(7-1 downto 0);
  end record;

  -------------------------------------------------------------------------
  -- register_bypass_c: if element n is '1', bypass corresponding registers
  --  n  |  register name | description
  -- ----------------------------------------------------------------------
  --  0  |  rdata_r       | Registers rdata_in
  --  1  |  result_r      | FU output port register
  -------------------------------------------------------------------------
  constant data_width_c : integer := 32*32;
  constant byte_width_c : integer := data_width_c/8;

  type pipeline_regs_t is array (4-1 downto 0) of pipeline_state_t;
  signal pipeline_r    : pipeline_regs_t;

  signal o1_data_r      : std_logic_vector(data_width_c - 1 downto 0);
  signal write_data     : std_logic_vector(data_width_c - 1 downto 0);
  signal glockreq       : std_logic;
  signal fu_glock       : std_logic;

  -- Access channel registers
  signal avalid_r    : std_logic;
  signal aaddr_r     : std_logic_vector(aaddr_out'range);
  signal awren_r     : std_logic;
  signal astrb_r     : std_logic_vector(astrb_out'range);
  signal adata_r     : std_logic_vector(adata_out'range);
  signal rready_r    : std_logic;

  -- Signals between memory and LSU output
  signal read_data      : std_logic_vector(data_width_c - 1 downto 0);
  signal rdata_r        : std_logic_vector(data_width_c - 1 downto 0);
  signal result_long_r  : std_logic_vector(data_width_c - 1 downto 0);
  signal result_mid_r   : std_logic_vector(128 - 1 downto 0);
  signal result_short_r : std_logic_vector(32 - 1 downto 0);

  -- LE opcodes for the switch statements
  constant OPC_LD1024  : integer := 0;
  constant OPC_LD16    : integer := 1;
  constant OPC_LD32    : integer := 2;
  constant OPC_LD512   : integer := 3;
  constant OPC_LD8     : integer := 4;
  constant OPC_ST1024  : integer := 5;
  constant OPC_ST16    : integer := 6;
  constant OPC_ST32    : integer := 7;
  constant OPC_ST512   : integer := 8;
  constant OPC_ST8     : integer := 9;
begin

  avalid_out(0) <= avalid_r;
  awren_out(0)  <= awren_r;
  aaddr_out     <= aaddr_r;
  astrb_out     <= astrb_r;
  adata_out     <= adata_r;
  rready_out(0) <= rready_r;

  shadow_registers_sync : process(clk)
  begin
    if rising_edge(clk) then
      if rstx = '0' then
        o1_data_r      <= (others => '0');
      elsif fu_glock = '0' then
        if o1_load_in = '1' then
          o1_data_r  <= o1_data_in;
        end if;
      end if;
    end if;
  end process;

  write_data <= o1_data_in when o1_load_in = '1' else o1_data_r;

  gen_lockreq : process(rready_r, rvalid_in, avalid_r, aready_in,
                        glock_in, glockreq)
  begin
    if    (rready_r = '1' and rvalid_in(0) = '0')
       or (avalid_r = '1' and aready_in(0) = '0') then
      glockreq <= '1';
    else
      glockreq <= '0';
    end if;

    fu_glock     <= glockreq or glock_in;
    glockreq_out <= glockreq;
  end process gen_lockreq;

-------------------------------------------------------------------------------
-- Byte shifts and enable signal logic based on most recent opcode
-------------------------------------------------------------------------------
  access_channel_sync : process(clk)
    variable opcode : integer range 0 to 9;
    variable addr_low : std_logic_vector(7-1 downto 0);
    variable elem_offset : integer range 128-1 downto 0;
  begin
    if rising_edge(clk) then
      if rstx = '0' then
        pipeline_r  <= (others => (NOP, W_1024, (others => '0')));
        aaddr_r     <= (others => '0');
        astrb_r     <= (others => '0');
        adata_r     <= (others => '0');
        avalid_r    <= '0';
        awren_r     <= '0';
      else

        if avalid_r = '1' and aready_in(0) = '1' then
          avalid_r <= '0';
        end if;

        if fu_glock = '0' then
          pipeline_r(pipeline_r'high downto 1)
              <= pipeline_r(pipeline_r'high-1 downto 0);

          if t1_load_in = '1' then
            avalid_r <= '1';
            aaddr_r  <= t1_address_in(t1_address_in'high downto 7);
            opcode   := to_integer(unsigned(t1_opcode_in));
            addr_low := t1_address_in(7 - 1 downto 0);
            astrb_r <= (others => '0');
            case opcode is
              when OPC_LD1024 =>
                pipeline_r(0)  <= (LOAD, W_1024, addr_low);
                awren_r        <= '0';
              when OPC_LD8 =>
                pipeline_r(0)  <= (LOAD, W_8, addr_low);
                awren_r        <= '0';
              when OPC_LD16 =>
                pipeline_r(0)  <= (LOAD, W_16, addr_low);
                awren_r        <= '0';
              when OPC_LD32 =>
                pipeline_r(0)  <= (LOAD, W_32, addr_low);
                awren_r        <= '0';
              when OPC_LD512 =>
                pipeline_r(0)  <= (LOAD, W_512, addr_low);
                awren_r        <= '0';

              when OPC_ST1024 =>
                pipeline_r(0)  <= (STORE, W_1024, addr_low);

                awren_r        <= '1';
                astrb_r        <= (others => '1');
                adata_r        <= write_data;
              
              when OPC_ST8 =>
                pipeline_r(0)  <= (STORE, W_8, addr_low);

                awren_r        <= '1';
                elem_offset := to_integer(unsigned(addr_low));

                astrb_r(elem_offset downto elem_offset) <= "1";
                adata_r  <= (others => '0');
                adata_r(8*elem_offset + 7 downto 8*elem_offset)
                            <= write_data(8 - 1 downto 0);

              when OPC_ST16 =>
                pipeline_r(0)  <= (STORE, W_16, addr_low);

                awren_r        <= '1';
                elem_offset := to_integer(unsigned(addr_low(addr_low'high downto 1)));

                astrb_r(elem_offset*2+1 downto elem_offset*2) <= "11";
                adata_r  <= (others => '0');
                adata_r(16*elem_offset + 15 downto 16*elem_offset)
                            <= write_data(16 - 1 downto 0);

              when OPC_ST32 =>
                pipeline_r(0)  <= (STORE, W_32, addr_low);

                awren_r        <= '1';
                elem_offset := to_integer(unsigned(addr_low(addr_low'high downto 2)));

                astrb_r(elem_offset*4+3 downto elem_offset*4) <= "1111";
                adata_r  <= (others => '0');
                adata_r(32*elem_offset + 31 downto 32*elem_offset)
                            <= write_data(32 - 1 downto 0);

              when others => -- OPC_ST512
                pipeline_r(0)  <= (STORE, W_512, addr_low);
                awren_r        <= '1';

                if addr_low(addr_low'high) = '1' then
                  astrb_r(128-1 downto 64) <= (others => '1');
                  adata_r  <= (others => '0');
                  adata_r(1024-1 downto 512) <= write_data(512 - 1 downto 0);
                else
                  astrb_r(64-1 downto 0) <= (others => '1');
                  adata_r  <= (others => '0');
                  adata_r(512-1 downto 0) <= write_data(512 - 1 downto 0);
                end if;
            end case;
          else
            pipeline_r(0)  <= (NOP, W_1024, (others => '0'));
            avalid_r       <= '0';
            awren_r        <= '0';
            aaddr_r        <= (others => '0');
            astrb_r        <= (others => '0');
            adata_r        <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process access_channel_sync;

  read_channel_sync : process(clk)
  begin
    if rising_edge(clk) then
      if rstx = '0'then
        rready_r <= '0';
        rdata_r  <= (others => '0');
      else
        if rvalid_in = "1" and rready_r = '1' then
          rdata_r       <= rdata_in;
          rready_r      <= '0';
        end if;

        if pipeline_r(0).operation = LOAD and fu_glock = '0' then
          rready_r <= '1';
        end if;
      end if;
    end if;
  end process read_channel_sync;

  read_data <= rdata_r;

-------------------------------------------------------------------------------
-- Read data formatting based on load type
-------------------------------------------------------------------------------
  shift : process(clk)
    variable elem_offset : integer range 16-1 downto 0;
    variable addr_low : std_logic_vector(7-1 downto 0);
  begin
    if rising_edge(clk) then
      if rstx = '0' then
        result_long_r    <= (others => '0');
        result_short_r   <= (others => '0');
        result_mid_r     <= (others => '0');
      else
        if pipeline_r(pipeline_r'high-1).operation = LOAD then
          addr_low := pipeline_r(pipeline_r'high-1).addr_low;
          case pipeline_r(pipeline_r'high-1).width is

            when W_1024 =>
              result_long_r <= read_data;

            when W_512  =>
              result_long_r <= (others => '0');
              if addr_low(addr_low'high) = '1' then
                result_long_r(512-1 downto 0) <= read_data(1024-1 downto 512);
              else
                result_long_r(512-1 downto 0) <= read_data(512-1 downto 0);
              end if;


            when others =>
              elem_offset := to_integer(unsigned(addr_low(addr_low'high downto 4)));
              result_mid_r <= read_data(128*elem_offset + 127 downto
                                        128*elem_offset);
          end case;
        end if;

        if pipeline_r(pipeline_r'high).operation = LOAD then
          addr_low := pipeline_r(pipeline_r'high).addr_low;
          case pipeline_r(pipeline_r'high).width is
            when W_32 =>
              elem_offset := to_integer(unsigned(addr_low(3 downto 2)));
              result_short_r <= result_mid_r(32*elem_offset + 31 downto
                                             32*elem_offset);

            when W_16 =>
              elem_offset := to_integer(unsigned(addr_low(3 downto 1)));
              result_short_r <= (others => '0');
              result_short_r(16-1 downto 0) <= result_mid_r(16*elem_offset + 15
                                                     downto 16*elem_offset);

            when W_8 =>
              elem_offset := to_integer(unsigned(addr_low(3 downto 0)));
              result_short_r <= (others => '0');
              result_short_r(8-1 downto 0) <= result_mid_r(8*elem_offset + 7
                                                    downto 8*elem_offset);
            when others =>
          end case;

        end if;
      end if;
    end if;
  end process shift;

  r1_data_out <= result_long_r;
  r2_data_out <= result_short_r;

end rtl;
