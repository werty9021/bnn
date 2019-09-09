for i in 0 to 31 loop
  if (i = 0) then
    sum := signed(op1((i+1)*32-1 downto i*32));  
  else
    sum := sum + signed(op1((i+1)*32-1 downto i*32));
  end if;
end loop;
op2 <= std_logic_vector(sum);
