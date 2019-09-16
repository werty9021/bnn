avalid_in_1 <= '1';
aaddr_in_1 <= op1(addrw_c-1 downto 0);
awren_in_1 <= '1';
if op1(6) = '0' then
  astrb_in_1 <= (1023 downto 521 => '0', 511 downto 0 => '1');
  adata_in_1 <= (511 downto 0 => '0') & op2;
else
  astrb_in_1 <= (1023 downto 521 => '1', 511 downto 0 => '0');
  adata_in_1 <= op2 & (511 downto 0 => '0');
end if;
