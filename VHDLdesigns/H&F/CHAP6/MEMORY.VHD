-- MEMORY 
-- Only 2 locations implemented - Addresses 0 and 1 are read/write
-- Locations set to initial values, imemx, on reset
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY memory IS

   PORT(read_data 			: OUT std_logic_vector(7 DOWNTO 0);
        read_address 		: IN std_logic_vector(2 DOWNTO 0);
        write_data 			: IN std_logic_vector(7 DOWNTO 0);
        write_address 		: IN std_logic_vector(2 DOWNTO 0);
        Memwrite 			: IN std_logic;
        clock,reset			: IN std_logic);

END memory;


ARCHITECTURE behavior OF memory IS

SIGNAL mem0, mem1 : std_logic_vector(7 DOWNTO 0);

BEGIN

					-- Process for memory read operation
 PROCESS (read_address, mem0, mem1)
 BEGIN
	CASE read_address IS
		WHEN "000" =>
	   	 	read_data <= mem0;
		WHEN "001" =>
	   	 	read_data <= mem1;
					-- unimplemented memory locations
		WHEN OTHERS =>
		    read_data <= "11111111";
	END CASE;
 END PROCESS;

          
					-- Process for memory write operation

 PROCESS
 	BEGIN   
 	WAIT UNTIL clock'event and clock='1';
   	IF (reset = '1') THEN
					-- initial values for memory (optional)
     	mem0 <= "01010101";
     	mem1 <= "10101010";
   	ELSE
					-- Write to memory?
					-- use a flip-flop with an enable for memory
     	IF memwrite = '1' THEN
			CASE write_address IS
				WHEN "000" =>
					mem0 <= write_data;
				WHEN "001" =>
	    			mem1 <= write_data;
					-- unimplemented memory locations
				WHEN OTHERS =>
	    			NULL;
			END CASE;
	 	END IF; 
   	END IF;
 END PROCESS;
END behavior;

