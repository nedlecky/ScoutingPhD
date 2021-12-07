-- uP1 Standalone Microprocessor
-- Modified to allow easy external wiring into memory
-- Also saves a CPI by decoding in the fetch phase, as long as clock period is long enough
-- University of Vermont
-- EE 231  Dr. Ned Lecky

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;
USE  IEEE.STD_LOGIC_ARITH.ALL;
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY UP1b IS
PORT(	clock, reset 	: IN STD_LOGIC;
        data_out 		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        data_in 		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        addr 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		rdy				: OUT STD_LOGIC;
		wr				: OUT STD_LOGIC);
END UP1b;

ARCHITECTURE a OF UP1b IS
	TYPE STATE_TYPE IS (resetA, fetch, decode, exec_add, exec_load, exec_store, 
		      exec_store2, exec_store3, exec_jump);
	SIGNAL state: STATE_TYPE;
	SIGNAL IR		: STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL MAR 		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL AC		: STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL PC		: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	-- use signal so can do math with MAR in future
	addr <= MAR;

	PROCESS (clock,reset)
	BEGIN
		IF reset = '1' THEN
			state <= resetA;
			rdy <= '0';
		ELSIF clock'EVENT AND clock = '1' THEN
			CASE state IS
				-- reset the computer, need to clear some registers
				WHEN resetA =>
					PC <= (others => '0');
					MAR <= (others => '0');
					AC <= (others => '0');
					wr <= '0';
					state <= fetch;
					rdy <= '1';
				-- Fetch instruction from memory and add 1 to PC
				WHEN fetch =>
					IR <= data_in;
					PC <= PC + 1;
--					state <= decode;
				-- Decode instruction and send out address of any data operands
--				WHEN decode =>
--					MAR <= IR(7 DOWNTO 0);
					MAR <= data_in(7 DOWNTO 0);
--					CASE IR(15 DOWNTO 8) IS
					CASE data_in(15 DOWNTO 8) IS
						WHEN "00000000" =>
						    state <= exec_add;
						WHEN "00000001" =>
						    state <= exec_store;
						WHEN "00000010" =>
						    state <= exec_load;		
						WHEN "00000011" =>
						    state <= exec_jump;
						WHEN OTHERS =>
						    state <= fetch;
					END CASE;
				-- Execute the ADD instruction
				WHEN exec_add =>
					AC <= AC + data_in;				
  					MAR <= PC;
					state <= fetch;
				-- Execute the STORE instruction
				-- (needs three clock cycles for memory write)
				WHEN exec_store =>
					-- write register_AC to memory
					data_out <= AC;
					wr <= '1';
		 			state <= exec_store2;
				-- This state ensures that the memory address is
				--  valid until after memory_write goes inactive
				WHEN exec_store2 =>
					wr <= '0';
					state <= exec_store3;
				WHEN exec_store3 =>
					MAR <= PC;
					state <= fetch;
				-- Execute the LOAD instruction
				WHEN exec_load =>
					AC <= data_in;
					MAR <= PC;
					state <= fetch;
				-- Execute the JUMP instruction
				WHEN exec_jump =>
					MAR <= IR(7 DOWNTO 0);
					PC <= IR(7 DOWNTO 0);
					state <= fetch;
				WHEN OTHERS =>
					MAR <= PC;
					state <= fetch;
				END CASE;
			END IF;
	END PROCESS;
END a;
