-- 05ifelsecombinational Example
-- Several ways of generating abs(a-b)

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY behaviorcombo IS
	PORT
	(
		a,b			: IN	integer range 0 to 7;
		f1,f2,f3	: OUT	integer range 0 to 7
	);
	
END behaviorcombo ;

ARCHITECTURE a OF behaviorcombo IS
	signal inputs : std_logic_vector(5 downto 0);
	signal outs : std_logic_vector(2 downto 0);
BEGIN
	-- Direct attack, thank you VHDL
	f1 <= a-b when a>b else b-a when b>a else 0;

	-- Direct attack, writting like a C program (bad)
	process (a,b)
	begin
		if a>b then
			f2 <= a-b;
		elsif b>a then
			f2 <= b-a;
		else
			f2 <= 0;
		end if;
	end process;

	-- Core level design based on first principles
	-- Where did the truth tables come from?  GenTT.cpp
	inputs <= conv_std_logic_vector(a,3) & conv_std_logic_vector(b,3);
	with conv_integer(inputs) select
		outs(2) <= '1' when 4|5|6|7|13|14|15|22|23|31|32|40|41|48|49|50|56|57|58|59,
			'0' when others;

	with conv_integer(inputs) select
		outs(1) <= '1' when 2|3|6|7|11|12|15|16|20|21|24|25|29|30|33|34|38|39|42|43|
							47|48|51|52|56|57|60|61,
			'0' when others;

	with conv_integer(inputs) select
		outs(0) <= '0' when 0|2|4|6|9|11|13|15|16|18|20|22|25|27|29|31|32|34|36|38|41|
							43|45|47|48|50|52|54|57|59|61|63,
			'1' when others;
	f3 <= conv_integer(outs);
END a;

