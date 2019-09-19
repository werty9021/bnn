for i in 0 to 31 loop
  if(i = to_integer(unsigned(op3(4 downto 0)))) then
    op4((i+1)*32-1 downto i*32) <= op2(31 downto 0);
  else
    op4((i+1)*32-1 downto i*32) <= op1((i+1)*32-1 downto i*32);
  end if;
end loop;
