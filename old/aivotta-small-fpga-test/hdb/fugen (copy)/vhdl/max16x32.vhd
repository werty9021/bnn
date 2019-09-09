for i in 0 to 31 loop
  if signed(op1((i+1)*16-1 downto i*16)) > signed(op2((i+1)*16-1 downto i*16)) then
    result((i+1)*16-1 downto i*16) := op1((i+1)*16-1 downto i*16);
  else
    result((i+1)*16-1 downto i*16) := op2((i+1)*16-1 downto i*16);
  end if;
end loop;
op3 <= result;
