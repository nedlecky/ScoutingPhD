LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 
LIBRARY lpm ;
USE lpm.lpm_components.all ;

ENTITY shift IS
	PORT ( 	Clock 			: IN 	STD_LOGIC ;
			Reset 			: IN 	STD_LOGIC ;
			Shiftin, Load	: IN 	STD_LOGIC ;
			R				: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			Q				: OUT 	STD_LOGIC_VECTOR(3 DOWNTO 0) ) ;
END shift ;

ARCHITECTURE Structure OF shift IS
BEGIN
	instance: lpm_shiftreg
		GENERIC MAP (LPM_WIDTH => 4, LPM_DIRECTION => "RIGHT")
		PORT MAP (data => R, clock => Clock, aclr => Reset,
			load => Load, shiftin => Shiftin, q => Q ) ;
END Structure ;

