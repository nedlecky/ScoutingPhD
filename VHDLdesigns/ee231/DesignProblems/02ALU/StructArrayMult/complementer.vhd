-- 2's Complement of N-bit input
-- Ned Lecky 1/24/98
-- Implements "if any bit on your right is one, invert yourself" algorithm
library ieee;
use ieee.std_logic_1164.all;

entity complementer is
	generic( width: integer := 10);
	port(
	x:	in std_logic_vector(width-1 downto 0);
	y:	out std_logic_vector(width-1 downto 0));
end complementer;

architecture arch of complementer is
	signal rightones: std_logic_vector(width-1 downto 0);
	begin
	
	-- rightones(i) gets 1 iff a bit to the right is 1
	rightones(0)<='0';  -- bit 0 has nothing on the right
	gen: for i in 1 to width-1 generate
		rightones(i)<=rightones(i-1) or x(i-1);
	end generate;

	-- invert bits if any on their right are 1
	gen2: for i in 0 to width-1 generate
		y(i)<=x(i) xor rightones(i);
	end generate;
end arch;

library ieee;
use ieee.std_logic_1164.all;
package complementer_pkg is
	component complementer
	generic( width: integer := 10);
	port(
	x:	in std_logic_vector(width-1 downto 0);
	y:	out std_logic_vector(width-1 downto 0));
	end component;
end;
