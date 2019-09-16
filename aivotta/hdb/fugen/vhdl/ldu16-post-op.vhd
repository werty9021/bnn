op2 <= (others => '0');
op2(15 downto 0) <= rdata_out_1(to_integer(unsigned(addr_low_out_1(7 downto 1)))*16+15 downto to_integer(unsigned(addr_low_out_1(7 downto 1)))*16);
