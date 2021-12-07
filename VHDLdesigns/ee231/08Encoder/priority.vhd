-- 08Encoder Example
-- 4-input Priority Encoder

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY priority IS
	PORT (	w 	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			y	: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0) ;
			z	: OUT 	STD_LOGIC ) ;
END priority ;

ARCHITECTURE Behavior OF priority IS
BEGIN
	-- sequential implementation
	PROCESS ( w )
	BEGIN
		-- Will setup "default" output and modify below since sequential
		-- note this will generate warnings, though
		y <= "00" ;
		IF w(1) = '1' THEN y <= "01" ; END IF ;
		IF w(2) = '1' THEN y <= "10" ; END IF ;
		IF w(3) = '1' THEN y <= "11" ; END IF ;

		if w="0000" then z <= '0'; else z <= '1'; end if;
	END PROCESS ;
END Behavior ;
