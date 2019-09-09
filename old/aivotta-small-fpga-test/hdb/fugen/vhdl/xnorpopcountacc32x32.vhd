xnor_result := op1 xnor op2;
-- 
-- for i in 0 to 31 loop
--   count                     := unsigned(op3((i+1)*16-1 downto i*16));
--   for j in 0 to 31 loop
--     if(xnor_result(i*32 + j) = '1') then
--       count := count + 1;
--     end if;
--   end loop;
--   
--   op4((i+1)*16-1 downto i*16) <= std_logic_vector(count);
-- end loop;

op4 <= xnor_result;
