-- Dummy VHDL Template with UP1 Library Definitions

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE up1core IS
	COMPONENT dec_7seg
		PORT(hex_digit				: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			segment_a, segment_b, segment_c, segment_d,
			segment_e, segment_f, segment_g : OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT debounce
		PORT(pb, clock_100Hz 		: IN	STD_LOGIC;
	         pb_debounced			: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT onepulse
		PORT(pb_debounced, clock	: IN	STD_LOGIC;
		 	pb_single_pulse			: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT clk_div
		PORT(clock_25Mhz			: IN	STD_LOGIC;
			 clock_1MHz				: OUT	STD_LOGIC;
			 clock_100KHz			: OUT	STD_LOGIC;
			 clock_10KHz			: OUT	STD_LOGIC;
			 clock_1KHz				: OUT	STD_LOGIC;
			 clock_100Hz			: OUT	STD_LOGIC;
			 clock_10Hz				: OUT	STD_LOGIC;
			 clock_1Hz				: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT vga_sync
 		PORT(clock_25Mhz, red, green, blue		: IN	STD_LOGIC;
         	 red_out, green_out, blue_out 		: OUT 	STD_LOGIC;
			 horiz_sync_out, vert_sync_out		: OUT 	STD_LOGIC;
			 pixel_row, pixel_column	: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
	END COMPONENT;
	COMPONENT char_rom
		PORT(character_address			: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			 font_row, font_col			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 rom_mux_output				: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT keyboard
		PORT(keyboard_clk, keyboard_data, clock_25Mhz , 
			 reset, read				: IN STD_LOGIC;
			 scan_code					: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 scan_ready					: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT mouse
		PORT(clock_25Mhz, reset 		: IN std_logic;
        	 mouse_data					: INOUT std_logic;
        	 mouse_clk 					: INOUT std_logic;
        	 left_button, right_button 	: OUT std_logic;
        	 mouse_cursor_row, 
			 mouse_cursor_column 		: OUT std_logic_vector(9 DOWNTO 0));       
		END COMPONENT;
END up1core;

LIBRARY work;
USE work.up1core.all;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY lfsr8 IS
	PORT
	(
		clk		: IN	STD_LOGIC;
		d		: OUT	STD_LOGIC_VECTOR(7 downto 0)
	);
	
END lfsr8;

ARCHITECTURE a OF lfsr8 IS
	SIGNAL s : STD_LOGIC_VECTOR(7 downto 0);
BEGIN
	process (clk)
	begin
		if (clk'event and clk='1') then
			if s="00000000" then
				s <= "00000001";
			else
				s <= s(6 downto 0) & (s(7) xor s(5) xor s(4) xor s(3));
			end if;
		end if;
	end process;
	d <= s;
END a;

