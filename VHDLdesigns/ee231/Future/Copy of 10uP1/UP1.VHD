LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;
USE  IEEE.STD_LOGIC_ARITH.ALL;
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY UP1 IS
PORT(	clock, reset 				: IN STD_LOGIC;
        PC_out 						: OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        AC_out 						: OUT STD_LOGIC_VECTOR(15 DOWNTO 0 );
        data_out 					: OUT STD_LOGIC_VECTOR(15 DOWNTO 0 );
        data_in 					: IN STD_LOGIC_VECTOR(15 DOWNTO 0 );
        addr 						: OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		wr							: OUT STD_LOGIC);
END UP1 ;

ARCHITECTURE a OF UP1 IS
TYPE STATE_TYPE IS ( reset_pc, fetch, decode, execute_add, execute_load, execute_store, 
		      execute_store3, execute_store2, execute_jump );
SIGNAL state: STATE_TYPE;
SIGNAL instruction_register, memory_data_register 	: STD_LOGIC_VECTOR(15 DOWNTO 0 );
SIGNAL MAR 				: STD_LOGIC_VECTOR(7 DOWNTO 0 );
SIGNAL register_AC 				: STD_LOGIC_VECTOR(15 DOWNTO 0 );
SIGNAL program_counter 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL memory_write 			: STD_LOGIC;
BEGIN
     	PC_out 		<= program_counter;
     	AC_out 		<= register_AC;
     	--memory_data_register_out 	<= memory_data_register; 
		wr <= memory_write;
		addr <= MAR;
		--data_out <= Register_AC;

PROCESS ( CLOCK, RESET )
	BEGIN
	IF reset = '1' THEN
		state <= reset_pc;
	ELSIF clock'EVENT AND clock = '1' THEN
		CASE state IS
					-- reset the computer, need to clear some registers
		WHEN reset_pc =>
			program_counter 		<= "00000000";
			MAR <= "00000000";
			register_AC				<= "0000000000000000";
			memory_write 			<= '0';
			state 					<= fetch;
					-- Fetch instruction from memory and add 1 to PC
		WHEN fetch =>
			instruction_register 	<= data_in;
			program_counter 		<= program_counter + 1;
			memory_write 			<= '0';
			state 					<= decode;
					-- Decode instruction and send out address of any data operands
		WHEN decode =>
			MAR <= instruction_register( 7 DOWNTO 0);
			CASE instruction_register( 15 DOWNTO 8 ) IS
				WHEN "00000000" =>
				    state 	<= execute_add;
				WHEN "00000001" =>
				    state 	<= execute_store;
				WHEN "00000010" =>
				    state 	<= execute_load;		
				WHEN "00000011" =>
				    state 	<= execute_jump;
				WHEN OTHERS =>
				    state 	<= fetch;
			END CASE;
					-- Execute the ADD instruction
		WHEN execute_add =>
			register_ac 				<= register_ac + data_in;				
  			MAR <= program_counter;
			state 						<= fetch;
					-- Execute the STORE instruction
					-- (needs three clock cycles for memory write)
		WHEN execute_store =>
					-- write register_AC to memory
			data_out <= register_AC;
			memory_write 				<= '1';
 			state 						<= execute_store2;
					-- This state ensures that the memory address is
					--  valid until after memory_write goes inactive
		WHEN execute_store2 =>
			memory_write				<= '0';
			state 						<= execute_store3;
		WHEN execute_store3 =>
			MAR <= program_counter;
			state 						<= fetch;
					-- Execute the LOAD instruction
		WHEN execute_load =>
			register_ac 				<= data_in;
			MAR <= program_counter;
			state <= fetch;
					-- Execute the JUMP instruction
		WHEN execute_jump =>
			MAR <= instruction_register( 7 DOWNTO 0 );
			program_counter 			<= instruction_register( 7 DOWNTO 0 );
			state 						<= fetch;
		WHEN OTHERS =>
			MAR <= program_counter;
			state <= fetch;
		END CASE;
	END IF;
   END PROCESS;
END a;
