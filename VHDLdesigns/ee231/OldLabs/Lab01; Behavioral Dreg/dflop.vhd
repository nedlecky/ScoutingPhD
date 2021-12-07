-- dflop.vhd
-- A level-sensitive D Flip-flop
library ieee;
use ieee.std_logic_1164.all;

entity dflop is port(
	d,clk:		in std_logic;
	q:		OUT std_logic);
end;

architecture archdflop of dflop is
	signal state: std_logic;
begin
	process(d,clk,state)

	begin
		if (clk= '1') then
			q <= d;
		end if;
	end process;
end;
