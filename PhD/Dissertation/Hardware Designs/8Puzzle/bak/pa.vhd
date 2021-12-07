library ieee;
use ieee.std_logic_1164.all;

entity PA is port(
	SIn:		in std_logic_vector(35 downto 0);
	random:		in std_logic_vector(7 downto 0);
	AIn:		in std_logic_vector(7 downto 0);
	AOut:		out std_logic_vector(7 downto 0));
end;

architecture archPA of PA is
	alias fromOut: std_logic_vector(3 downto 0) is AOut(3 downto 0);
	alias toOut: std_logic_vector(3 downto 0) is AOut(7 downto 4);
	alias fromIn: std_logic_vector(3 downto 0) is AIn(3 downto 0);
	alias toIn: std_logic_vector(3 downto 0) is AIn(7 downto 4);
	begin
	fromOut <= fromIn xor "1100";
	toOut <= toIn xor "0101";
end;

library ieee;
use ieee.std_logic_1164.all;
package PA_pkg is
	component PA port(
	SIn:		in std_logic_vector(35 downto 0);
	random:		in std_logic_vector(7 downto 0);
	AIn:		in std_logic_vector(7 downto 0);
	AOut:		out std_logic_vector(7 downto 0));
	end component;
end;
