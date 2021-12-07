LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;


ENTITY amemory IS
 
   PORT(read_data 			: OUT std_logic_vector(7 DOWNTO 0);
        memory_address 		: IN std_logic_vector(2 DOWNTO 0);
        write_data 			: IN std_logic_vector(7 DOWNTO 0);
        Memwrite 			: IN std_logic;
        clock,reset			: IN std_logic);

END amemory;

ARCHITECTURE behavior OF amemory IS
BEGIN

data_memory: lpm_ram_dq
      GENERIC MAP (	lpm_widthad 		=> 3,
        			lpm_outdata 		=> "UNREGISTERED",
        			lpm_indata 			=> "REGISTERED",
        			lpm_address_control => "UNREGISTERED",
					-- Reads in mif file for initial data values
         			lpm_file 			=> "memory.mif",
         			lpm_width 			=> 8)

      PORT MAP (data => write_data, address => memory_address(2 DOWNTO 0), 
                we => Memwrite, inclock => clock, q => read_data);

END behavior;

