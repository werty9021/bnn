for i in 0 to 31 loop
  if unsigned(op1((i+1)*16-1 downto i*16)) >= unsigned(op2((i+1)*16-1 downto i*16)) then
    op3(i) <= '1';
  else
    op3(i) <= '0';
  end if;
end loop;
