avalid_in_1 <= '1';
aaddr_in_1 <= op1(addrw_c-1 downto 0);
awren_in_1 <= '1';
astrb_in_1 <= (others => '0');
astrb_in_1(to_integer(unsigned(op1(6 downto 2))*4+3 downto unsigned(op1(6 downto 2))*4)) <= "1111";
adata_in_1 <= (others => '0');
adata_in_1(to_integer(unsigned(op1(6 downto 2)))*32+31 downto to_integer(unsigned(op1(6 downto 2)))*32) <= op2;
