-- 8 Puzzle Solver
-- J.E. Lecky 10-99

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity p3x3 is port
	(
		clk:	in std_logic;
		reinit:	in std_logic;
		init:	in std_logic_vector(35 downto 0);
		solved:	out std_logic;
		fireclr_out: out std_logic_vector(8 downto 0);
		match_out: out std_logic_vector(8 downto 0)
	);
end;

architecture p3x3_arch of p3x3 is
	component square4 port(
		clk:	in std_logic;
		clr:	in std_logic;
		reinit:	in std_logic;
		rand:	in std_logic_vector(1 downto 0);
		goal:	in std_logic_vector(3 downto 0);
		init:	in std_logic_vector(3 downto 0);
		in0:	in std_logic_vector(3 downto 0);
		in1:	in std_logic_vector(3 downto 0);
		in2:	in std_logic_vector(3 downto 0);
		in3:	in std_logic_vector(3 downto 0);
		clr0:	out std_logic;
		clr1:	out std_logic;
		clr2:	out std_logic;
		clr3:	out std_logic;
		output:	out std_logic_vector(3 downto 0);
		match:	out std_logic);
	end component;
	component square3 port(
		clk:	in std_logic;
		clr:	in std_logic;
		reinit:	in std_logic;
		rand:	in std_logic_vector(1 downto 0);
		goal:	in std_logic_vector(3 downto 0);
		init:	in std_logic_vector(3 downto 0);
		in0:	in std_logic_vector(3 downto 0);
		in1:	in std_logic_vector(3 downto 0);
		in2:	in std_logic_vector(3 downto 0);
		clr0:	out std_logic;
		clr1:	out std_logic;
		clr2:	out std_logic;
		output:	out std_logic_vector(3 downto 0);
		match:	out std_logic);
	end component;
	component square2 port(
		clk:	in std_logic;
		clr:	in std_logic;
		reinit:	in std_logic;
		rand:	in std_logic_vector(1 downto 0);
		goal:	in std_logic_vector(3 downto 0);
		init:	in std_logic_vector(3 downto 0);
		in0:	in std_logic_vector(3 downto 0);
		in1:	in std_logic_vector(3 downto 0);
		clr0:	out std_logic;
		clr1:	out std_logic;
		output:	out std_logic_vector(3 downto 0);
		match:	out std_logic);
	end component;
	subtype cur4 is std_logic_vector(3 downto 0);
	type cur_vector is array(natural range <>) of cur4;
	signal clr01,clr03,clr10,clr12,clr14,clr21,clr25,clr30,clr34,clr36,clr41,
		clr43,clr45,clr47,clr52,clr54,clr58,clr63,clr67,clr74,clr76,clr78,clr85,clr87:
		std_logic;
	signal goal: 	std_logic_vector(35 downto 0);
	signal cur: 	cur_vector(0 to 8);
	signal match:	std_logic_vector(8 downto 0);
	signal fireclr:	std_logic_vector(8 downto 0);
	type randosc is array(0 to 1) of std_logic_vector(1 downto 0);
	signal flippybits:	randosc;
	signal rand:	std_logic_vector(1 downto 0);
begin
	-- random number generator
	flippybits(0) <= not flippybits(0);
	flippybits(1) <= not flippybits(1);
--	flippybits(0) <= "00";
--	flippybits(1) <= "00";

	-- latch random number on clock
	process (clk)
	begin
		if rising_edge(clk) then
--			rand<=rand+1;
			rand<=flippybits(0) xor flippybits(1);
		end if;
	end process;

	-- establish goal state
	-- 1 2 3
	-- 8 0 4
	-- 7 6 5
	goal <= x"1" & x"23804765"; -- 32-bit hex conversion limitation!

	fireclr(0) <= clr01 or clr03;
	fireclr(1) <= clr10 or clr12 or clr14;
	fireclr(2) <= clr21 or clr25;
	fireclr(3) <= clr30 or clr34 or clr36;
	fireclr(4) <= clr41 or clr43 or clr45 or clr47;
	fireclr(5) <= clr52 or clr54 or clr58;
	fireclr(6) <= clr63 or clr67;
	fireclr(7) <= clr74 or clr76 or clr78;
	fireclr(8) <= clr85 or clr87;
	fireclr_out <= fireclr;
	solved <= '1' when match="111111111" else '0';
	match_out <= match;

	s0: square2 port map(clk,fireclr(0),reinit,rand,goal(35 downto 32),init(35 downto 32),
			cur(1),cur(3),
			clr10,clr30,
			cur(0),match(0));
	s1: square3 port map(clk,fireclr(1),reinit,rand,goal(31 downto 28),init(31 downto 28),
			cur(0),cur(2),cur(4),
			clr01,clr21,clr41,
			cur(1),match(1));
	s2: square2 port map(clk,fireclr(2),reinit,rand,goal(27 downto 24),init(27 downto 24),
			cur(1),cur(5),
			clr12,clr52,
			cur(2),match(2));
	s3: square3 port map(clk,fireclr(3),reinit,rand,goal(23 downto 20),init(23 downto 20),
			cur(0),cur(4),cur(6),
			clr03,clr43,clr63,
			cur(3),match(3));
	s4: square4 port map(clk,fireclr(4),reinit,rand,goal(19 downto 16),init(19 downto 16),
			cur(1),cur(3),cur(5),cur(7),
			clr14,clr34,clr54,clr74,
			cur(4),match(4));
	s5: square3 port map(clk,fireclr(5),reinit,rand,goal(15 downto 12),init(15 downto 12),
			cur(2),cur(4),cur(8),
			clr25,clr45,clr85,
			cur(5),match(5));
	s6: square2 port map(clk,fireclr(6),reinit,rand,goal(11 downto 8),init(11 downto 8),
			cur(3),cur(7),
			clr36,clr76,
			cur(6),match(6));
	s7: square3 port map(clk,fireclr(7),reinit,rand,goal(7 downto 4),init(7 downto 4),
			cur(4),cur(6),cur(8),
			clr47,clr67,clr87,
			cur(7),match(7));
	s8: square2 port map(clk,fireclr(8),reinit,rand,goal(3 downto 0),init(3 downto 0),
			cur(5),cur(7),
			clr58,clr78,
			cur(8),match(8));
end;
 

