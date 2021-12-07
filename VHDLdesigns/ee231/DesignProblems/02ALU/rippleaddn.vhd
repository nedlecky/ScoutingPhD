-- n-bit Ripple Adder
-- Uses generate with ha amd fa components
-- also passes back carry(n-1) for overflow assistance

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY rippleaddn IS
	GENERIC
	(
		width : integer := 16
	);
	PORT
	(
		x,y		: IN	STD_LOGIC_VECTOR(width-1 downto 0);
		s		: OUT	STD_LOGIC_VECTOR(width downto 0);
		cnm1	: OUT	STD_LOGIC -- second MSB carry
	);
END rippleaddn;

ARCHITECTURE arch OF rippleaddn IS
	COMPONENT ha
		PORT
		(
			x,y	: IN	STD_LOGIC;
			s,c	: OUT	STD_LOGIC
		);
	END COMPONENT;
	COMPONENT fa IS
		PORT
		(
			x,y,cin	: IN	STD_LOGIC;
			s,cout	: OUT	STD_LOGIC
		);
	END COMPONENT;
	-- intermediate wires for carry handoffs
	SIGNAL c : STD_LOGIC_VECTOR(width-1 downto 0);
BEGIN
	-- the LSB
	ha1: ha port map (x(0),y(0),s(0),c(0));

	-- loop to instantiate remaining bits
	middlegen: FOR bitpos IN 1 to width-1 GENERATE
		fa1: fa port map (x(bitpos),y(bitpos),c(bitpos-1),s(bitpos),c(bitpos));
	END GENERATE;

	-- grab that last carry out and slam it into sum MSB
	s(width) <= c(width-1);

	-- second to last carry
	cnm1 <= c(width-2);
END arch;

