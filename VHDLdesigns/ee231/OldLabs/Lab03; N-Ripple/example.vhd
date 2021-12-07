-- An Example Using the n-Bit Ripple Adder
-- Add three 3-bit numbers to make a 5-bit number
library ieee;
use ieee.std_logic_1164.all;
use work.nripple_pkg.all;

entity example is
	generic(n: integer := 8);
	port(
	a,b,c:	in std_logic_vector(n-1 downto 0);
	sum:	out std_logic_vector(n+1 downto 0));
end;

architecture example_arch of example is
	signal add1: std_logic_vector(n downto 0);
	signal augc: std_logic_vector(n downto 0);
	signal zero: std_logic;
	begin
		zero<='0';	-- a hard 0 to use for cin
		augc<='0' & c;  -- an extended c for the second add
		
		-- first adder adds a+b
		r1: nripple generic map (n)
			port map(a=>a,b=>b,cin=>zero,sum=>add1);

		-- second adds (a+b) + c
		r2: nripple generic map(n+1)
			port map(a=>add1,b=>augc,cin=>zero,sum=>sum);
end;
