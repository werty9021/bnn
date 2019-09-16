op2 <= (others => '0');
if addr_low_out_1(6) = '0' then
    op2(512 downto 0) <= rdata_out_1(511 downto 0);
else
    op2(512 downto 0) <= rdata_out_1(1023 downto 512);
end if;
