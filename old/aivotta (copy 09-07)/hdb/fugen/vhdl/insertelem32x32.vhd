i := to_integer(unsigned(op3));
vec := op1;
element := op2;
vec((i+1)*32-1 downto i*32) := element;
op4 <= std_logic_vector(vec);
