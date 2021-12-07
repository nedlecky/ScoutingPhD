-- MIPS Decode Module  (Register File)
-- 16-bit Version
-- Enhanced from Hamblen&Furman Rapid Prototyping of Digital Systems
-- Two versions: array based, and dual-port RAM based

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library lpm;
use lpm.lpm_components.all;

entity idecode is
	port
	(
		read_data_1	: out 	std_logic_vector(15 downto 0);
		read_data_2	: out 	std_logic_vector(15 downto 0);
		instruction : in 	std_logic_vector(31 downto 0);
		read_data 	: in 	std_logic_vector(15 downto 0);
		alu_result	: in 	std_logic_vector(15 downto 0);
		regwrite 	: in 	std_logic;
		memtoreg 	: in 	std_logic;
		regdst 		: in 	std_logic;
		sign_extend : out 	std_logic_vector(15 downto 0);
		clock,reset	: in 	std_logic
	);
end idecode;

architecture behavior of idecode is
	-- ARRAY Version
--	type register_file is array (0 to 7) of std_logic_vector(15 downto 0);
--	signal register_array				: register_file;

	signal write_register_address 		: std_logic_vector(4 downto 0);
	signal write_data					: std_logic_vector(15 downto 0);
	signal read_register_1_address		: std_logic_vector(4 downto 0);
	signal read_register_2_address		: std_logic_vector(4 downto 0);
	signal write_register_address_1		: std_logic_vector(4 downto 0);
	signal write_register_address_0		: std_logic_vector(4 downto 0);
	signal instruction_immediate_value	: std_logic_vector(15 downto 0);

begin
	read_register_1_address 	<= instruction(25 downto 21);
   	read_register_2_address 	<= instruction(20 downto 16);
   	write_register_address_1	<= instruction(15 downto 11);
   	write_register_address_0 	<= instruction(20 downto 16);
   	instruction_immediate_value <= instruction(15 downto 0);

	-- DP RAM Version
	reg1: lpm_ram_dp
		generic map
		(
			lpm_width => 16,
			lpm_widthad => 3,	-- limited to 8 regs
			lpm_indata => "registered",
			lpm_outdata => "unregistered",
			lpm_rdaddress_control => "unregistered",
			lpm_wraddress_control => "registered"
		)
		port map
		(
			rdaddress => read_register_1_address(2 downto 0),
			wraddress => write_register_address(2 downto 0),
			wrclock => clock,
			wren => regwrite,
			data => write_data,
			q => read_data_1
		);

	reg2: lpm_ram_dp
		generic map
		(
			lpm_width => 16,
			lpm_widthad => 3,	-- limited to 8 regs
			lpm_indata => "registered",
			lpm_outdata => "unregistered",
			lpm_rdaddress_control => "unregistered",
			lpm_wraddress_control => "registered"
		)
		port map
		(
			rdaddress => read_register_2_address(2 downto 0),
			wraddress => write_register_address(2 downto 0),
			wrclock => clock,
			wren => regwrite,
			data => write_data,
			q => read_data_2
		);

	-- ARRAY Version
	-- read register 1 operation
--	read_data_1 <= register_array(conv_integer(read_register_1_address(2 downto 0)));
--	read_data_2 <= register_array(conv_integer(read_register_2_address(2 downto 0)));

	-- mux for register write address
   	write_register_address <= write_register_address_1 when regdst = '1'
  			else write_register_address_0;

	-- mux to bypass data memory for rformat instructions
	write_data <= alu_result when (memtoreg='0')
		else read_data;

	-- no actual sign extension required until address width > 16
	sign_extend <= instruction_immediate_value(15 downto 0);

	-- ARRAY Process
--	process
--	begin
--			wait until rising_edge(clock);
--			if reset = '1' then
--				-- initial register values on reset are register = reg#
--				-- use loop to automatically generate reset logic 
--				-- for all registers
--				for i in 0 to 7 loop
--					register_array(i) <= conv_std_logic_vector(i, 16);
--	 			end loop;
--			-- write back to register - don't write to register 0
--			elsif regwrite = '1' and write_register_address /= 0 then
--		    	register_array(conv_integer(write_register_address(2 downto 0))) <= write_data;
--			end if;
--	end process;
end behavior;


