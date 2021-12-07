library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY ir_sensor IS

	PORT
	(	clock_100Hz, clock_10Khz, clock_1hz, sout, active	: IN	STD_LOGIC;
		left_led, right_led, left, right, other			: OUT	STD_LOGIC);
	
END ir_sensor;

ARCHITECTURE a OF ir_sensor IS

	SIGNAL	left_rscount, right_rscount, other_rscount : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL  set_left, set_right, set_other : STD_LOGIC;
	SIGNAL	state_count : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN

	right_led <= '1' WHEN state_count = "00" AND active = '1' ELSE '0';
	left_led  <= '1' WHEN state_count = "01" AND active = '1' ELSE '0';


PROCESS
	BEGIN
	  WAIT UNTIL clock_100hz'EVENT and clock_100hz = '1';
		IF state_count = "10" THEN
			state_count <= "00";
		ELSE
			state_count <= state_count + 1;
		END IF;
	END PROCESS;
	
PROCESS
	BEGIN
	  WAIT UNTIL clock_10Khz'EVENT and clock_10Khz = '0';
		CASE state_count IS 
		WHEN "00" =>
			IF right_rscount < 25 THEN
				right_rscount <= right_rscount + NOT sout;
			END IF;
			IF other_rscount >= 15 THEN set_other <= '1'; 
			ELSIF other_rscount <= 5 THEN set_other <= '0';  END IF;
		    left_rscount <= "00000";
		WHEN "01" =>
			IF left_rscount < 25 THEN
				left_rscount <= left_rscount + NOT sout;
			END IF;
			IF right_rscount >= 25 THEN set_right <= '1';  
			ELSIF right_rscount <= 12 THEN set_right <= '0';  END IF;
		    other_rscount <= "00000";
		WHEN "10" =>		
			IF left_rscount >= 25 THEN set_left <= '1'; 
			ELSIF left_rscount <= 12 THEN set_left <= '0';  END IF;
			IF other_rscount < 25 THEN
				other_rscount <= other_rscount + NOT sout;
			END IF;
		    right_rscount <= "00000";
		WHEN OTHERS =>
			NULL;
		END CASE;
	END PROCESS;

	PROCESS (set_left,clock_1Hz)
	BEGIN
		IF set_left = '1' THEN left <= '1';
		ELSIF clock_1Hz'EVENT and clock_1Hz = '1' THEN
			left <= '0';
		END IF;
	END PROCESS;

	PROCESS (set_right,clock_1Hz)
	BEGIN
		IF set_right = '1' THEN right <= '1';
		ELSIF clock_1Hz'EVENT and clock_1Hz = '1' THEN
			right <= '0';
		END IF;
	END PROCESS;

	PROCESS (set_other,clock_1Hz)
	BEGIN
		IF set_other = '1' THEN other <= '1';
		ELSIF clock_1Hz'EVENT and clock_1Hz = '1' THEN
			other <= '0';
		END IF;
	END PROCESS;
END a;

