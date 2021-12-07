-- An N-bit 2's complement absolute value circuit
-- Ned Lecky 1/24/98
-- Uses complementer circuit if input is negative
-- Returns unsigned number with top (sign) bit stripped off
library ieee;
use ieee.std_logic_1164.all;
use work.complementer_pkg.all;

entity absolute is
	generic( width: integer := 4);
	port(
	x:	in std_logic_vector(width-1 downto 0);
	y:	out std_logic_vector(width-2 downto 0));
end absolute;

architecture arch of absolute is
	signal xbar: std_logic_vector(width-1 downto 0);
	begin
	-- wire up the complementer so we have x and xbar
	c: complementer generic map (width)
		port map(x=>x,y=>xbar);
	process
	begin
		-- grab bottom width-1 bits of either x or xbar
		if(x(x'high)='1') then
			y<=xbar(width-2 downto 0);
		else
			y<=x(width-2 downto 0);
		end if;
	end process;
end arch;

library ieee;
use ieee.std_logic_1164.all;
package absolute_pkg is
	component absolute
	generic( width: integer := 4);
	port(
	x:	in std_logic_vector(width-1 downto 0);
	y:	out std_logic_vector(width-2 downto 0));
	end component;
end;
