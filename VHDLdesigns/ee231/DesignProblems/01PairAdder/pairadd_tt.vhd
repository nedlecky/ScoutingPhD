-- pairadd_tt.vhd
-- PairAdd from Truth Table
-- Truth Tables and VHDL code portions generated automatically
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;	-- pulls in conv_integer

entity pairadd_tt IS
	port
	(
		a,b			: in	std_logic_vector(1 downto 0);
		c			: in	std_logic;
		s			: out	std_logic_vector(2 downto 0)
	);
	
end pairadd_tt;

architecture a of pairadd_tt is
	signal composite : std_logic_vector(4 downto 0);
begin
	composite <= a & b & c;

	-- sum bit truth tables from GenTT.cpp
	with conv_integer(composite)select
        s(2) <= '1' when 7|13|14|15|19|20|21|22|23|25|26|27|28|29|30|31,
        '0' when others;

	with conv_integer(composite)select
        s(1) <= '1' when 3|4|5|6|9|10|11|12|16|17|18|23|24|29|30|31,
        '0' when others;

	with conv_integer(composite)select
        s(0) <= '1' when 1|2|5|6|8|11|12|15|17|18|21|22|24|27|28|31,
        '0' when others;
end a;

