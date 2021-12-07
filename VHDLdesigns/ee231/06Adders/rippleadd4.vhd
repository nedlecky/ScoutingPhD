-- 4-bit Ripple Adder
-- Uses ha and fa components defined as components directly in the architecture

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY rippleadd4 IS
	PORT
	(
		x,y	: IN	STD_LOGIC_VECTOR(3 downto 0);
		s	: OUT	STD_LOGIC_VECTOR(4 downto 0)
	);
END rippleadd4;

ARCHITECTURE arch OF rippleadd4 IS
	-- defining the components here avoids the package definition
	COMPONENT ha
		PORT
		(
			x,y		: IN	STD_LOGIC;
			s,c		: OUT	STD_LOGIC
		);
	END COMPONENT;
	COMPONENT fa IS
		PORT
		(
			x,y,cin	: IN	STD_LOGIC;
			s,cout	: OUT	STD_LOGIC
		);
	END COMPONENT;
	SIGNAL c : STD_LOGIC_VECTOR(2 downto 0);
BEGIN
	-- build 4-bit ripple adder, no initial carry in
	-- final carry out just dumps into sum MSB
	ha1: ha PORT MAP (x(0),y(0),s(0),c(0));
	fa1: fa PORT MAP (x(1),y(1),c(0),s(1),c(1));
	fa2: fa PORT MAP (x(2),y(2),c(1),s(2),c(2));
	fa3: fa PORT MAP (x(3),y(3),c(2),s(3),s(4));
END arch;

