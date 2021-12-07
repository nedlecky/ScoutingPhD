-- Design Problem 3B
-- Super register

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity superregister is
	generic (width : integer := 32);
	port
	(
		clock	: in std_logic;
		sel		: in std_logic_vector(2 downto 0);
		dist	: in std_logic_vector(1 downto 0);
		d		: in std_logic_vector(width-1 downto 0);
		q		: out std_logic_vector(width-1 downto 0)
	);
end superregister;

architecture arch of superregister is
	signal	qi : std_logic_vector(width-1 downto 0);
	signal	multmp : std_logic_vector(qi'high+2 downto 0);
	constant R_NOP 		: std_logic_vector(2 downto 0) := "000";
	constant R_CLEAR 	: std_logic_vector(2 downto 0) := "001";
	constant R_LOAD 	: std_logic_vector(2 downto 0) := "010";
	constant R_DECR 	: std_logic_vector(2 downto 0) := "011";
	constant R_INCR 	: std_logic_vector(2 downto 0) := "100";
	constant R_ROTR 	: std_logic_vector(2 downto 0) := "101";
	constant R_ROTL 	: std_logic_vector(2 downto 0) := "110";
	constant R_MUL7 	: std_logic_vector(2 downto 0) := "111";
begin
	-- hardlogic multiply by 7
	multmp <=	  ("00" & qi)
				+ ('0' & qi & '0')
				+ (qi & "00"); 

	-- the register
	process(clock)
	begin
		wait until rising_edge(clock);

		case sel is
			when R_CLEAR =>
				qi <= (others => '0');
			when R_LOAD =>
				qi <= d;
			when R_DECR =>
				qi <= qi-1;
			when R_INCR =>
				qi <= qi+1;
			when R_ROTR =>
				case dist is
					when "01" =>
						qi <= qi(0) & qi(qi'high downto 1);
					when "10" =>
						qi <= qi(1 downto 0) & qi(qi'high downto 2);
					when "11" =>
						qi <= qi(2 downto 0) & qi(qi'high downto 3);
					when others =>
				end case;
			when R_ROTL =>
				case dist is
					when "01" =>
						qi <= qi(qi'high-1 downto 0) & qi(qi'high);
					when "10" =>
						qi <= qi(qi'high-2 downto 0) & qi(qi'high downto qi'high-1);
					when "11" =>
						qi <= qi(qi'high-3 downto 0) & qi(qi'high downto qi'high-2);
					when others =>
				end case;
			when R_MUL7 =>
				qi <= multmp(qi'high downto 0);
			when others =>
		end case;
	end process;

	-- connect the outputs
	q <= qi;
end arch;


