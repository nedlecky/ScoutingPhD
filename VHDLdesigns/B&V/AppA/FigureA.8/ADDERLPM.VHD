LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
LIBRARY lpm ;
USE lpm.lpm_components.all ;

ENTITY adderLPM IS
	PORT ( 	Cin 	: IN 	STD_LOGIC ;
			X, Y	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			S		: OUT 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			Cout	: OUT 	STD_LOGIC ) ;
END adderLPM ;

ARCHITECTURE Structure OF adderLPM IS
BEGIN
	instance: lpm_add_sub
		GENERIC MAP (LPM_WIDTH => 4)
		PORT MAP (
			dataa => X, datab => Y, Cin => Cin, result => S, Cout => Cout ) ;
END Structure ;
