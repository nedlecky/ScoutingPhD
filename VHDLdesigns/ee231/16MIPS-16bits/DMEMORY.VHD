-- MIPS Data Memory Module
-- 16-bit Version
-- Enhanced from Hamblen&Furman Rapid Prototyping of Digital Systems

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

library lpm;
use lpm.lpm_components.all;

entity dmemory is
	port
	(
		read_data 			: out 	std_logic_vector(15 downto 0);
        address 			: in 	std_logic_vector(7 downto 0);
        write_data 			: in 	std_logic_vector(15 downto 0);
	   	memread,memwrite	: in 	std_logic;
        clock				: in 	std_logic
	);
end dmemory;

architecture behavior of dmemory is
	signal lpm_write : std_logic;
begin
	data_memory: lpm_ram_dq
		generic map
		( 
			lpm_widthad 		=> 	8,
			lpm_outdata 		=> 	"unregistered",
			lpm_indata 			=> 	"registered",
			lpm_address_control => 	"unregistered",
			lpm_file 			=> 	"dmemory3.mif",
			lpm_width 			=> 	16
		)
		port map
		(
			data		=>	write_data,
			address		=> 	address, 
			we			=>	lpm_write,
			inclock		=> 	clock,
			q			=>  read_data
		);
		
	-- delay lpm write enable to ensure stable address and data
	lpm_write <= memwrite and ( not clock );
end behavior;

