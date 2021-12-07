LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;

ENTITY ilatch IS

   PORT( 			-- Input Signals	
			A, B 				: IN std_logic;
		 			-- Output Signals
			Output1, Output2 	: OUT std_logic);

END ilatch;

ARCHITECTURE behavior OF ilatch IS
BEGIN
	PROCESS (A, B)
	BEGIN
		IF A = '0' THEN 
			Output1 <= '0';
			Output2 <= '0'; 
		ELSE 
			IF B = '1' THEN
				Output1 <= '1';
				Output2 <= '1';
			ELSE
				Output1 <= '0';
			END IF;
		END IF;
	END PROCESS;
END behavior;

