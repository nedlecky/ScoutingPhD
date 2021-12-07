-- LFSR 8
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY lfsr8 IS
	PORT
	(
		clk		: IN	STD_LOGIC;
		d		: OUT	STD_LOGIC_VECTOR(7 downto 0)
	);
	
END lfsr8;

ARCHITECTURE a OF lfsr8 IS
	SIGNAL s : STD_LOGIC_VECTOR(7 downto 0);
BEGIN
	process (clk)
	begin
		if (clk'event and clk='1') then
			if s="00000000" then
				s <= "00000001";
			else
				s <= s(6 downto 0) & (s(7) xor s(5) xor s(4) xor s(3));
			end if;
		end if;
	end process;
	d <= s;
END a;

