avalid_in_1 <= '1';
aaddr_in_1 <= op1(addrw_c-1 downto 0);
awren_in_1 <= '1';
astrb_in_1 <= (others => '0');
astrb_in_1(to_integer(unsigned(op1(6 downto 0)))) <= '1';
adata_in_1 <= (others => '0');
adata_in_1(to_integer(unsigned(op1(6 downto 0)))*8+7 downto to_integer(unsigned(op1(6 downto 0)))*8) <= op2;
