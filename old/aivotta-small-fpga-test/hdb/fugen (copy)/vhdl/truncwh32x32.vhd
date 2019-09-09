for i in 0 to 31 loop
  result((i+1)*16-1 downto i*16) := op1((i+1)*32-17 downto i*32);
end loop;
op2 <= result;
