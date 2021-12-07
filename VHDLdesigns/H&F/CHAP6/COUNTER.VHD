LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY Counter IS

   PORT( 				-- Input Signals	
			Clock, Reset		: IN std_logic;
			Max_count			: IN std_logic_vector(7 DOWNTO 0);
					 	-- Output Signals
			Count 				: OUT std_logic_vector(7 DOWNTO 0));

END Counter;

ARCHITECTURE behavior OF Counter IS
						-- declare signal internal to module here
SIGNAL internal_count: std_logic_vector(7 DOWNTO 0);

BEGIN
  count <= internal_count;
  PROCESS (Reset,Clock)
	BEGIN
						-- reset counter
	IF reset = '1' THEN 
		internal_Count <= "00000000"; 
	ELSIF (clock'EVENT and clock='1') THEN
						-- Check for maximum count
		IF internal_count < Max_count THEN
						-- Increment Counter
			internal_count <= internal_count + 1;
						-- Count >=  Max_Count so reset Counter
		ELSE
			internal_Count <= "00000000";
		END IF;
	END IF;
  END PROCESS;
END behavior;

