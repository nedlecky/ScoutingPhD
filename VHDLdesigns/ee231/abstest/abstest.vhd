library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library lpm;
use lpm.lpm_components.all;

entity abstest is
	port(
		a													: in	std_logic_vector(7 downto 0);
		b													: out	std_logic_vector(7 downto 0)
	);
end abstest;

architecture a of abstest is
begin
	abscomp: lpm_abs
	GENERIC MAP (lpm_width => 8) 
	PORT MAP (data => a, result => b); 
end a;

