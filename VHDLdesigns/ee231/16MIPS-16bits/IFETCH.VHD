-- MIPS Fetch Unit (Instruction Memory and PC)
-- 16-bit Version
-- Enhanced from Hamblen&Furman Rapid Prototyping of Digital Systems

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library lpm;
use lpm.lpm_components.all;

entity ifetch is
	port
	(
		signal instruction 		: out	std_logic_vector(31 downto 0);
       	signal pc_plus_4_out 	: out	std_logic_vector(7 downto 0);
       	signal add_result 		: in 	std_logic_vector(7 downto 0);
       	signal bne,beq 			: in 	std_logic;
       	signal zero 			: in 	std_logic;
    	signal pc_out 			: out	std_logic_vector(7 downto 0);
       	signal clock, reset 	: in 	std_logic
	);
end ifetch;

architecture behavior of ifetch is
	signal pc, pc_plus_4 	: std_logic_vector(9 downto 0);
	signal next_pc 			: std_logic_vector(7 downto 0);
begin
	--rom for instruction memory
	inst_memory: lpm_rom
		generic map
		( 
			lpm_widthad 		=> 8,
			lpm_outdata 		=> "unregistered",
			lpm_address_control => "unregistered",
			-- reads in mif file for initial data memory values
			lpm_file 			=> "program3.mif",
			lpm_width 			=> 32
		)
		port map
		( 
			address 	=> pc( 9 downto 2 ), 
			q 			=> instruction
		);

	-- copy output signals - allows read inside module
	pc_out 			<= pc(7 downto 0);
	pc_plus_4_out 	<= pc_plus_4(7 downto 0);

	-- adder to increment pc by 4        
	pc_plus_4(9 downto 2)  <= pc(9 downto 2) + 1;
	pc_plus_4(1 downto 0)  <= "00";

	-- mux to select branch address or pc + 4        
	next_pc  <= add_result when
		((beq='1') and (zero='1')) or ((bne='1') and (zero='0')) else
		pc_plus_4(9 downto 2);

	-- store pc in register and load next pc on clock edge
	process
	begin
		wait until rising_edge(clock);
		if reset='1' then
			pc <= "0000000000"; 
		else 
			pc(9 downto 2) <= next_pc;
		end if;
	end process;
end behavior;


