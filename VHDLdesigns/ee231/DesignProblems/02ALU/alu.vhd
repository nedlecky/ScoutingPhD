-- Design Problem #2
-- Simple ALU

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity alu is
	port
	(
		a,b			: in	signed(4 downto 0);
		result		: out	signed(9 downto 0);
		s			: in	std_logic_vector(2 downto 0);
		over		: out	std_logic
	);
end alu;

architecture arch of alu is
component rippleaddn is
	generic
	(
		width : integer := 16
	);
	PORT
	(
		x,y		: IN	STD_LOGIC_VECTOR(width-1 downto 0);
		s		: OUT	STD_LOGIC_VECTOR(width downto 0);
		cnm1	: OUT	STD_LOGIC -- second MSB carry
	);
end component;
component multiplier is
	port
	(
		x_in,y_in	: in	signed(4 downto 0);
		f			: out	signed(9 downto 0)
	);
end component;
	signal oper1,oper2 : signed(4 downto 0);
	signal oper1slv,oper2slv : std_logic_vector(4 downto 0);
	signal mult_out : signed(9 downto 0);
	signal adder_out : std_logic_vector(5 downto 0);
	signal cnm1 : std_logic;
begin

	-- operand selects for the single adder
	with s select
		oper1 <=	a when "000",
					a when "001",
					b when "010",
					b when "011",
					a when "100",
					a when "101",
					b when "110",
					a when others;

	with s select
		oper2 <=	conv_signed(1,5) when "000",
					-conv_signed(1,5) when "001",
					conv_signed(1,5) when "010",
					-conv_signed(1,5) when "011",
					b when "100",
					-b when "101",
					-a when "110",
					conv_signed(1,5) when others;

	-- the adder, including a passback of carry (sum MSB) and carry(n-1)
	adder1: rippleaddn 
		generic map (width => 5) 
		port map (oper1slv,oper2slv,adder_out,cnm1);

	-- the multiplier is always working
	mult1: multiplier PORT MAP (a,b,mult_out);

	-- makes VHDL happy sending signed to std_logic_vector w/no real action
	oper1slv <= std_logic_vector(oper1);
	oper2slv <= std_logic_vector(oper2);

	-- overflow logic- non on multiply, else xor carries in and out of MSB
	over <= '0' when s="111" else adder_out(5) xor cnm1;

	-- result mux based on whether we're multiplying
	result <= mult_out when s="111" else "00000" & signed(adder_out(4 downto 0));
end arch;


