--
-- VHDL Program to interface to the Sharp GP2D02 IR distance sensor
--
-- Vin and Vout are sensor I/O pins
-- Clock_10Khz is a 10Khz clock signal
-- Distance is the 8-bit distance returned by the sensor
-- Valid=1 indicates a valid distance is loaded
-- Measure=1 starts the sensor, Measure=0 powers down the sensor after the current cycle
--
--
-- Typical measurement cycle:  
-- Vin is sensor input (clock)  Vout is sensor output (8-bit serial data)
--
--  Vin ---------____________________---___---___---___---___---___---___---___---___-----
--  Vout----------__________________---| b7  | b6  | b5  | b4  | b3  | b2  | b1  | b0 -----
--
-- Vin=0 starts a measurement cycle. When ready Vout=1 and the 8-bit serial data can be clocked 
-- out using Vin as the clock. A measurement cycle can take up to 70ms, 
-- should wait .5-1.5ms before starting another measurement cycle.
-- If no measurement starts in 1.5ms, the sensor powers down to a low current state
--
-- GP2D02 pinout with pins towards you           __o_____o__
--	1-gnd, 3-5v, 2-Vin, 4-Vout					|    4321   |
--                                             ===============
--
-- Distance output from sensor (cm) is  1000*arctan(1.9/distance) + 20
-- last constant varies a few bits from sensor to sensor
-- larger values are closer to the sensor, readings less than 10cm should be avoided.
--
library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY gp2d02 IS
	PORT(Vout, clock_10Khz, measure : IN	STD_LOGIC;
		 Vin : INOUT STD_LOGIC; 
		 Valid	: OUT	STD_LOGIC;
		 Distance : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END gp2d02;

ARCHITECTURE a OF gp2d02 IS
	SIGNAL Distance_shift : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Count : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reset : STD_LOGIC;
	TYPE STATE_TYPE IS (init, power_down, start_measure, wait_ack, got_ack, send_data, clock_data);
	SIGNAL state: STATE_TYPE;
BEGIN
	PROCESS
	BEGIN
	  WAIT UNTIL clock_10Khz'EVENT AND clock_10Khz = '1';
	   IF reset = '0' THEN
			state <= init;
			reset <= '1';
	   ELSE
		CASE state IS

-- resets flags and counters during initial power on
				WHEN init =>
					state <= power_down;
					valid <= '0';
					count <= "0000";
					distance <= "00000000";

-- checks for sensor power down control (measure=0) and waits for intermeasurement delay time
				WHEN power_down =>
					IF measure = '1'  AND count = "1100" THEN
						state <= start_measure;
						count <= "0000";
					ELSE
						state <= power_down;
						IF count < "1100" THEN
							count <= count + 1;
						END IF;
					END IF;

 -- Set Vin low and after a delay jump to state that starts checking Vout
				WHEN start_measure =>
					IF  count = "0111" THEN
						state <= wait_ack;
						count <= "0000";
					ELSE
						state <= start_measure;
						count <= count + 1;
					END IF;

-- Wait for Vout to go high - this signals new data ready in sensor
				WHEN wait_ack =>
					IF Vout = '1' THEN
						state <= got_ack;
					ELSE
						state <= wait_ack;
					END IF;

-- Set Vin back high after Vout goes high to start clocking data out
				WHEN got_ack =>
						state <= send_data;

-- drive Vin low each time to clock out next data bit
				WHEN send_data =>
						state <= clock_data;

-- drive Vin high and clock in another data bit and count until all 8 bits are in shifter
				WHEN clock_data =>
					IF count = "0111" THEN
						state <= power_down;
						count <= "0000";
						valid <= '1';
						distance <= distance_shift(6 DOWNTO 0) & Vout;
					ELSE
						state <= send_data;
						count <= count + 1;
						distance_shift <= distance_shift(6 DOWNTO 0) & Vout;
					END IF;

			END CASE;
		END IF;
	END PROCESS;

-- Vin is an open drain input (internal pull up resistor) so it should only be driven low
-- and should never be assigned a value of "1". "Z" will allow the internal pullup resistor
-- to pull it high and will prevent the possibility of two transistors shorting between power and ground.
	WITH state SELECT
		Vin 	<=	'Z'	WHEN	init,
					'Z' WHEN 	power_down,
					'0'	WHEN	start_measure,
					'0' WHEN 	wait_ack,
					'Z' WHEN	got_ack,
					'0'	WHEN	send_data,
					'Z' WHEN    clock_data;
END a;


