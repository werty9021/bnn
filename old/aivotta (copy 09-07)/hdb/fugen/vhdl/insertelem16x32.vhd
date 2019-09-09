i := to_integer(unsigned(op3));
vec := op1;
element := op2;
vec((i+1)*16-1 downto i*16) := element;
op4 <= std_logic_vector(vec);
