for i in 0 to 31 loop
  out_v := signed(op3((i+1)*32-1 downto i*32)) + signed(op1((i+1)*16-1 downto i*16)) * signed(op2((i+1)*16-1 downto i*16));
  op4((i+1)*32-1 downto i*32) <= std_logic_vector(out_v);
end loop;
