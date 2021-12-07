LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY lpm ;
USE lpm.lpm_components.all ;

ENTITY adderlpm IS
	PORT (	Cin 	: IN 	STD_LOGIC ;
			A, B 	: IN 	STD_LOGIC_VECTOR(15 DOWNTO 0) ;
			Sum 	: OUT 	STD_LOGIC_VECTOR(15 DOWNTO 0) ;
			Cout 	: OUT 	STD_LOGIC ) ;
END adderlpm ;

ARCHITECTURE Structure OF adderlpm IS
BEGIN
	instance: lpm_add_sub
		GENERIC MAP (LPM_WIDTH => 16)
		PORT MAP (	cin => Cin, dataa => A, datab => B, 
			result => Sum, cout => Cout ) ;
END Structure ;
