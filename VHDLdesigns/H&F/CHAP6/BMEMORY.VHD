LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY bmemory IS

   PORT(read_data 			: OUT std_logic_vector(7 DOWNTO 0);
        read_address 		: IN std_logic_vector(2 DOWNTO 0);
        write_data 			: IN std_logic_vector(7 DOWNTO 0);
        write_address 		: IN std_logic_vector(2 DOWNTO 0);
        Memwrite 			: IN std_logic;
        clock				: IN std_logic);

END bmemory;

ARCHITECTURE behavior OF bmemory IS
				-- define new data type for memory array
  TYPE memory_type IS ARRAY (0 TO 7) OF std_logic_vector(7 DOWNTO 0);  
  SIGNAL memory : memory_type;

BEGIN
				-- Read Memory 
				-- convert array index to an integer with CONV_INTEGER
	read_data <= memory(CONV_INTEGER(read_address(2 DOWNTO 0)));

				-- Write Memory?
 	PROCESS
 	BEGIN   
 		WAIT UNTIL clock'event and clock='1';
 		IF (memwrite = '1') THEN
				-- convert array index to an integer with CONV_INTEGER
			memory(CONV_INTEGER(write_address(2 DOWNTO 0))) <= write_data;
 		END IF;
 	END PROCESS;

END behavior;

