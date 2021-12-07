-- Serial Multiplier

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity smult is
	port
	(
		reset,clock	: in	std_logic;
		s			: in	std_logic;
		A_in,B_in	: in	std_logic_vector(15 downto 0);
		P_out		: out	std_logic_vector(31 downto 0);
		done		: out	std_logic
	);
end smult;

architecture a of smult is
	signal A : std_logic_vector(31 downto 0);
	signal B : std_logic_vector(15 downto 0);
	signal P : std_logic_vector(31 downto 0);
	type state_type is (S1,S2,S3);
	signal state: state_type;
begin
	-- State Machine (State Transitions Only)
	process(clock,reset)
	begin
		if reset='1' then
			state <= S1;
		elsif rising_edge(clock) then
			case state is
				when S1 =>
					if s='1' then state <= S2; end if;
					P <= (others=>'0');
					if s='0' then
						A <= x"0000" & A_in;
						B <= B_in;
					end if;
				when S2 =>
					if B=0 then state <= S3; end if;
					A <= A(30 downto 0) & '0';
					B <= '0' & B(15 downto 1);
					if B(0)='1' then P <= P + A; end if;
				when S3 =>
					if s='0' then state <= S1; end if;
					--done <= '1';  not here; Moore output gets implied latch!
			end case;
		end if;
	end process;
	P_out <= P;

	-- Any Moore outputs
	done <= '1' when state=S3 else '0';
end a;

