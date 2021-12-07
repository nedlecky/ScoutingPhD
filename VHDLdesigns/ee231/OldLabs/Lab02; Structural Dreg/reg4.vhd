-- reg4.vhd
-- Structural 4-bit register with select
library ieee;
use ieee.std_logic_1164.all;
use work.and2_pkg.all;
use work.dflop_pkg.all;

entity reg2 is port(
	d:	in std_logic_vector(3 downto 0);
	cs,clk:	in std_logic;
	q:	OUT std_logic_vector(3 downto 0));
end;

architecture archreg2 of reg2 is
	signal clk_en: std_logic;  -- output of the AND gate
	begin
	g1: and2 port map(a=>cs,b=>clk,y=>clk_en);
	d0: dflop port map(d=>d(0),clk=>clk_en,q=>q(0));
	d1: dflop port map(d=>d(1),clk=>clk_en,q=>q(1));
	d2: dflop port map(d=>d(2),clk=>clk_en,q=>q(2));
	d3: dflop port map(d=>d(3),clk=>clk_en,q=>q(3));
end;
