for i in 0 to 31 loop
  op3((i+1)*32-1 downto i*32) <= std_logic_vector(shift_left(unsigned(op1((i+1)*32-1 downto i*32)), to_integer(unsigned(op2(4 downto 0)))));
end loop;
