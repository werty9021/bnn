for i in 0 to 31 loop
  xnor_result := op1 xnor op2((i+1)*32-1 downto i*32);
  count := unsigned(op3((i+1)*16-1 downto i*16));
  for j in 0 to 31 loop
    if(xnor_result(j) = '1') then
      count := count + 1;
    end if;
  end loop;
  
  op4((i+1)*16-1 downto i*16) <= std_logic_vector(count);
end loop;
