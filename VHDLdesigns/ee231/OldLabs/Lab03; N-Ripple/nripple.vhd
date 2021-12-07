-- An N-bit Ripple Adder
library ieee;
use ieee.std_logic_1164.all;
use work.full_adder_pkg.all;

entity nripple is generic( width: integer := 4);
	port(
	a,b:	in std_logic_vector(width-1 downto 0);
	cin:	in std_logic;
	sum:	out std_logic_vector(width downto 0));
end;

architecture nripple_arch of nripple is
	signal carry: std_logic_vector(width-1 downto -1);
	attribute synthesis_off of carry: signal is true;
	begin
	carry(-1)<=cin; -- trick to handle input carry to LSB adder
	
	gen: for i in 0 to width-1 generate
		adder: full_adder port map(a=>a(i),b=>b(i),
		cin=>carry(i-1),sum=>sum(i),cout=>carry(i));
	end generate;

	-- attach final cout to MSB of sum
	sum(width)<=carry(width-1);
end;
 
library ieee;
use ieee.std_logic_1164.all;
package nripple_pkg is
	component nripple generic( width: integer := 4);
	port(
	a,b:	in std_logic_vector(width-1 downto 0);
	cin:	in std_logic;
	sum:	out std_logic_vector(width downto 0));
	end component;
end;
 