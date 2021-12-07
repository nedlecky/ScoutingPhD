-- 02Combinational Example, continued
-- Using "combinational" to build a higher-level function

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE mypackage IS
	COMPONENT combinational
		PORT
		(
			a,b,c		: IN	STD_LOGIC;
			f1,f2,f3	: OUT	STD_LOGIC
		);
	END COMPONENT;
END mypackage;

LIBRARY work;
USE work.mypackage.all;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY combinationalPlusG IS
	PORT
	(
		a,b,c	: IN	STD_LOGIC;
		f,g		: OUT	STD_LOGIC
	);
	
END combinationalPlusG ;

ARCHITECTURE arch OF combinationalPlusG IS
	-- use f0 since VHDL can't read outputs
	SIGNAL f0 : std_logic;
BEGIN
	-- Version 1: Explicit Map
	--comb1: combinational 
	--	PORT MAP (a => a,b => b,c => c,f1 => f0);

	-- Version 2: Implicit Map
	comb1: combinational
		PORT MAP (a,b,c,f0);
		
	g <= f0 or (not a and not b and not c);
	f <= f0;
END arch;

