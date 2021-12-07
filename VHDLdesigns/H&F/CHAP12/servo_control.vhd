library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY servo_control IS

	PORT
	(
		clock_100khz, clock_10hz	: IN	STD_LOGIC;
		lmotor_dir, rmotor_dir: IN STD_LOGIC;
		lmotor_speed, rmotor_speed: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		lmotor, rmotor	: OUT	STD_LOGIC);
	
END servo_control;

ARCHITECTURE a OF servo_control IS

	SIGNAL count_motor: STD_LOGIC_VECTOR(10 DOWNTO 0); 
	SIGNAL	count_100Khz, count_10Khz, count_1Khz : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL	old_lmotor_dir, old_rmotor_dir: STD_LOGIC; 
	SIGNAL 	lmotor_delay_count, rmotor_delay_count: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL 	lmotor_speed_count, rmotor_speed_count: STD_LOGIC_VECTOR(5 DOWNTO 0);
BEGIN
	PROCESS 
	BEGIN
		WAIT UNTIL clock_100Khz'EVENT and clock_100Khz = '1';
			IF count_motor /=1999 THEN
				count_motor <= count_motor + 1;
			ELSE
				count_motor <= "00000000000";
			END IF;
			IF count_motor >= 1799 AND count_motor < 1899 THEN
-- DON'T GENERATE A PULSE FOR SPEED = 0
				IF lmotor_speed /= "000" THEN lmotor <= '1'; END IF;
				IF rmotor_speed /= "000" THEN rmotor <= '1'; END IF;
				lmotor_speed_count <= lmotor_speed & '0' & '0' & '0';
				rmotor_speed_count <= rmotor_speed & '0' & '0' & '0';
			ELSIF count_motor >= 1899 AND count_motor <2000 THEN
				IF lmotor_speed /= "000" THEN
					CASE lmotor_dir IS
					-- FORWARD
						WHEN '0' =>
							IF count_motor < 1892 THEN lmotor <= '1';
						    ELSIF count_motor >= 1892 AND lmotor_speed_count < "111111" 
						    THEN 
						    	lmotor <= '1';
						    	lmotor_speed_count <= lmotor_speed_count + 1;
						    ELSE
						    	lmotor <= '0';
						    END IF;
					-- REVERSE
						WHEN '1' =>
							IF count_motor < 1955 THEN lmotor <= '1';
							ELSIF count_motor >= 1955 AND lmotor_speed_count /= "000001"
							THEN
								lmotor <= '1';
								lmotor_speed_count <= lmotor_speed_count - 1;
							ELSE
								lmotor <= '0';
							END IF;
						WHEN OTHERS => NULL;
					END CASE;
				END IF;
				IF rmotor_speed /= "000" THEN
					CASE rmotor_dir IS
					-- FORWARD
						WHEN '1' =>
							IF count_motor < 1940 THEN rmotor <= '1';
						    ELSIF count_motor >= 1940 AND rmotor_speed_count < "1111" 
						    THEN 
						    	rmotor <= '1';
						    	rmotor_speed_count <= rmotor_speed_count + 1;
						    ELSE
						    	rmotor <= '0';
						    END IF;
					-- REVERSE
						WHEN '0' =>
							IF count_motor < 1955 THEN rmotor <= '1';
							ELSIF count_motor >= 1955 AND rmotor_speed_count /= "0001"
							THEN
								rmotor <= '1';
								rmotor_speed_count <= rmotor_speed_count - 1;
							ELSE
								rmotor <= '0';
							END IF;
						WHEN OTHERS => NULL;
					END CASE;
				END IF;
			ELSE
				lmotor <= '0';
				rmotor <= '0';
			END IF;
	END PROCESS;


END a;

