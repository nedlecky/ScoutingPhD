-- An edge-triggered D Flip-flop with load
library ieee;
use ieee.std_logic_1164.all;

entity dflop is port(
	d,oe,clk:	in std_logic;
	q:		out std_logic);
end;

architecture archdflop of dflop is
begin
	process(d,oe,clk)
		variable internal_d: std_logic;
	begin
		if (clk'event and clk= '1') then
			internal_d := d;
		end if;
--		if (oe = '1') then
			q<=internal_d;
--		else
--			q<='Z';
--		end if;
	end process;
end;
 
library ieee;
use ieee.std_logic_1164.all;
package dflop_pkg is
	component dflop port(
		d,oe,clk: 	in std_logic;
		q:		out std_logic);
	end component;
end;
