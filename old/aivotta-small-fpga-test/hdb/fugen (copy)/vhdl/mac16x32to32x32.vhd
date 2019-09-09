for i in 0 to 31 loop
  a                         := signed(op1((i+1)*16-1 downto i*16));
  b                         := signed(op2((i+1)*16-1 downto i*16));
  c                         := signed(op3((i+1)*32-1 downto i*32));
  mul                       := a * b;
  out_v                       := c + mul;
  result((i+1)*32-1 downto i*32) := std_logic_vector(out_v);
end loop;
op4 <= result;
