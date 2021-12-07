-- pair_pairadd_tt.vhd
-- Pair of PairAdd from Truth Table
-- Also adds a zero-detector one one of the instances
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;

entity pair_pairadd_tt IS
	port
	(
		a1,a2,b1,b2	: in	std_logic_vector(1 downto 0);
		c1,c2		: in	std_logic;
		s1,s2		: out	std_logic_vector(2 downto 0);
		ZF			: out	std_logic
	);
	
end pair_pairadd_tt;

architecture a of pair_pairadd_tt is
	component pairadd_tt
		port(
			a,b			: in	std_logic_vector(1 downto 0);
			c			: in	std_logic;
			s			: out	std_logic_vector(2 downto 0)
		);
	end component;
	signal s2_int : std_logic_vector(s2'range); -- nice way to make s2_int and s2 same range
begin
	pair1: pairadd_tt port map (a1,b1,c1,s1);
	pair2: pairadd_tt port map (a2,b2,c2,s2_int);
	ZF <= not(s2_int(0) or s2_int(1) or s2_int(2));
	s2 <= s2_int;
end a;

