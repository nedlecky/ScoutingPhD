-- regb.vhd
-- Two bit register with CS and OE (behavioral version)
library ieee;
use ieee.std_logic_1164.all;

entity regb2 is port(
	d:		in std_logic_vector(1 downto 0);
	cs,oe,clk:	in std_logic;
	q:		out std_logic_vector(1 downto 0));
end;

architecture archregb2 of regb2 is
--	signal state: std_logic_vector(1 downto 0);
begin
	process(clk,cs,oe,d)

	begin
		if (clk='1' and cs='1') then
			q<=d;
		end if;
		if (oe='1') then
			--q<=state;
		else
			q<="ZZ";
		end if;
	end process;
end;
