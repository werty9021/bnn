sum := to_unsigned(0, 32)
for i in 0 to 31 loop
  sum := sum + unsigned(op1((i+1)*32-1 downto i*32));
end loop;
op2 <= std_logic_vector(sum);
