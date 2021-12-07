-- An Edge-Triggered Write-enabled D Flip-Flop
-- Ned Lecky 2/16/98

library ieee;
use ieee.std_logic_1164.all;

entity dflop is port(
	d:	in std_logic;
	q:	buffer std_logic;
	clk,en:	in std_logic);
end;

architecture dflop_arch of dflop is
	begin
	write: process(clk,d,en,q) begin
		if (rising_edge(clk)) then
			if (en='1') then
				q <= d;
			end if;
		end if;
	end process;
end;
 
library ieee;
use ieee.std_logic_1164.all;
package dflop_pkg is
	component dflop port(
	d:	in std_logic;
	q:	buffer std_logic;
	clk,en:	in std_logic);
	end component;
end;
