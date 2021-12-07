-- An N-bit x N-bit Unsigned Array Multiplier
-- Ned Lecky 1/24/98

-- Traditional array multiplier
library ieee;
use ieee.std_logic_1164.all;
use work.fulladder_pkg.all;

entity nxnMult is
	generic( width: integer := 4);
	port(
	a,b:	in std_logic_vector(width-1 downto 0);
	prod:	out std_logic_vector((width*2)-1 downto 0));
end nxnMult;

architecture nxnMult_arch of nxnMult is
	type andgrid is array(0 to width-1,width-1 downto 0) of std_logic;
	type sumgrid is array(0 to width-2,width-1 downto 0) of std_logic;
	type carrygrid is array(0 to width-2,width-2 downto 0) of std_logic;
	signal andouts: andgrid;
	signal sumouts: sumgrid;
	signal carryouts: carrygrid;
	signal ZERO: std_logic;
	begin

	-- logical zero for feeding carry chains and leftmost adders	
	ZERO<='0';
	
	-- the AND multiplier array
	gen: for i in 0 to width-1 generate
		gen2: for j in 0 to width-1 generate
			andouts(i,j)<=a(j) and b(i);
		end generate;
	end generate;

	-- bottom product bit is just the lowest andout
	prod(0)<=andouts(0,0);

	-- first row of FAs get first two rows of andouts as inputs	
	add0j: for i in 0 to width-1 generate
		g1: if i=0 generate  -- rightmost in row
		add00: fulladder port map(
			a=>andouts(0,1),b=>andouts(1,0),
			cin=>ZERO,
			sum=>prod(1),cout=>carryouts(0,0));
		end generate;
		g2: if i>=1 and i<width-1 generate -- interior adders
		add0j: fulladder port map(
			a=>andouts(0,i+1),b=>andouts(1,i),
			cin=>carryouts(0,i-1),
			sum=>sumouts(0,i-1),cout=>carryouts(0,i));
		end generate;
		g3: if i=width-1 generate -- leftmost in row
		add0wm1: fulladder port map(
			a=>ZERO,b=>andouts(1,i),
			cin=>carryouts(0,i-1),
			sum=>sumouts(0,i-1),cout=>sumouts(0,i));
		end generate;
	end generate;

	-- remaining rows of FA array get the and terms and an FA out as inputs
	addi: for i in 1 to width-2 generate
		addj: for j in 0 to width-1 generate
			g1: if j=0 generate -- rightmost in row
			addi0: fulladder port map(
				a=>sumouts(i-1,0),b=>andouts(i+1,0),
				cin=>ZERO,
				sum=>prod(i+1),cout=>carryouts(i,0));
			end generate;
			g2: if j>=1 and j<width-1 generate -- interior
			addij: fulladder port map(
				a=>sumouts(i-1,j),b=>andouts(i+1,j),
				cin=>carryouts(i,j-1),
				sum=>sumouts(i,j-1),cout=>carryouts(i,j));
			end generate;
			g3: if j=width-1 generate -- leftmost in row
			addiwm1: fulladder port map(
				a=>sumouts(i-1,j),b=>andouts(i+1,j),
				cin=>carryouts(i,j-1),
				sum=>sumouts(i,j-1),cout=>sumouts(i,j));
			end generate;
		end generate;
	end generate;

	-- Uppermost width product bits are the final sums; lower sum bits
	--  already stored into sum
	genf: for i in 1 to width generate
		prod((width*2)-i)<=sumouts(width-2,width-i);
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
 
