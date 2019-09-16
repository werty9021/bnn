op2 <= (others => '0');
op2(7 downto 0) <= rdata_out_1(to_integer(unsigned(addr_low_out_1))*8+7 downto to_integer(unsigned(addr_low_out_1))*8);
