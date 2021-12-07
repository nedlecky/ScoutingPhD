-- 02Combinational Example
-- Simple implementation variations starting with a truth table

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY combinational is
	PORT
	(
		a,b,c		: IN	STD_LOGIC;
		f1,f2,f3	: OUT	STD_LOGIC
	);
END combinational ;

ARCHITECTURE arch OF combinational IS
	signal abc : std_logic_vector(2 downto 0);
BEGIN
	-- Useful concatenation transform
	abc <= a & b & c;

	-- Version 1: Select Statement
	-- Like a truth table
	WITH abc SELECT
		f1 <=	'0' WHEN "000",
				'1' WHEN "001",
				'0' WHEN "010",
				'1' WHEN "011",
				'0' WHEN "100",
				'1' WHEN "101",
				'1' WHEN "110",
				'1' WHEN others; -- Errors if you say "111"!

	-- Version 2: Select Statement
	-- Like an abbreviated truth table (0s only)
	WITH abc SELECT
		f2 <=	'0' WHEN "000"|"010"|"100",
				'1' WHEN others;

	-- Version 3: Select Statement with integers
	-- Like saying f3=POS(0,2,4)
	WITH conv_integer(abc) SELECT
		f3 <=	'0' WHEN 0|2|4,
				'1' WHEN others;
END arch;

