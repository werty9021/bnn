-- Copyright (c) 2016 Tampere University
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

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity dual_port_fifo is generic (
    addrw_g : integer := 15;
    dataw_g : integer := 32);
  port (
    clk      : in std_logic;
    rstx     : in std_logic;

    write_valid_in  : in std_logic;
    write_ready_out : out std_logic;
    write_data_in   : in std_logic_vector(dataw_g-1 downto 0);

    read_ready_in   : in std_logic;
    read_valid_out  : out std_logic;
    read_data_out   : out std_logic_vector(dataw_g-1 downto 0)
  );
end dual_port_fifo;

architecture rtl of dual_port_fifo is

constant fifo_length_c : integer := 2**addrw_g;

type ram_type is array (fifo_length_c-1 downto 0) of std_logic_vector
                                              (dataw_g - 1 downto 0);
signal ram_data : std_logic_vector(dataw_g - 1 downto 0);


signal write_enable : std_logic;

signal write_ready_r : std_logic;
signal read_valid_r  : std_logic;
signal read_iter_r   : unsigned(addrw_g-1 downto 0);
signal write_iter_r  : unsigned(addrw_g-1 downto 0);

signal write_ready   : std_logic;
signal read_valid    : std_logic;
signal read_iter     : unsigned(addrw_g-1 downto 0);
signal write_iter    : unsigned(addrw_g-1 downto 0);

signal RAM_ARR        : ram_type;


begin
  write_ready_out <= write_ready_r;
  read_valid_out  <= read_valid_r;
  write_enable    <= write_valid_in and write_ready_r;

  fifo_ctrl_comb : process(write_enable, write_iter_r,
                           read_iter_r, read_ready_in, read_valid_r,
                           read_iter, write_iter)
  begin
    if write_enable = '1' then
      write_iter <= write_iter_r + 1;
    else
      write_iter <= write_iter_r;
    end if;

    if read_ready_in = '1' and read_valid_r = '1' then
      read_iter  <= read_iter_r + 1;
    else
      read_iter  <= read_iter_r;
    end if;

    if read_iter = write_iter + 1 then
      write_ready <= '0';
    else
      write_ready <= '1';
    end if;

    if read_iter = write_iter then
      read_valid <= '0';
    else
      read_valid <= '1';
    end if;
  end process;

  fifo_ctrl_sync : process(clk, rstx)
  begin
    if rstx = '0' then
      write_iter_r  <= (others => '0');
      read_iter_r   <= (others => '0');
      write_ready_r <= '0';
      read_valid_r  <= '0';
    elsif rising_edge(clk) then
      write_ready_r <= write_ready;
      read_valid_r  <= read_valid;
      read_iter_r   <= read_iter;
      write_iter_r  <= write_iter;
    end if;
  end process;

  fifo_mem : process(clk, rstx)
  begin
      if rstx = '0' then
        ram_data   <= (others => '0');
      elsif(clk'event and clk = '1') then
          if write_enable = '1' then
              RAM_ARR(to_integer(write_iter_r)) <= write_data_in;
          end if;

          if read_iter = write_iter_r and write_enable = '1' then
            ram_data <= write_data_in;
          else
            ram_data <= RAM_ARR(to_integer(read_iter));
          end if;
      end if;
  end process;

  read_data_out <= ram_data;
end rtl;
