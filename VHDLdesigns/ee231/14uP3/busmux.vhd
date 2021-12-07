-- busmux.vhd
-- Kick out high or low 8 bits of 16-bit bus
-- EE 231  Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;

entity busmux is
port
(
	input: in std_logic_vector(15 downto 0);
	output:	out std_logic_vector(7 downto 0);
	sel:	in	std_logic
);
END busmux;

architecture a of busmux is
begin
	output <= input(15 downto 8) when sel='0' else input(7 downto 0);
end a;

