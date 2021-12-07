-- Full and Half Adders for Signed Multiplier
-- John E. Lecky 2/10/98
library ieee;
use ieee.std_logic_1164.all;
entity FA is port(
	a,b,cin:	in std_logic;
	sum,cout:	out std_logic);
end;

library ieee;
use ieee.std_logic_1164.all;
entity FAMMP is port(
	a,b,cin:	in std_logic;
	sum,cout:	out std_logic);
end;

library ieee;
use ieee.std_logic_1164.all;
entity HA is port(
	a,b:		in std_logic;
	sum,cout:	out std_logic);
end;

library ieee;
use ieee.std_logic_1164.all;
entity HAMP is port(
	a,b:		in std_logic;
	sum,cout:	out std_logic);
end;

architecture FA_arch of FA is
	signal s,c: std_logic;
	attribute synthesis_off of s,c: signal is true;
	begin
	s <= a xor b xor cin;
	c <= (a and b) or (b and cin) or (a and cin);
	sum<=s;
	cout<=c;
end;

architecture FAMMP_arch of FAMMP is
	signal s,c: std_logic;
	attribute synthesis_off of s,c: signal is true;
	begin
	s <= a xor b xor cin;
	c <= (a and b) or (a and not cin) or (b and not cin);
	sum<=s;
	cout<=c;
end;

architecture HA_arch of HA is
	signal s,c: std_logic;
	attribute synthesis_off of s,c: signal is true;
	begin
	s <= a xor b;
	c <= a and b;
	sum<=s;
	cout<=c;
end;

architecture HAMP_arch of HAMP is
	signal s,c: std_logic;
	attribute synthesis_off of s,c: signal is true;
	begin
	s <= a xor b;
	c <= a and not b;
	sum<=s;
	cout<=c;
end;
 
library ieee;
use ieee.std_logic_1164.all;
package adders_pkg is
	component FA port(
		a,b,cin: 	in std_logic;
		sum,cout: 	out std_logic);
	end component;
	component FAMMP port(
		a,b,cin: 	in std_logic;
		sum,cout: 	out std_logic);
	end component;
	component HA port(
		a,b:	 	in std_logic;
		sum,cout: 	out std_logic);
	end component;
	component HAMP port(
		a,b:	 	in std_logic;
		sum,cout: 	out std_logic);
	end component;
end;
 