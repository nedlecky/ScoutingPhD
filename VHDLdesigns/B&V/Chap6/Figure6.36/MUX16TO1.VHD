LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE work.mux4to1_package.all ;

ENTITY mux16to1 IS
	PORT (	w	: IN 	STD_LOGIC_VECTOR(0 TO 15) ;
			s 	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			f 	: OUT 	STD_LOGIC ) ;
END mux16to1 ;

ARCHITECTURE Structure OF mux16to1 IS
	SIGNAL m : STD_LOGIC_VECTOR(0 TO 3) ;
BEGIN
	G1: FOR i IN 0 TO 3 GENERATE
		Muxes: mux4to1 PORT MAP (
			w(4*i), w(4*i+1), w(4*i+2), w(4*i+3), s(1 DOWNTO 0), m(i) ) ;
	END GENERATE ;
	Mux5: mux4to1 PORT MAP ( m(0), m(1), m(2), m(3), s(3 DOWNTO 2), f ) ;
END Structure ;
