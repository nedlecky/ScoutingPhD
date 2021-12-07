-- An N-bit x N-bit Signed Array Multiplier
-- John E. Lecky 2/10/98

library ieee;
use ieee.std_logic_1164.all;
use work.adders_pkg.all;

entity nxnMult is
	generic( width: integer := 4);
	port(
	a,b:	in std_logic_vector(width-1 downto 0);
	prod:	out std_logic_vector((width*2)-1 downto 0));
end;

architecture nxnMult_arch of nxnMult is
	type andgrid is array(0 to width-1,width-1 downto 0) of std_logic;
	type sumgrid is array(0 to width-1,width downto 0) of std_logic;
	type carrygrid is array(0 to width-1,width-1 downto 0) of std_logic;
	signal ands: andgrid;
	signal sums: sumgrid;
	signal carries: carrygrid;
	attribute synthesis_off of ands,sums,carries: signal is true;
	begin

	-- the AND multiplier array
	gen: for i in 0 to width-1 generate
		gen2: for j in 0 to width-1 generate
			ands(i,j)<=a(j) and b(i);
		end generate;
	end generate;

	-- first row of FAs get first two rows of ands as inputs	
	add00: HA port map(
		a=>ands(0,1),b=>ands(1,0),
		sum=>sums(0,0),cout=>carries(0,0));
	add0j: for i in 1 to width-2 generate
		add0j: FA port map(
			a=>ands(0,i+1),b=>ands(1,i),
			cin=>carries(0,i-1),
			sum=>sums(0,i),cout=>carries(0,i));
	end generate;
	add0wm1: FAMMP port map(
		a=>ands(0,width-1),b=>ands(1,width-1), -- sign extension on a
		cin=>carries(0,width-2),
		sum=>sums(0,width-1),cout=>sums(0,width));

	-- interior rows of FA array get the and terms and an FA out as inputs
	addi: for i in 1 to width-3 generate
		addi0: HA port map(
			a=>sums(i-1,1),b=>ands(i+1,0),
			sum=>sums(i,0),cout=>carries(i,0));
		addj: for j in 1 to width-2 generate
			addij: FA port map(
				a=>sums(i-1,j+1),b=>ands(i+1,j),
				cin=>carries(i,j-1),
				sum=>sums(i,j),cout=>carries(i,j));
		end generate;
		addin: FAMMP port map(
			a=>sums(i-1,width),b=>ands(i+1,width-1),
			cin=>carries(i,width-2),
			sum=>sums(i,width-1),cout=>sums(i,width));
	end generate;

	-- last row of FA array
	addn0: HAMP port map(
		a=>ands(width-1,0),b=>sums(width-3,1),
		sum=>sums(width-2,0),cout=>carries(width-2,0));
	addnj: for j in 1 to width-2 generate
		addnj: FAMMP port map(
			a=>ands(width-1,j),b=>carries(width-2,j-1),
			cin=>sums(width-3,j+1),
			sum=>sums(width-2,j),cout=>carries(width-2,j));
	end generate;
	addnwm1: FAMMP port map(
		a=>sums(width-3,width),b=>carries(width-2,width-2),
		cin=>ands(width-1,width-1),
		sum=>sums(width-2,width-1),cout=>sums(width-2,width));

	-- Pull down result bits
	prod(0)<=ands(0,0);
	genp1: for i in 1 to width-2 generate
		prod(i) <= sums(i-1,0);
	end generate;
	genp2: for i in 0 to width generate
		prod(i+width-1) <= sums(width-2,i);
	end generate;
end;
 
library ieee;
use ieee.std_logic_1164.all;
package nxnMult_pkg is
	component nxnMult generic( width: integer := 4);
	port(
	a,b:	in std_logic_vector(width-1 downto 0);
	prod:	out std_logic_vector((width*2)-1 downto 0));
	end component;
end;
 