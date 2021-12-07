-- reg2.vhd
-- a 2-bit register with select and enable
library ieee;
use ieee.std_logic_1164.all;
use work.and2_pkg.all;
use work.dflop_pkg.all;

entity reg2 is port(
	d0,d1,cs,oe,clk:	in std_logic;
	q0,q1:			OUT std_logic);
end;

architecture archreg2 of reg2 is
	signal clk_en: std_logic;
	begin
	g1: and2 port map(a=>cs,b=>clk,y=>clk_en);
	d0: dflop port map(d=>d0,clk=>clk_en,oe=>oe,q=>q0);
	d1: dflop port map(d=>d1,clk=>clk_en,oe=>oe,q=>q1);
end;
