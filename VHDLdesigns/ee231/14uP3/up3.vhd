-- uP3 Standalone Microprocessor
-- Datapath architecture
-- University of Vermont
-- EE 231  Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity uP3 is
	port
	(
		clk, reset		: in	std_logic;
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
	signal AC			:	std_logic_vector(15 downto 0);
	signal AC_ld		:	std_logic;

	signal amux			:	std_logic_vector(15 downto 0);
	signal amux_sel		:	std_logic;

	signal bmux			:	std_logic_vector(15 downto 0);
	signal bmux_sel		:	std_logic_vector(2 downto 0);

	signal adder		:	std_logic_vector(15 downto 0);
	signal zflag		:	std_logic;

	signal MARmux		:	std_logic_vector(7 downto 0);
	signal MARmux_sel	:	std_logic_vector(1 downto 0);
	signal MAR			:	std_logic_vector(7 downto 0);
	signal MAR_ld		:	std_logic;

	signal ODR			:	std_logic_vector(15 downto 0);
	signal ODR_ld		:	std_logic;

	signal PCmux		:	std_logic_vector(7 downto 0);
	signal PCmux_sel	:	std_logic_vector(1 downto 0);

	signal PC			:	std_logic_vector(7 downto 0);
	signal PC_ld		:	std_logic;

	signal IR			:	std_logic_vector(15 downto 0);

	type statetype is (reset1, reset2, fetch, exec_nop, exec_load, exec_loadi,
						exec_store, exec_store2, exec_store3, exec_add, exec_addimm,
						exec_clear, exec_decr, exec_jump, exec_jz,
						exec_out, exec_out2);
	signal state		:	statetype;

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
	-- AC
	process (clk)
	begin
		wait until rising_edge(clk);
		if ac_ld='1' then
			AC <= adder;
		end if;
	end process;

	-- Amux
	amux <=		(others => '0') when amux_sel='0' else
				AC;

	-- Bmux
	bmux <=		(others => '0')				when bmux_sel="000" else
				data_in						when bmux_sel="001" else
				x"00" & IR(7 downto 0)		when bmux_sel="010" else
				x"0001"						when bmux_sel="011" else
				x"FFFF"						; --when bmux_sel="100" 

	-- Adder
	adder <= amux + bmux;

	-- Zero flag
	zflag <= '1' when AC=0 else '0';

	-- MARmux
	MARmux <=	PC						when MARmux_sel="00" else
				AC						when MARmux_sel="01" else
				IR(7 downto 0)			when MARmux_sel="10" else
				data_in(7 downto 0);

	-- MAR
	process (clk)
	begin
		wait until rising_edge(clk);
		if MAR_ld='1' then
			MAR <= marmux;
		end if;
	end process;

	-- ODR
	process (clk)
	begin
		wait until rising_edge(clk);
		if ODR_ld='1' then
			ODR <= AC;
		end if;
	end process;

	-- PCmux
	PCmux <=	(others => '0')		when PCmux_sel="00" else
				IR(7 downto 0)		when PCmux_sel="01" else
				PC+1;

	-- PC
	process (clk)
	begin
		wait until rising_edge(clk);
		if PC_ld='1' then
			PC <= PCmux;
		end if;
	end process;

	-- hard outputs
	addr <= MAR;
	outbus <= ODR;
	data_out <= adder;

	-- Next State Process
	process (clk,reset)
	begin
		IF reset = '1' then
			state <= reset1;
			rdy <= '0';
		elsif rising_edge(clk) then
			case state is
				when reset1 =>
					state <= reset2;
				when reset2 =>
					rdy <= '1';
					state <= fetch;
				when fetch =>
					IR <= data_in;   -- save original instr in case needed later
					case data_in(15 downto 8) is
						when nop_opcode =>
							state <= exec_nop;
						when load_opcode =>
							state <= exec_load;
						when loadi_opcode =>
						    state <= exec_loadi;		
						when store_opcode =>
						    state <= exec_store;
						when add_opcode =>
						    state <= exec_add;
						when addimm_opcode =>
						    state <= exec_addimm;
						when clear_opcode =>
						    state <= exec_clear;
						when decr_opcode =>
						    state <= exec_decr;
						when jump_opcode =>
						    state <= exec_jump;
						when jz_opcode =>
						    state <= exec_jz;
						when out_opcode =>
						    state <= exec_out;
						when OTHERS =>
						    state <= fetch;
					END CASE;
				when exec_nop =>
					state <= fetch;
				when exec_load =>
					state <= fetch;
				when exec_loadi =>
					state <= exec_load;
				when exec_store =>
		 			state <= exec_store2;
				when exec_store2 =>
					state <= exec_store3;
				when exec_store3 =>
					state <= fetch;
				when exec_add =>
					state <= fetch;
				when exec_addimm =>
					state <= fetch;
				when exec_clear =>
					state <= fetch;
				when exec_decr =>
					state <= fetch;
				when exec_jump =>
					state <= fetch;
				when exec_jz =>
					state <= fetch;
				when exec_out =>
					state <= exec_out2;
				when exec_out2 =>
					state <= fetch;
				when OTHERS =>
					state <= fetch;
				end case;
			end if;
	end process;

	-- Datapath Engine (All Combinational)
	process (state)
	begin
		-- default datapath config guarantees no implicit latches!
		AC_ld		<= '0';
		amux_sel	<= '0';
		bmux_sel	<= "000";
		ODR_ld		<= '0';
		PCmux_sel	<= "10";
		PC_ld		<= '0';
		out_wr		<= '0';
		wr			<= '0';

		-- default MAR <= PC at end unless state overrides it
		MARmux_sel <= "00";	-- MAR <= PC
		MAR_ld <= '1';

		case state is
			when reset1 =>
				-- zero AC
				amux_sel <= '0';		-- 0
				bmux_sel <= "000";		-- 0
				AC_ld <= '1';
				PCmux_sel <= "00";		-- 0
				PC_ld <= '1';

				out_wr <= '0';
				wr <= '0';
			when reset2 =>
				ODR_ld <= '1';			-- load ODR from zeroed AC
				MARmux_sel <= "01";		-- AC (=0)
				MAR_ld <= '1';
			when fetch =>
				PCmux_sel <= "10";		-- PC+1
				PC_ld <= '1';
				MARmux_sel <= "11";		-- data_in(7 downto 0)
				MAR_ld <= '1';
			when exec_nop =>
			when exec_load =>
				amux_sel	<= '0';		-- 0
				bmux_sel	<= "001";	-- data_in
				AC_ld		<= '1';
			when exec_loadi =>
				MARmux_sel <= "01";		-- AC
				MAR_ld <= '1';
			when exec_store =>
				amux_sel <= '1';		-- AC
				bmux_sel <= "000";		-- 0
				wr <= '1';
				MAR_ld <= '0';			-- leave address alone
			when exec_store2 =>
				amux_sel <= '1';		-- same as store
				bmux_sel <= "000";
				wr <= '0';				-- just cancel wr
				MAR_ld <= '0';			-- no address change
			when exec_store3 =>
			when exec_add =>
				amux_sel <= '1';		-- AC
				bmux_sel <= "001";		-- data_in
				AC_ld <= '1';
			when exec_addimm =>
				amux_sel <= '1';		-- AC
				bmux_sel <= "010";		-- IR(7 downto 0)
				AC_ld <= '1';
			when exec_clear =>
				amux_sel <= '0';		-- 0
				bmux_sel <= "000";		-- 0
				AC_ld <= '1';
			when exec_decr =>
				amux_sel <= '1';		-- AC
				bmux_sel <= "100";		-- -1
				AC_ld <= '1';
			when exec_jump =>
				PCmux_sel <= "01";		-- IR(7 downto 0)
				PC_ld <= '1';
				MARmux_sel <= "10";		-- IR(7 downto 0)
				MAR_ld <= '1';
			when exec_jz =>
				if zflag='1' then
					MARmux_sel <= "10";	-- IR(7 downto 0)
					MAR_ld <= '1';
					PCmux_sel <= "01";	-- IR(7 downto 0)
					PC_ld <= '1';
				end if;
			when exec_out =>
				ODR_ld <= '1';
				out_wr <= '1';
			when exec_out2 =>
				out_wr <= '0';
			when others =>
				state <= fetch;
			end case;
	end process;
end arch;
