-- An edge-triggered D Flip-flop
library ieee;
use ieee.std_logic_1164.all;

entity dflop is port(
	d,clk:	in std_logic;
	q:	OUT std_logic);
end;

architecture archdflop of dflop is
begin
	process(d,clk)
	begin
		if (clk'event and clk= '1') then
			q <= d;
		end if;
	end process;
end;
 
library ieee;
use ieee.std_logic_1164.all;
package dflop_pkg is
	component dflop port(
		d,clk: 	in std_logic;
		q:	out std_logic);
	end component;
end;
