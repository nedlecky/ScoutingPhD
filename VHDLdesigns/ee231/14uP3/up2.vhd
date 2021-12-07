-- uP3 Standalone Microprocessor
-- Datapath architecture
-- University of Vermont
-- EE 231  Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uP3 is
	port
	(
		clock, reset 	: in	std_logic;
        data_in 		: in	std_logic_vector(15 downto 0);
        data_out 		: out	std_logic_vector(15 downto 0);
        outbus	 		: out	std_logic_vector(15 downto 0);
        out_wr	 		: out	std_logic;
        addr 			: out	std_logic_vector(7 downto 0);
		rdy				: out	std_logic;
		wr				: out	std_logic
	);
end uP3;

architecture arch of uP3 is
	type alu_op is(alu_passa,alu_passb,alu_aplusb,alu aplus1,alu_aminus1,alu_zero);
		exec_store, exec_store2, exec_store3, exec_add, exec_addimm, exec_clear,
		exec_decr, exec_jump, exec_jz, exec_out, exec_out2
		);
	TYPE STATE_TYPE IS (resetA, fetch, decode, exec_nop, exec_load, exec_loadi,
		exec_store, exec_store2, exec_store3, exec_add, exec_addimm, exec_clear,
		exec_decr, exec_jump, exec_jz, exec_out, exec_out2
		);
	signal alu_ctl	:	alu_op;
	signal alu_a	:	std_logic_vector(15 downto 0);
	signal alu_b	:	std_logic_vector(15 downto 0);
	signal alu_out	:	std_logic_vector(15 downto 0);
	signal alu_z	:	std_logic;

	signal bmux_sel		:	std_logic;
	signal acmux_sel	:	std_logic;

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
	-- ALU
	process (alu_a,alu_b,alu_sel)
	begin
		case alu_sel is
			when alu_passa
				alu_out <= alu_a;
			when alu_passb
				alu_out <= alu_b;
			when alu_aplusb
				alu_out <= alu_a + alu_b;
			when alu_aplus1
				alu_out <= alu_aplus1;
			when alu_aminus1
				alu_out <= alu_aminus1;
			when others
				alu_out <= (others => '0');
		end case;
		alu_z <= (alu_out = (others=>'0'));
	end process;
	
		
	
	
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
				-- Fetch instruction from memory and add 1 to PC
				WHEN fetch =>
					IR <= data_in;
					PC <= PC + 1;
					state <= decode;
				-- Decode instruction and send out address of any data operands
				WHEN decode =>
					MAR <= IR(7 DOWNTO 0);
					CASE IR(15 DOWNTO 8) IS
						WHEN nop_opcode =>
							state <= exec_nop;
						WHEN load_opcode =>
						    state <= exec_load;		
						WHEN loadi_opcode =>
						    state <= exec_loadi;		
						WHEN store_opcode =>
						    state <= exec_store;
						WHEN add_opcode =>
						    state <= exec_add;
						WHEN addimm_opcode =>
						    state <= exec_addimm;
						WHEN clear_opcode =>
						    state <= exec_clear;
						WHEN decr_opcode =>
						    state <= exec_decr;
						WHEN jump_opcode =>
						    state <= exec_jump;
						WHEN jz_opcode =>
						    state <= exec_jz;
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
				WHEN exec_loadi =>
					MAR <= AC(7 downto 0);
					state <= exec_load;
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
				WHEN exec_addimm =>
					AC <= AC + IR(7 downto 0);
  					MAR <= PC;
					state <= fetch;
				WHEN exec_clear =>
					AC <= (others => '0');
  					MAR <= PC;
					state <= fetch;
				WHEN exec_decr =>
					AC <= AC - 1;
  					MAR <= PC;
					state <= fetch;
				WHEN exec_jump =>
					MAR <= IR(7 DOWNTO 0);
					PC <= IR(7 DOWNTO 0);
					state <= fetch;
				WHEN exec_jz =>
					if AC=x"0000" then
						MAR <= IR(7 DOWNTO 0);
						PC <= IR(7 DOWNTO 0);
					else
						MAR <= PC;
					end if;
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
