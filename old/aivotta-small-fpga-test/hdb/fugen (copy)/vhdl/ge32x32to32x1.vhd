for i in 0 to 31 loop
  if signed(op1((i+1)*32-1 downto i*32)) >= signed(op2((i+1)*32-1 downto i*32)) then
    result(i) := '1';
  else
    result(i) := '0';
  end if;
end loop;
op3 <= result;
