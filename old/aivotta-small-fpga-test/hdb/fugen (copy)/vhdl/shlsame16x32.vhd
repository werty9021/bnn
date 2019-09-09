for i in 0 to 31 loop
  result((i+1)*16-1 downto i*16) := std_logic_vector(shift_left(unsigned(op1((i+1)*16-1 downto i*16)), to_integer(unsigned(op2))));
end loop;
op3 <= result;
