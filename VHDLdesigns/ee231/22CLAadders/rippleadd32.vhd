-- 32-bit Ripple Adder
-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;

entity rippleadd32 is
	port
	(
		x,y		: in	std_logic_vector(31 downto 0);
		cin		: in	std_logic;
		s		: out	std_logic_vector(31 downto 0);
		cout	: out	std_logic
	);
end rippleadd32;

architecture arch of rippleadd32 is
	component fa is
		port
		(
			x,y,cin	: in	std_logic;
			s,cout	: out	std_logic
		);
	end component;
	signal c : std_logic_vector(32 downto 0);
begin
	c(0) <= cin;	-- carry in hookup
	adder: for i in 0 to 31 generate
		fa_i: fa port map (x(i),y(i),c(i),s(i),c(i+1));
	end generate;
	cout <= c(32);	-- carry out hookup

end arch;

