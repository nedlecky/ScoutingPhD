-- Traditional Full Adder
-- Ned Lecky 1/24/98
library ieee;
use ieee.std_logic_1164.all;

entity fulladder is port(
	a,b,cin:	in std_logic;
	sum,cout:	out std_logic);
end fulladder;

architecture arch of fulladder is
	signal s,c: std_logic;
begin
	s <= a xor b xor cin;
	c <= (a and b) or (b and cin) or (a and cin);
	sum<=s;
	cout<=c;
end arch;
 
library ieee;
use ieee.std_logic_1164.all;
package fulladder_pkg is
	component fulladder port(
		a,b,cin: 	in std_logic;
		sum,cout: 	out std_logic);
	end component;
end package;
 
