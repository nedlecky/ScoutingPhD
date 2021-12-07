-- 8 Puzzle Solver
-- J.E. Lecky 10-99

library ieee;
use ieee.std_logic_1164.all;

entity p3x3 is port(
	clk:	in std_logic;
	reinit:	in std_logic;
	rand:	in std_logic_vector(1 downto 0);
	init:	in std_logic_vector(35 downto 0);
	solved:	out std_logic);
end;

use work.square_pkg.all;
architecture p3x3_arch of p3x3 is
	subtype cur4 is std_logic_vector(3 downto 0);
	type cur_vector is array(natural range <>) of cur4;
	type clr_vector is array(0 to 8,0 to 8) of std_logic;
	signal goal: 	std_logic_vector(35 downto 0);
	signal cur: 	cur_vector(0 to 8);
	signal clr: 	clr_vector;
	signal match:	std_logic_vector(8 downto 0);
	signal fireclr:	std_logic_vector(8 downto 0);
begin
	-- establish goal state
	-- 1 2 3
	-- 8 0 4
	-- 7 6 5
	goal <= "000100100011100000000100011101100101";

	fireclr(0) <= clr(0,1) or clr(0,3);
	fireclr(1) <= clr(1,0) or clr(1,2) or clr(1,4);
	fireclr(2) <= clr(2,1) or clr(2,5);
	fireclr(3) <= clr(3,0) or clr(3,4) or clr(3,6);
	fireclr(4) <= clr(4,1) or clr(4,3) or clr(4,5) or clr(4,7);
	fireclr(5) <= clr(5,2) or clr(5,4) or clr(5,8);
	fireclr(6) <= clr(6,3) or clr(6,7);
	fireclr(7) <= clr(7,4) or clr(7,6) or clr(7,8);
	fireclr(8) <= clr(8,5) or clr(8,7);
	solved <= match(0) and match(1) and match(2) and match(3)
		and match(4) and match(5) and match(6) and match(7) and match(8);
	s0: square2 port map(clk,fireclr(0),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(1),cur(3),
			clr(1,0),clr(3,0),
			cur(0),match(0));
	s1: square3 port map(clk,fireclr(1),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(0),cur(2),cur(4),
			clr(0,1),clr(2,1),clr(4,1),
			cur(1),match(1));
	s2: square2 port map(clk,fireclr(2),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(1),cur(5),
			clr(1,2),clr(5,2),
			cur(2),match(2));
	s3: square3 port map(clk,fireclr(3),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(0),cur(4),cur(6),
			clr(0,3),clr(4,3),clr(6,3),
			cur(3),match(3));
	s4: square4 port map(clk,fireclr(4),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(1),cur(3),cur(5),cur(7),
			clr(1,4),clr(3,4),clr(5,4),clr(7,4),
			cur(4),match(4));
	s5: square3 port map(clk,fireclr(5),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(2),cur(4),cur(8),
			clr(2,5),clr(4,5),clr(8,5),
			cur(5),match(5));
	s6: square2 port map(clk,fireclr(6),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(3),cur(7),
			clr(3,6),clr(7,6),
			cur(6),match(6));
	s7: square3 port map(clk,fireclr(7),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(4),cur(6),cur(8),
			clr(4,7),clr(6,7),clr(8,7),
			cur(7),match(7));
	s8: square2 port map(clk,fireclr(8),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(5),cur(7),
			clr(5,8),clr(7,8),
			cur(8),match(8));
end;
 
library ieee;
use ieee.std_logic_1164.all;
package p3x3_pkg is
	component p3x3 port(
		clk:	in std_logic;
		reinit:	in std_logic;
		rand:	in std_logic_vector(1 downto 0);
		goal:	in std_logic_vector(35 downto 0);
		init:	in std_logic_vector(35 downto 0);
		solved:	out std_logic);
	end component;
end;
 