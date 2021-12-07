-- and2.vhd
-- A simple 2-input AND gate
library ieee;
use ieee.std_logic_1164.all;

entity and2 is port(
	a,b:	in std_logic;
	y:	out std_logic);
end;

architecture archand2 of and2 is
	begin
	y <= a and b;
end;
 