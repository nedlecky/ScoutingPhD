		-- Includes Libraries for standard logic data types
LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;

		-- Entity name normally the same as file name
ENTITY gate_network IS

		-- Port declaration - declares module inputs and outputs
   PORT( -- Input Signals	
			A, B, C 		: IN std_logic;
		 -- Standard Logic Vector (Array of Bits)
        	D 				: IN std_logic_vector(3 DOWNTO 0);
		 -- Output Signals
			X,Y 			: OUT std_logic);
   END gate_network;

		-- defines internal module architecture
ARCHITECTURE behavior OF gate_network IS
BEGIN

		-- concurrent assignment statements operate in parallel
		-- D(1) selects bit 1 of standard logic vector D
	X <= A AND NOT(B OR C) AND (D(1) XOR D(2));

		-- Process must declare a sensitivity list
		-- Sensitivity list includes all signals which can change the outputs
PROCESS (A,B,C,D)
	BEGIN
		-- Statements inside a process execute in sequential order
		Y <= A AND NOT(B OR C) AND (D(1) XOR D(2));
	END PROCESS;

END behavior;

