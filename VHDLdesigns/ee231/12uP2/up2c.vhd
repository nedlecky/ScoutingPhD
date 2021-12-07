-- uP2c Standalone Microprocessor
-- Combined fetch/decode and instruction pre-execution
-- University of Vermont
-- EE 231  Dr. Ned Lecky

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;
USE  IEEE.STD_LOGIC_ARITH.ALL;
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY uP2c IS
PORT(	clock, reset 	: IN STD_LOGIC;
        data_out 		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        outbus	 		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_wr	 		: OUT STD_LOGIC;
        data_in 		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        addr 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		rdy				: OUT STD_LOGIC;
		wr				: OUT STD_LOGIC);
END uP2c;

ARCHITECTURE a OF uP2c IS
	TYPE STATE_TYPE IS (resetA, fetch, exec_nop, exec_load,
		exec_store,exec_store2, exec_store3, exec_add,
		exec_out, exec_out2
		);
	SIGNAL state: STATE_TYPE;
	SIGNAL IR		: STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL MAR 		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL AC		: STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL PC		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	constant nop_opcode 	: std_logic_vector(7 downto 0) := x"00";
	constant load_opcode 	: std_logic_vector(7 downto 0) := x"01";
	constant loadi_opcode 	: std_logic_vector(7 downto 0) := x"02";
	constant store_opcode 	: std_logic_vector(7 downto 0) := x"03";
	constant add_opcode 	: std_logic_vector(7 downto 0) := x"04";
	constant addimm_opcode 	: std_logic_vector(7 downto 0) := x"05";
	constant clear_opcode 	: std_logic_vector(7 downto 0) := x"06";
	constant decr_opcode 	: std_logic_vector(7 downto 0) := x"07";
	constant jump_opcode 	: std_logic_vector(7 downto 0) := x"08";
	constant jz_opcode 		: std_logic_vector(7 downto 0) := x"09";
	constant out_opcode 	: std_logic_vector(7 downto 0) := x"0A";
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
					outbus <= (others => '0');
					out_wr <= '0';
					wr <= '0';
					state <= fetch;
					rdy <= '1';
				-- Fetch instruction from memory and do whatever else you can
				WHEN fetch =>
					IR <= data_in;
					PC <= PC + 1;
					MAR <= data_in(7 DOWNTO 0);
					CASE data_in(15 DOWNTO 8) IS
						WHEN nop_opcode =>
							state <= exec_nop;
						WHEN load_opcode =>
						    state <= exec_load;		
						WHEN loadi_opcode =>
							MAR <= AC(7 downto 0);
							state <= exec_load;
						WHEN store_opcode =>
				 			state <= exec_store;
						WHEN add_opcode =>
						    state <= exec_add;
						WHEN addimm_opcode =>
							AC <= AC + data_in(7 downto 0);
  							MAR <= PC + 1;
							state <= fetch;
						WHEN clear_opcode =>
							AC <= (others => '0');
		  					MAR <= PC + 1;
							state <= fetch;
						WHEN decr_opcode =>
							AC <= AC - 1;
		  					MAR <= PC + 1;
							state <= fetch;
						WHEN jump_opcode =>
							MAR <= data_in(7 DOWNTO 0);
							PC <= data_in(7 DOWNTO 0);
							state <= fetch;
						WHEN jz_opcode =>
							if AC=x"0000" then
								MAR <= data_in(7 DOWNTO 0);
								PC <= data_in(7 DOWNTO 0);
							else
								MAR <= PC + 1;
							end if;
							state <= fetch;
						WHEN out_opcode =>
						    state <= exec_out;
						WHEN OTHERS =>
						    state <= fetch;
					END CASE;
				WHEN exec_nop =>
  					MAR <= PC;
					state <= fetch;
				WHEN exec_load =>
					AC <= data_in;
					MAR <= PC;
					state <= fetch;
				WHEN exec_store =>
					data_out <= AC;
					wr <= '1';
					state <= exec_store2;
				WHEN exec_store2 =>
					wr <= '0';
					state <= exec_store3;
				WHEN exec_store3 =>
					MAR <= PC;
					state <= fetch;
				WHEN exec_add =>
					AC <= AC + data_in;				
  					MAR <= PC;
					state <= fetch;
				WHEN exec_out =>
					outbus <= AC;
					out_wr <= '1';
					state <= exec_out2;
				WHEN exec_out2 =>
					MAR <= PC;
					out_wr <= '0';
					state <= fetch;
				WHEN OTHERS =>
					MAR <= PC;
					state <= fetch;
				END CASE;
			END IF;
	END PROCESS;
END a;