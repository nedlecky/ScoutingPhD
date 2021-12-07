library ieee;
use ieee.std_logic_1164.all;

entity LFSR8 is port(
	clk:		in std_logic;
	rand:		out std_logic_vector(7 downto 0));
end;

architecture archLFSR8 of LFSR8 is
	begin
	rand <= "01011010";
end;

library ieee;
use ieee.std_logic_1164.all;
package LFSR8_pkg is
	component LFSR8 port(
	clk:		in std_logic;
	rand:		out std_logic_vector(7 downto 0));
	end component;
end;
