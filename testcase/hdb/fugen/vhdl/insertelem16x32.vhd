for i in 0 to 31 loop
  if(i = to_integer(unsigned(op3(4 downto 0)))) then
    op4((i+1)*16-1 downto i*16) <= op2(15 downto 0);
  else
    op4((i+1)*16-1 downto i*16) <= op1((i+1)*16-1 downto i*16);
  end if;
end loop;
