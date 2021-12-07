-- A behavioral 2-input AND gate
library ieee;
use ieee.std_logic_1164.all;

entity and2 is port(
	a,b:	in std_logic;
	y:	out std_logic);
end;

architecture archand2 of and2 is
	begin
	process(a,b)
	begin
	if (a='1' and b='1') then
		y <= '1';
	else
		y <= '0';
	end if;
	end process;
end;
 
library ieee;
use ieee.std_logic_1164.all;
package and2_pkg is
	component and2 port(
		a,b: 	in std_logic;
		y: 	out std_logic);
	end component;
end;
 