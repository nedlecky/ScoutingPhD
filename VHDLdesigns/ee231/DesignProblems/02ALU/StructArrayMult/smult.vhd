-- Signed Array Multiplier
-- Ned Lecky 1/24/98

library ieee;
use ieee.std_logic_1164.all;
use work.nxnMult_pkg.all;
use work.absolute_pkg.all;
use work.complementer_pkg.all;

entity SMult is
	generic( width: integer := 5);
	port(
	a,b:	in std_logic_vector(width-1 downto 0);
	prod:	out std_logic_vector(width*2-1 downto 0));
end SMult;

architecture arch of SMult is
	-- absolute values of inputs have size width-1
	constant sizeAbsIn: integer := width-1;
	signal abs_a: std_logic_vector(sizeAbsIn-1 downto 0);
	signal abs_b: std_logic_vector(sizeAbsIn-1 downto 0);
	signal abs_prod: std_logic_vector(2*sizeAbsIn-1 downto 0);
	
	signal raw_prod: std_logic_vector(2*width-1 downto 0);
	signal comp_prod: std_logic_vector(2*width-1 downto 0);
	
begin
	-- establish abs_a and abs_b
	a1: absolute generic map(width)
		port map(x=>a,y=>abs_a);
	a2: absolute generic map(width)
		port map(x=>b,y=>abs_b);
		
	-- multiply these 2 width-1 bit numbers to get a 2w-2 bit number
	m1: nxnmult generic map (width-1) port map(a=>abs_a,b=>abs_b,prod=>abs_prod);

	-- load up signed raw_product (sign bit is 0)
	raw_prod(prod'high)<='0';
	raw_prod(prod'high-1)<='0';
	raw_prod(2*sizeAbsIn-1 downto 0)<=abs_prod;	
	
	-- establish complement of product
	c1: complementer generic map(prod'length)
		port map(x=>raw_prod,y=>comp_prod);
	
	process begin
		-- assign positive or negative product to output
		if((a(a'high) xor b(b'high)) = '1') then -- if signA <> signB
			prod<=comp_prod;
		else
			prod<=raw_prod;
		end if;
	end process;
	end;
