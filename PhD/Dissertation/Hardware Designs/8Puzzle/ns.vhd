library ieee;
use ieee.std_logic_1164.all;

entity NS is port(
	SIn:		in std_logic_vector(35 downto 0);
	AIn:		in std_logic_vector(7 downto 0);
	SOut:		out std_logic_vector(35 downto 0));
end;

architecture archNS of NS is
	alias fromIn: std_logic_vector(3 downto 0) is AIn(3 downto 0);
	alias toIn: std_logic_vector(3 downto 0) is AIn(7 downto 4);
	begin
	SOut <= SIn xor "010101010101010101010101010101010101";
end;

library ieee;
use ieee.std_logic_1164.all;
package NS_pkg is
	component NS port(
	SIn:		in std_logic_vector(35 downto 0);
	AIn:		in std_logic_vector(7 downto 0);
	SOut:		out std_logic_vector(35 downto 0));
	end component;
end;
