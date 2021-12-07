-- Counter01
-- Simple counter example
-- One traditional counter, and one non-standard sequence

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter01 is
	port
	(
		clk			: in	std_logic;						-- clock
		q1,q2		: out	std_logic_vector(3 downto 0)	-- outputs
	);
	
end counter01;

architecture a of counter01 is
begin
	-- traditional counter
	process (clk)
		variable qi : std_logic_vector(3 downto 0);
	begin
		wait until clk'event and clk='1';
		qi := qi + 1;
		q1 <= qi;
	end process;

	-- funky counter
	process (clk)
		variable qi : std_logic_vector(3 downto 0);
	begin
		wait until clk'event and clk='1';
		case qi is
			when "0000" => qi := "1010";
			when "1010" => qi := "1110";
			when "1110" => qi := "0011";
			when others => qi := "0000";
		end case;
		q2 <= qi;
	end process;
end a;

