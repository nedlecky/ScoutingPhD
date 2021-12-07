library ieee;
use ieee.std_logic_1164.all;

entity and10 is port(
	inbus:	in std_logic_vector(9 downto 0);
	x:	inout std_logic;
	y:	inout std_logic);
end;

architecture and10_arch of and10 is
begin
	y <= x and inbus(0) and inbus(1) and inbus(2) and inbus(3) and inbus(4) and inbus(5) and inbus(6) and inbus(7) and inbus(8) and inbus(9);
	x <= not x;
end;	
