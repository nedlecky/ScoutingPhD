
LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY hierarch IS
	PORT (clock_25Mhz, pb1 : IN STD_LOGIC;
		  pb1_single_pulse : OUT STD_LOGIC);
END hierarch;
ARCHITECTURE a OF hierarch IS
-- Declare internal signals needed to connect submodules
SIGNAL clock_1MHz, clock_100Hz, pb1_debounced : STD_LOGIC;
-- Use Components to Define Submodules and Parameters
	COMPONENT debounce
		PORT(pb, clock_100Hz : IN	STD_LOGIC;
	         pb_debounced	: OUT	STD_LOGIC);
	END COMPONENT;	 
	
	COMPONENT onepulse
		PORT(pb_debounced, clock	: IN	STD_LOGIC;
			 pb_single_pulse		: OUT	STD_LOGIC);
	END COMPONENT;

	COMPONENT clk_div
		PORT(clock_25Mhz				: IN	STD_LOGIC;
		clock_1MHz				: OUT	STD_LOGIC;
		clock_100KHz			: OUT	STD_LOGIC;
		clock_10KHz				: OUT	STD_LOGIC;
		clock_1KHz				: OUT	STD_LOGIC;
		clock_100Hz				: OUT	STD_LOGIC;
		clock_10Hz				: OUT	STD_LOGIC;
		clock_1Hz				: OUT	STD_LOGIC);
	END COMPONENT;									
BEGIN

-- Use Port Map to connect signals between components in the hiearchy
debounce1 : debounce PORT MAP  (pb => pb1, clock_100Hz => clock_100Hz,
			pb_debounced => pb1_debounced);

prescalar : clk_div  PORT MAP (clock_25Mhz => clock_25Mhz, clock_1MHz => clock_1Mhz,
			clock_100hz => clock_100hz);

single_pulse : onepulse PORT MAP (pb_debounced => pb1_debounced, clock => clock_1MHz, 
			   pb_single_pulse => pb1_single_pulse);
END a;
		  


