for i in 0 to 31 loop
  a_v                         := signed(op1((i+1)*16-1 downto i*16));
  b_v                         := signed(op2((i+1)*16-1 downto i*16));
  c_v                         := signed(op3((i+1)*32-1 downto i*32));
  mul_v                       := a_v * b_v;
  out_v                       := b_v + mul_v;
  op4((i+1)*32-1 downto i*32) <= std_logic_vector(out_v);
end loop;
