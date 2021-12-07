-- Serial Divider

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity divider is
	port
	(
		reset,clock	: in	std_logic;
		s			: in	std_logic;
		A_in,B_in	: in	std_logic_vector(15 downto 0);
		Q_out		: out	std_logic_vector(15 downto 0);
		done		: out	std_logic
	);
end divider;

architecture a of divider is
	signal A : std_logic_vector(15 downto 0);
	signal B : std_logic_vector(15 downto 0);
	signal R,Q : std_logic_vector(15 downto 0);
	signal C : std_logic_vector(3 downto 0);
	type state_type is (S1,S2,S3,S4);
	signal state: state_type;
begin
	process(clock,reset)
	begin
		if reset='1' then
			state <= S1;
		elsif rising_edge(clock) then
			case state is
				when S1 =>
					if s='1' then state <= S2; end if;
					R <= (others=>'0');
					C <= x"F";
					if s='0' then
						A <= A_in;
						B <= B_in;
					end if;
				when S2 =>
					state <= S3;
					R <= R(14 downto 0) & A(15);
					A <= A(14 downto 0) & '0';
				when S3 =>
					C <= C-1;
					if R>=B then
						Q <= Q(14 downto 0) & '1';
						R <= R-B;
					else
						Q <= Q(14 downto 0) & '0';
					end if;
					if C=0 then state <= S4; else state <= S2; end if;
				when S4 =>
					if s='0' then state <= S1; end if;
			end case;
		end if;
	end process;
	Q_out <= Q;

	-- Any Moore outputs
	done <= '1' when state=S4 else '0';
end a;

