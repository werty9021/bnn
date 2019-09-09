-- Copyright (c) 2002-2015 Tampere University of Technology.
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
-- Title      : (Multi-)TTA-core testbench template
-- Project    : TCE
-------------------------------------------------------------------------------
-- File       : multicore_testbench.vhdl
-- Author     : Henry Linjam�ki  <linjamah@kauluskeiju.cs.tut.fi>
-- Company    :
-- Created    : 2015-09-08
-- Last update: 2016-04-11
-- Platform   :
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2015
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-09-08  1.0      linjamah    Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_arith.all;
use std.textio.all;
use work.tta0_globals.all;
use work.tta0_imem_mau.all;

entity testbench is
end testbench;

architecture behavior of testbench is

  constant core_count_c : integer := 1;

  component clkgen
    generic (
      PERIOD : time);
    port (
      clk : out std_logic;
      en  : in  std_logic := '1');
  end component;

  signal clk : std_logic := '1';

  component proc
    port (
      clk     : in  std_logic;
      rstx    : in  std_logic;
      
      locked  : out std_logic_vector(core_count_c-1 downto 0));
  end component;

  signal rstx   : std_logic;

  type   counter_array_t is array (0 to core_count_c-1) of integer;
  signal execution_count_reg : counter_array_t := (others => 0);
  signal enable_clock        : std_logic       := '1';
  signal lock_status_wire    : std_logic_vector(core_count_c-1 downto 0);

begin

  clock : clkgen
    generic map (
      PERIOD => PERIOD)
    port map (
      clk => clk,
      en  => enable_clock);

  dut : proc
    port map (
      clk     => clk,
      rstx    => rstx,
      
      locked  => lock_status_wire);

  run_test : process
  begin
    rstx   <= '0';
    -- Lower rstx a little after a clock edge so its clear on wich side reset
    -- lift off occurs.
    wait for (PERIOD*2 + PERIOD/10);
    rstx   <= '1';
    -- Test runs until requested amount of instructions have been executed or
    -- stopped by simulation script.
    wait;
  end process;

  -- purpose: Counts executed instructions per core
  -- type   : sequential
  -- inputs : clk, rstx
  -- outputs: execution_count_reg
  execution_counter : process (clk, rstx)
  begin  -- process execution_counter
    if rstx = '0' then                 -- asynchronous reset (active low)
      execution_count_reg <= (others => 0);
    elsif clk'event and clk = '1' then  -- rising clock edge
      for i in 0 to core_count_c-1 loop
        if lock_status_wire(i) = '0' then
          execution_count_reg(i) <= execution_count_reg(i) + 1;
        end if;
      end loop;  -- i
    end if;
  end process execution_counter;

  -- purpose: Controls clock generation. At beginning of the simulation the
  --          clock is enabled. If execution limit is defined then the clock
  --          will be stopped causing simulation to end.
  -- type   : combinational
  -- inputs : execution_count_reg
  -- outputs: enable_clock
  clock_control : process
    file execution_limit_file_v : text;
    variable line_v             : line;
    variable good_v             : boolean := false;
    variable open_status_v      : file_open_status;
    variable execution_limit_v  : integer := -1;
    variable all_finished_v     : boolean := false;
  begin  -- process clock_control
    file_open(open_status_v, execution_limit_file_v,
              "execution_limit", read_mode);
    if open_status_v = open_ok and not endfile(execution_limit_file_v) then
      readline(execution_limit_file_v, line_v);
      read(line_v, execution_limit_v, good_v);
      if not good_v then
        execution_limit_v := -2;
      end if;
    end if;

    -- If execution limit is not defined then keep clock running indefinitely.
    if execution_limit_v < 0 then
      wait;
    end if;

    -- Finish simulation is all cores have executed the set amount of
    -- instructions.
    while not all_finished_v loop
      wait until clk'event and clk = '1';
      all_finished_v := execution_count_reg(0) >= execution_limit_v;
      for i in 1 to core_count_c-1 loop
        all_finished_v := all_finished_v and
                          execution_count_reg(i) >= execution_limit_v;
      end loop;  -- i
    end loop;

    enable_clock <= '0';
    wait;

  end process clock_control;

end behavior;


