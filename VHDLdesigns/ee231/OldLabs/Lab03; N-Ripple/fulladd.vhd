-- Full Adder
library ieee;
use ieee.std_logic_1164.all;

entity full_adder is port(
	a,b,cin:	in std_logic;
	sum,cout:	out std_logic);
end;

architecture full_adder_arch of full_adder is
	begin
	sum <= a xor b xor cin;
	cout <= (a and b) or (b and cin) or (a and cin);
end;
 
library ieee;
use ieee.std_logic_1164.all;
package full_adder_pkg is
	component full_adder port(
		a,b,cin: 	in std_logic;
		sum,cout: 	out std_logic);
	end component;
end;
 