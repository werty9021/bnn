for i in 0 to 31 loop
  a_v                         := unsigned(op1((i+1)*32-1 downto i*32));
  b_v                         := unsigned('0' & op2((i+1)*8-1 downto i*8));
  count_v                     := unsigned(op3);
  xnor_result_v               := a_v xnor b_v;

  for j in 0 to 31 loop
    if(xnor_result_v(j) = '1') then
      count_v := count_v + 1;
    end if;
  end loop;
  
  op4((i+1)*16-1 downto i*16) <= std_logic_vector(count_v);
end loop;
