-- TOP_FLEX module
--
-- Flex - Mips Implementation
-- Uses VGA to Display Data 
-- PB1 is clock for Mips
-- PB2 is synchronous reset for Mips
-- i.e. must clock (hit PB1) while holding down PB2 for reset
-- PC is also displayed on 7 Segment Display
-- Flex Switch 3 is reverse video
--
-- This Module uses UP1core functions and they must be in the user library path
--
-- VHDL synthesis and simulation model of MIPS single clock cycle machine
-- as described in chapter 5 of Patterson and Hennessey
-- VHDL Submodules Ifetch20,Control,Idecode,Execute and Dmemory
-- become different pipeline stages in chapter 6.  The code 
-- for each of these VHDL modules in *.VHD files
--
-- Setup to use alternate Ifetch (Ifetch20) so that design fits on a FLEX 10K20.
-- Program must be entered into the Ifetch20 vhdl source file.
-- If a 10K70 board is available, Ifetch version using LPM_RAM can be used. 
--
-- NOTE: Full 32-bit instructions are used. The Data paths were limited
-- to 8 bits to speed synthesis and simulation for student projects.
-- Registers are limited to 8 bits and $R0..$R7 only
-- Program memory limited to locations 0..7 and Data to locations 0..1
-- Register contain register address on reset.  Data memory
-- is initialized to 55 AA for program on reset
-- Use top_spim module to simulate MIPS without video display hardware
--
--
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

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;
LIBRARY work;
USE work.up1core.all;

ENTITY top_flex IS

GENERIC(ADDR_WIDTH: integer := 12; DATA_WIDTH: integer := 1);

   PORT( PB1, PB2, Clock 							: IN std_logic;
         LSB_a, LSB_b, LSB_c, LSB_d, LSB_e, LSB_f, LSB_g, LSB_dp,
         MSB_a, MSB_b, MSB_c, MSB_d, MSB_e, MSB_f, 
		 MSB_g, MSB_dp 								: OUT std_logic;               
         Red,Green,Blue 							: OUT std_logic;
         Horiz_sync,Vert_sync 						: OUT std_logic;
         Flex_Switch_1, Flex_Switch_2, Flex_Switch_3, 
		 Flex_Switch_4								: IN std_logic;
         Flex_Switch_5, Flex_Switch_6, Flex_Switch_7, 
		 Flex_Switch_8								: IN std_logic);      
		
END top_flex;

ARCHITECTURE behavior OF top_flex IS

   COMPONENT Ifetch20
   		PORT(	Instruction			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        		PC_plus_4_out 		: OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
        		Add_result 			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        		Branch 				: IN STD_LOGIC;
        		Zero 				: IN STD_LOGIC;
        		PC_out 				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        		clock,reset 		: IN STD_LOGIC);
   END COMPONENT;
 

   COMPONENT Idecode
   		PORT(	read_data_1 		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        		read_data_2 		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        		Instruction 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        		read_data 			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        		ALU_result 			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        		RegWrite, MemtoReg 	: IN STD_LOGIC;
        		RegDst 				: IN STD_LOGIC;
        		Sign_extend 		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        		clock, reset		: IN STD_LOGIC);
	END COMPONENT;


   COMPONENT control
   		PORT( 	Opcode 				: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
                RegDst 				: OUT STD_LOGIC;
                ALUSrc 				: OUT STD_LOGIC;
                MemtoReg 			: OUT STD_LOGIC;
                RegWrite 			: OUT STD_LOGIC;
                MemRead 			: OUT STD_LOGIC;
                MemWrite 			: OUT STD_LOGIC;
                Branch 				: OUT STD_LOGIC;
                ALUop 				: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
                clock, reset		: IN STD_LOGIC);
	 END COMPONENT;


   COMPONENT  Execute
   		PORT(	Read_data_1 		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                Read_data_2 		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                Sign_Extend 		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                Function_opcode 	: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
                ALUOp 				: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
                ALUSrc 				: IN STD_LOGIC;
                Zero 				: OUT STD_LOGIC;
                ALU_Result 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                Add_Result 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                PC_plus_4 			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                clock, reset		: IN STD_LOGIC);
	END COMPONENT;


   COMPONENT dmemory
	  	 PORT(	read_data 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        		address 			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        		write_data 			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        		MemRead, Memwrite 	: IN STD_LOGIC;
        		Clock,reset			: IN STD_LOGIC);
   END COMPONENT;

--Force MIPS clock signal on low skew global clock bus line
   COMPONENT GLOBAL
          PORT (a_in : IN STD_LOGIC;
                a_out: OUT STD_LOGIC);
   END COMPONENT;

-- declare signals used to connect VHDL MIPS components
   SIGNAL PC_plus_4, PC 				: STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL read_data_1 					: STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL read_data_2 					: STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL Sign_Extend 					: STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL Add_result 					: STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL ALU_result 					: STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL read_data 					: STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL ALUSrc 						: STD_LOGIC;
   SIGNAL Branch 						: STD_LOGIC;
   SIGNAL RegDst 						: STD_LOGIC;
   SIGNAL Regwrite 						: STD_LOGIC;
   SIGNAL Zero 							: STD_LOGIC;
   SIGNAL MemWrite 						: STD_LOGIC;
   SIGNAL MemtoReg						: STD_LOGIC;
   SIGNAL MemRead						: STD_LOGIC;
   SIGNAL ALUop 						: STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL Instruction					: STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL Reset, MIPS_clock, Vert_sync_in : STD_LOGIC;


-- Video Display Signals
SIGNAL Red_Data, Green_Data, Blue_Data, Power_On, Rev_video : std_logic;

-- Signals for Video ROM Memory for Pixel Data
SIGNAL char_address				: std_logic_vector(5 DOWNTO 0);
SIGNAL sum_address				: std_logic_vector(6 DOWNTO 0);
SIGNAL col_address, row_address	: std_logic_vector(5 DOWNTO 0);
SIGNAL pixel_col, pixel_row		: std_logic_vector(9 DOWNTO 0);
SIGNAL rom_mux_output			: std_logic;
SIGNAL format_address			: std_logic_vector(5 DOWNTO 0);
SIGNAL format_data				: std_logic_vector(5 DOWNTO 0);

-- Signals for LED Display
SIGNAL LSB,MSB					: std_logic_vector(3 DOWNTO 0);

-- Signals for Push buttons
SIGNAL PB1_sync, PB2_sync		: std_logic; 
SIGNAL PB2_debounced, PB1_debounced, PB2_debounced_Sync, 
		PB1_debounced_Sync		: std_logic; 
SIGNAL PB1_single_pulse			: std_logic;
SIGNAL switch, switch_sync		: std_logic_vector(7 DOWNTO 0);


BEGIN



-- Character Format ROM for Video Display
-- Displays constant format character data
-- on left side of Display area
 format_rom: lpm_rom
      GENERIC MAP ( lpm_widthad => 6,
        lpm_numwords => 60,
        lpm_outdata => "UNREGISTERED",
        lpm_address_control => "UNREGISTERED",
			-- Reads in mif file for data display format
        lpm_file => "format.mif",
        lpm_width => 6)
      PORT MAP ( address => format_address, q => format_data);


---------------------------------------------------------------------------------------
-- MIPS structural model - contains processor module interconnections
-- Code for each module is in *.VHD files
--
-- connect the 5 MIPS components   
  IFE : Ifetch20
   	PORT MAP (	Instruction => Instruction,
    	    	PC_plus_4_out => PC_plus_4,
				Add_result => Add_result,
				Branch => Branch,
				Zero => Zero,
				PC_out => PC,        		
				clock => MIPS_clock,  
				reset => reset);




   ID : Idecode
   	PORT MAP (	read_data_1 => read_data_1,
        		read_data_2 => read_data_2,
        		Instruction => Instruction,
        		read_data => read_data,
				ALU_result => ALU_result,
				RegWrite => RegWrite,
				MemtoReg => MemtoReg,
				RegDst => RegDst,
				Sign_extend => Sign_extend,
        		clock => MIPS_clock,  
				reset => reset);


   CTL:   control
	PORT MAP ( 	Opcode => Instruction(31 DOWNTO 26),
				RegDst => RegDst,
				ALUSrc => ALUSrc,
				MemtoReg => MemtoReg,
				RegWrite => RegWrite,
				MemRead => MemRead,
				MemWrite => MemWrite,
				Branch => Branch,
				ALUop => ALUop,
                clock => MIPS_clock,
				reset => reset);

   EXE:  Execute
   	PORT MAP (	Read_data_1 => read_data_1,
             	Read_data_2 => read_data_2,
				Sign_extend => Sign_extend,
                Function_opcode => Instruction(5 DOWNTO 0),
				ALUOp => ALUop,
				ALUSrc => ALUSrc,
				Zero => Zero,
                ALU_Result => ALU_Result,
				Add_Result => Add_Result,
				PC_plus_4 => PC_plus_4,
                clock => MIPS_clock,
				reset => reset);

   MEM:  dmemory
   	PORT MAP (	read_data => read_data,
				address => ALU_Result,
				write_data => read_data_2,
				MemRead => MemRead, 
				Memwrite => MemWrite, 
            	clock => MIPS_clock,  
				reset => reset);

				--Force MIPS clock signal on low skew global clock bus line
   GBUF: GLOBAL
   	PORT MAP (  a_in => PB1_Single_Pulse,
                a_out => MIPS_clock);
				-- Generate VGA sync signals for display
   SYNC: vga_sync
 		PORT MAP(clock_25Mhz => clock, 
				red => red_data, green => green_data, blue => blue_data,	
    	     	red_out => red, green_out => green, blue_out => blue,
			 	horiz_sync_out => horiz_sync, vert_sync_out => vert_sync_in,
			 	pixel_row => pixel_row, pixel_column => pixel_col);
				-- Character Font ROM for Video Display
   CGROM: char_rom
		PORT MAP(character_address => char_address,
				font_row => pixel_row(3 DOWNTO 1), font_col => pixel_col(3 DOWNTO 1),	
				rom_mux_output => rom_mux_output);
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

-- Debounce Button: Filters out mechanical bounce for around 64Ms.
-- Debounce clock uses Vert_Sync timing signal (16Ms) to save hardware
-- needed for a clock prescaler
	DB1: debounce
		PORT MAP(pb => pb1, clock_100Hz => vert_sync_in , pb_debounced => pb1_debounced);

				-- Debounce reset pushbutton
	DB2: debounce
		PORT MAP(pb => pb2, clock_100Hz => vert_sync_in , pb_debounced => pb2_debounced);

				-- Output Pushbutton Pulse for 1 clock cycle
	SP1: onepulse
		PORT MAP(pb_debounced => pb1_debounced_sync, clock => clock,
		 	 	 pb_single_pulse => pb1_single_pulse);


------------------------------------------------------------------------------

			-- Reset signal for MIPS processor
Reset <=  PB2_Debounced_Sync;

Vert_sync <= vert_sync_in;

			-- Colors for pixel data on video signal
			-- address video_rom for pixel color data
			-- Switch 2 xor Rev_Video will reverse video
Red_Data <= not ((rom_mux_output xor Switch_Sync(2)) xor Rev_video);
Green_Data <= not ((rom_mux_output xor Switch_Sync(2)) xor Rev_video);
Blue_Data <= '1';

			-- current character row and column being displayed
row_address(5 DOWNTO 0) <= pixel_row(9 DOWNTO 4);
col_address(5 DOWNTO 0) <= pixel_col(9 DOWNTO 4);


		-- Combine Flex Dip Switch Inputs into Switch vector
Switch <= Flex_Switch_8 & Flex_Switch_7 & Flex_Switch_6 & Flex_Switch_5 &
          Flex_Switch_4 & Flex_Switch_3 & Flex_Switch_2 & Flex_Switch_1;

		-- Address for Constant Character Data Format ROM
format_address(1 DOWNTO 0) <= Col_address(1 DOWNTO 0);
format_address(5 DOWNTO 2) <= Row_address(4 DOWNTO 1);


-- This Process Provides Character Data for Video Display
-- by generating addresses for the Character Generator ROM
-- using the character row address and col address provided by the Video 
-- Sync process  - 40 characters by 30 lines of display area

VIDEO_DISPLAY_DATA: PROCESS
BEGIN
  WAIT UNTIL (clock'event) AND (clock='1');

			-- Reverse Video for Title at top of screen
IF (row_address <= "00011") THEN rev_video <= '1'; 
	ELSE rev_video <= '0';
END IF;

			-- Blank characters on edge of screen and on alternating lines
IF (row_address(0)='0')  OR
   (col_address < "001000") OR (col_address >"010101") 
THEN char_address <= "100000";
ELSE 

			-- Constant Character Area - use data from format ROM
 IF ((col_address >= "001000") AND (col_address <= "001011")) THEN
	 char_address <= format_data;
 ELSE
			-- Couple of Spaces
  IF (col_address = "001100") OR (col_address = "001101") 
			-- Blanks on Top and Bottom line of Display Area  
  OR (row_address < "00010") OR (row_address > "11011")
  THEN char_address <= "100000";
 
  ELSE

			-- Numeric Data From Simulation
			-- Display Values in Hex
  CASE  row_address(4 DOWNTO 1) IS
	WHEN  "0001"  =>
		CASE col_address IS
		-- Print "Computer" on first line of data display area
 	    	WHEN "001110" => 
				char_address <= "000011";
	    	WHEN "001111" => 
				char_address <= "001111" ;
	    	WHEN "010000" => 
				char_address <= "001101" ;
	    	WHEN "010001" => 
				char_address <= "010000" ;
	    	WHEN "010010" => 
				char_address <= "010101" ;
	    	WHEN "010011" => 
				char_address <= "010100" ;
	    	WHEN "010100" => 
				char_address <= "000101" ;
	    	WHEN "010101" => 
				char_address <= "010010" ;
	    	WHEN OTHERS =>
				char_address <= char_address;
        END CASE;
	WHEN  "0010" =>
	    CASE col_address IS
			WHEN "010100" => 
 				-- Selects Hex Character Address with 4-bit value from signal
               char_address <= "11" & PC(7 DOWNTO 4);
        	WHEN "010101" =>
  				-- Selects Hex Character Address with 4-bit value from signal
               char_address <= "11" & PC(3 DOWNTO 0);
            WHEN OTHERS =>
               char_address <= "110000";
        END CASE;
	WHEN  "0011"  =>
			-- Selects Hex Character Address with 4-bit value from signal
	    CASE col_address IS
			WHEN "001110" => 
         		char_address <= "11" & Instruction(31 DOWNTO 28);
	    	WHEN "001111" => 
				char_address <= "11" & Instruction(27 DOWNTO 24);
	    	WHEN "010000" => 
				char_address <= "11" & Instruction(23 DOWNTO 20);
	    	WHEN "010001" => 
				char_address <= "11" & Instruction(19 DOWNTO 16);
	    	WHEN "010010" => 
				char_address <= "11" & Instruction(15 DOWNTO 12);
	    	WHEN "010011" => 
				char_address <= "11" & Instruction(11 DOWNTO 8);
	    	WHEN "010100" => 
				char_address <= "11" & Instruction(7 DOWNTO 4);
	    	WHEN "010101" => 
				char_address <= "11" & Instruction(3 DOWNTO 0);
	    	WHEN OTHERS =>
				char_address <= char_address;
        END CASE;
	WHEN   "0100"  =>
	    CASE col_address IS
			WHEN "010100" =>
  			-- Selects Hex Character Address with 4-bit value from signal
        		char_address <= "11" & read_data_1(7 DOWNTO 4);
        	WHEN "010101" =>
         		char_address <= "11" & read_data_1(3 DOWNTO 0);
        	WHEN OTHERS =>
         		char_address <= "110000";
        END CASE;
	WHEN   "0101"  =>
	    CASE col_address IS
			WHEN "010100" => 
  			-- Selects Hex Character Address with 4-bit value from signal
         		char_address <= "11" & read_data_2(7 DOWNTO 4);
        	WHEN "010101" =>
          		char_address <= "11" & read_data_2(3 DOWNTO 0);
        	WHEN OTHERS =>
         		char_address <= "110000";
        END CASE;
	WHEN   "0110"  =>
	    CASE col_address IS
		     WHEN "010100" => 
 			-- Selects Hex Character Address with 4-bit value from signal
         		 char_address <= "11" & ALU_result(7 DOWNTO 4);
        	 WHEN "010101" => 
                 char_address <= "11" & ALU_result(3 DOWNTO 0);
        	 WHEN OTHERS =>
                 char_address <= "110000";
        END CASE;
	WHEN   "0111"  =>
	    CASE col_address IS
			WHEN "010100" => 
  			-- Selects Hex Character Address with 4-bit value from signal
        	  char_address <= "11" & Read_data(7 DOWNTO 4);
        	WHEN "010101" => 
              char_address <= "11" & Read_data(3 DOWNTO 0);
        	WHEN OTHERS =>
         	  char_address <= "110000";
        END CASE;
	WHEN   "1000"  =>
	    IF col_address = "001110" 
			-- Select "0" OR "1" character address
        THEN char_address <= "11000" & Branch;
        ELSE
         char_address <= "100000";
        END IF;
	WHEN   "1001"  =>
	    IF col_address = "001110" 
			-- Select "0" OR "1" character address
         THEN char_address <= "11000" & Zero;
        ELSE
         char_address <= "100000";
        END IF;
	WHEN   "1010"  =>
	    IF col_address = "001110" 
 			-- Select "0" OR "1" character address
        THEN char_address <= "11000" & Memread;
        ELSE
         char_address <= "100000";
        END IF;
	WHEN   "1011"  =>
	    IF col_address = "001110" 
 			-- Select "0" OR "1" character address
        THEN char_address <= "11000" & Memwrite;
        ELSE
         char_address <= "100000";
        END IF;
	WHEN   "1100"  =>
	    IF col_address = "001110" 
 			-- Select Up arrow or Down arrow character address
        THEN char_address <= "0111" & MIPS_Clock & "0";
        ELSE
         char_address <= "100000";
        END IF;
	WHEN   "1101"  =>
	    IF col_address = "001110" 
 			-- Select Up arrow or Down arrow character address
         THEN char_address <= "0111" & Reset & "0";
        ELSE
         char_address <= "100000";
        END IF;
	WHEN OTHERS =>
      char_address <= "100000";
  END CASE;
  END IF;
 END IF;
END IF;
END PROCESS VIDEO_DISPLAY_DATA;


	
-- Values to Display in 7Seg LEDs
MSB_dp 	<= NOT MIPS_CLOCK;
LSB_dp 	<= NOT RESET;
MSB 	<= PC (7 DOWNTO 4);
LSB 	<= PC (3 DOWNTO 0);

-- Sync extenal pushbutton inputs to chip clock
PUSH_BUTTON_SYNC: PROCESS (clock)
BEGIN
  	WAIT UNTIL (clock'event) AND (clock='1');
	PB1_Sync <=  PB1;
	PB2_Sync <=  PB2;
	Switch_Sync <= Switch;
	PB1_DEBOUNCED_SYNC <= PB1_DEBOUNCED;
	PB2_DEBOUNCED_SYNC <= PB2_DEBOUNCED;
END PROCESS PUSH_BUTTON_SYNC;


END behavior;

