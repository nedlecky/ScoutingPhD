			-- Bouncing Ball Video 
					-- UP1PACK - UP1core package
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;
PACKAGE up1core IS
	COMPONENT dec_7seg
		PORT(	hex_digit: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				segment_a, segment_b, segment_c, segment_d,
				segment_e, segment_f, segment_g : OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT debounce
		PORT(pb, clock_100Hz 	: IN	STD_LOGIC;
	         pb_debounced		: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT onepulse
		PORT(pb_debounced, clock: IN	STD_LOGIC;
		 	 pb_single_pulse	: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT clk_div
		PORT(clock_25Mhz		: IN	STD_LOGIC;
			clock_1MHz			: OUT	STD_LOGIC;
			clock_100KHz		: OUT	STD_LOGIC;
			clock_10KHz			: OUT	STD_LOGIC;
			clock_1KHz			: OUT	STD_LOGIC;
			clock_100Hz			: OUT	STD_LOGIC;
			clock_10Hz			: OUT	STD_LOGIC;
			clock_1Hz			: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT vga_sync
 		PORT(clock_25Mhz, red, green, blue		: IN	STD_LOGIC;
         	red_out, green_out, blue_out		: OUT 	STD_LOGIC;
			horiz_sync_out, vert_sync_out		: OUT 	STD_LOGIC;
			pixel_row, pixel_column		: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
	END COMPONENT;
	COMPONENT char_rom
		PORT(	character_address	: IN	STD_LOGIC_VECTOR(5 DOWNTO 0);
			font_row, font_col		: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
			rom_mux_output			: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT keyboard
		PORT(	keyboard_clk, keyboard_data, clock_25Mhz , 
			reset, read				: IN	STD_LOGIC;
			scan_code				: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			scan_ready				: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT mouse
		PORT( 	clock_25Mhz, reset 	: IN std_logic;
         		mouse_data			: INOUT std_logic;
        		mouse_clk 			: INOUT std_logic;
        		left_button, right_button : OUT std_logic;
        		mouse_cursor_row, mouse_cursor_column : OUT std_logic_vector(9 DOWNTO 0));       
		END COMPONENT;
END up1core;


			-- Bouncing Ball Video 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;
LIBRARY work;
USE work.up1core.all;


ENTITY ball IS

Generic(ADDR_WIDTH: integer := 12; DATA_WIDTH: integer := 1);

   PORT(SIGNAL PB1, PB2, Clock 				: IN std_logic;
        SIGNAL LSB_a, LSB_b, LSB_c, LSB_d	: OUT std_logic; 
		SIGNAL LSB_e, LSB_f, LSB_g, LSB_dp	: OUT std_logic;
        SIGNAL MSB_a, MSB_b, MSB_c, MSB_d	: OUT std_logic;
		SIGNAL MSB_e, MSB_f, MSB_g, MSB_dp 	: OUT std_logic;               
        SIGNAL Red,Green,Blue 				: OUT std_logic;
        SIGNAL Horiz_sync,Vert_sync	: OUT std_logic);
       
		
		
END ball;

architecture behavior of ball is

			-- Video Display Signals   
SIGNAL Red_Data, Green_Data, Blue_Data, vert_sync_int,
		reset, Ball_on, Direction			: std_logic;
SIGNAL Size 								: std_logic_vector(9 DOWNTO 0);  
SIGNAL Ball_Y_motion 						: std_logic_vector(9 DOWNTO 0);
SIGNAL Ball_Y_pos, Ball_X_pos				: std_logic_vector(9 DOWNTO 0);
SIGNAL pixel_row, pixel_column					: std_logic_vector(9 DOWNTO 0); 
			-- Signals for LED Display
SIGNAL LSB,MSB								: std_logic_vector(3 DOWNTO 0);
SIGNAL LSB_7SEG,MSB_7SEG					: std_logic_vector(6 DOWNTO 0);


BEGIN           

   SYNC: vga_sync
 		PORT MAP(clock_25Mhz => clock, 
				red => red_data, green => green_data, blue => blue_data,	
    	     	red_out => red, green_out => green, blue_out => blue,
			 	horiz_sync_out => horiz_sync, vert_sync_out => vert_sync_int,
			 	pixel_row => pixel_row, pixel_column => pixel_column);
				-- Display PC in seven-segment displays
   MSD: dec_7seg
		PORT MAP(hex_digit => MSB,
				segment_a => MSB_a, segment_b => MSB_b, segment_c => MSB_c, 
				segment_d => MSB_d,	segment_e => MSB_e, segment_f => MSB_f, 
				segment_g => MSB_g );

   LSD: dec_7seg
		PORT MAP(hex_digit => LSB,
				segment_a => LSB_a, segment_b => LSB_b, segment_c => LSB_c, 
				segment_d => LSB_d,	segment_e => LSB_e, segment_f => LSB_f, 
				segment_g => LSB_g );


Size <= CONV_STD_LOGIC_VECTOR(8,10);
Ball_X_pos <= CONV_STD_LOGIC_VECTOR(320,10);

		-- need internal copy of vert_sync to read
vert_sync <= vert_sync_int;

		-- Colors for pixel data on video signal
Red_Data <=  '1';
		-- Turn off Green and Blue when displaying ball
Green_Data <= NOT Ball_on;
Blue_Data <=  NOT Ball_on;

		-- Turn off LED display decimal points
LSB_dp <= '1';
MSB_dp <= '1';
		-- display ball row in LEDs
MSB <= Ball_Y_pos(7 DOWNTO 4);
LSB <= Ball_Y_pos(3 DOWNTO 0);


RGB_Display: Process (Ball_X_pos, Ball_Y_pos, pixel_column, pixel_row, Size)
BEGIN
			-- Set Ball_on ='1' to display ball
 IF ('0' & Ball_X_pos <= pixel_column + Size) AND
 			-- compare positive numbers only
 	(Ball_X_pos + Size >= '0' & pixel_column) AND
 	('0' & Ball_Y_pos <= pixel_row + Size) AND
 	(Ball_Y_pos + Size >= '0' & pixel_row ) THEN
 		Ball_on <= '1';
 	ELSE
 		Ball_on <= '0';
END IF;
END process RGB_Display;


Move_Ball: process
BEGIN
			-- Move ball once every vertical sync
	WAIT UNTIL vert_sync_int'event and vert_sync_int = '1';
			-- Bounce off top or bottom of screen
			IF ('0' & Ball_Y_pos) >= CONV_STD_LOGIC_VECTOR(480,10) - Size THEN
				Ball_Y_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
			ELSIF Ball_Y_pos <= Size THEN
				Ball_Y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
			END IF;
			-- Compute next ball Y position
				Ball_Y_pos <= Ball_Y_pos + Ball_Y_motion;
END process Move_Ball;

END behavior;

