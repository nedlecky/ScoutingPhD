-- 8-bit Ripple Adder
-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;

entity rippleadd8 is
	port
	(
		x,y		: in	std_logic_vector(7 downto 0);
		cin		: in	std_logic;
		s		: out	std_logic_vector(7 downto 0);
		cout	: out	std_logic
	);
end rippleadd8;

architecture arch of rippleadd8 is
	component fa is
		port
		(
			x,y,cin	: in	std_logic;
			s,cout	: out	std_logic
		);
	end component;
	signal c : std_logic_vector(8 downto 0);
begin
	c(0) <= cin;	-- carry in hookup
	adder: for i in 0 to 7 generate
		fa_i: fa port map (x(i),y(i),c(i),s(i),c(i+1));
	end generate;
	cout <= c(8);	-- carry out hookup

end arch;

