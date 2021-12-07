-- A 4-bit Simple ALU Testbench
-- Ned Lecky 2/1/98
library ieee;
use ieee.std_logic_1164.all;
use work.std_arith.all;
use work.nALU_pkg.all;

entity ALU4 is
	port(
	A,B:	inout std_logic_vector(3 downto 0);
	sel:	inout std_logic_vector(3 downto 0);
	Cin:	inout std_logic;
	C:	inout std_logic_vector(3 downto 0);
	Cout,Z:	inout std_logic);
end;

architecture ALU4_arch of ALU4 is
	type test_vector is record
		A: std_logic_vector(3 downto 0);
		B: std_logic_vector(3 downto 0);
		sel: std_logic_vector(3 downto 0);
		Cin: std_logic;
		C: std_logic_vector(3 downto 0);
		Cout: std_logic;
		Z: std_logic;
	end record;
	type test_vector_array is array(natural range <>) of test_vector;
	constant test_vectors: test_vector_array(1 to 5) := (
		(A=>"0000",B=>"0000",sel=>ALU_ADD,Cin=>'0',C=>"0000",Cout=>'0',Z=>'1'),
		(A=>"0001",B=>"0001",sel=>ALU_ADD,Cin=>'1',C=>"0011",Cout=>'0',Z=>'0'),
		(A=>"0101",B=>"0101",sel=>ALU_ADD,Cin=>'0',C=>"1010",Cout=>'0',Z=>'0'),
		(A=>"0110",B=>"0101",sel=>ALU_ADD,Cin=>'0',C=>"1011",Cout=>'0',Z=>'0'),
		(A=>"1010",B=>"1001",sel=>ALU_ADD,Cin=>'0',C=>"0011",Cout=>'1',Z=>'0')
	);
begin
	-- create ALU4 for testing
	alu1: nALU generic map(4)
		port map(A,B,sel,Cin,C,Cout,Z);
		
	-- apply test vectors
	verify: process
		variable tv: test_vector;
		variable errors: boolean := false;
	begin
	for i in test_vectors'range loop
		-- get vector
		tv := test_vectors(i);
		
		-- hook it into the ALU
		A <= tv.A;
		B <= tv.B;
		Cin <= tv.Cin;
		sel <= tv.sel;
		
		Cin <= '1';	
		wait for 100 ns;
			
		-- check outputs
--		if Cin /= '1' then
--			assert false
--			report "Cin Failed";
--			errors := true;
--		end if;
--		if C /= tv.C then
--			assert false
--			report "C Failed";
--			errors := true;
--		end if;
--		if Cout /= tv.Cout then
--			assert false
--			report "Cout Failed";
--			errors := true;
--		end if;
--		if Z /= tv.Z then
--			assert false
--			report "Z Failed";
--			errors := true;
--		end if;
--	assert not errors
--		report "Test vectors failed."
--		severity note;
--	assert errors
--		report "Test vectors passed."
--		severity note;
	end loop;
	end process;
end;
