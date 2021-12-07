LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
LIBRARY work ;
USE work.mux4to1_package.all ;

ENTITY mux16to1 IS
	PORT (	w 	: IN 	STD_LOGIC_VECTOR(0 TO 15) ;
			s 	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			f 	: OUT 	STD_LOGIC ) ;
END mux16to1 ;

ARCHITECTURE Structure OF mux16to1 IS	
	SIGNAL m : STD_LOGIC_VECTOR(0 TO 3) ;
BEGIN
	Mux1: mux4to1 PORT MAP 
		( w(0), w(1), w(2), w(3), s(1 DOWNTO 0), m(0) ) ;
	Mux2: mux4to1 PORT MAP 
		( w(4), w(5), w(6), w(7), s(1 DOWNTO 0), m(1) ) ;
	Mux3: mux4to1 PORT MAP 
		( w(8), w(9), w(10), w(11), s(1 DOWNTO 0), m(2) ) ;
	Mux4: mux4to1 PORT MAP 
		( w(12), w(13), w(14), w(15), s(1 DOWNTO 0), m(3) ) ;
	Mux5: mux4to1 PORT MAP 
		( m(0), m(1), m(2), m(3), s(3 DOWNTO 2), f ) ;
END Structure ;
