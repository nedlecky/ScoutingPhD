-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY Ifetch IS
	PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	SIGNAL Branch 			: IN 	STD_LOGIC;
        	SIGNAL Zero 			: IN 	STD_LOGIC;
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	SIGNAL clock, reset 	: IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4 	: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL next_PC 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
BEGIN
						--ROM for Instruction Memory
inst_memory: lpm_rom
	
	GENERIC MAP ( 
		lpm_widthad 		=> 8,
		lpm_outdata 		=> "UNREGISTERED",
		lpm_address_control => "UNREGISTERED",
						-- Reads in mif file for initial data memory values
		lpm_file 			=> "program.mif",
		lpm_width 			=> 32)
						-- Fetch next instruction from memory using PC
	PORT MAP ( 
		address 	=> PC( 9 DOWNTO 2 ), 
		q 			=> Instruction );
						-- copy output signals - allows read inside module
		PC_out 			<= PC( 7 DOWNTO 0 );
		PC_plus_4_out 	<= PC_plus_4( 7 DOWNTO 0 );
						-- Adder to increment PC by 4        
      	PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
		next_PC  <= Add_result  
			WHEN ( ( Branch = '1' ) AND ( Zero = '1' ) ) 
			ELSE   PC_plus_4( 9 DOWNTO 2 );

						-- Store PC in register and load next PC on clock edge
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC <= "0000000000" ; 
			ELSE 
				   PC( 9 DOWNTO 2 ) <= next_PC;
			END IF;
	END PROCESS;
END behavior;


