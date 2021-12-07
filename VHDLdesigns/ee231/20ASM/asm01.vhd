-- ASM Bit Counter with Datapath

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity asm01 is
	port
	(
		reset,clock	: in	std_logic;
		LA_in,s		: in	std_logic;
		data		: in	std_logic_vector(15 downto 0);
		B_out		: out	std_logic_vector(4 downto 0);
		done		: out	std_logic
	);
end asm01;

architecture a of asm01 is
	signal A : std_logic_vector(15 downto 0);
	signal LA,EA : std_logic;
	signal B : std_logic_vector(4 downto 0);
	signal LB,EB : std_logic;
	signal z : std_logic;
	type state_type is (S1,S2,S3);
	signal state: state_type;
begin
	-- datapath elements
	-- A Register; sync load(LA=1,EA=1) or right shift(LA=0,EA=1)
	process(clock)
	begin
		wait until rising_edge(clock);
		if EA='1' then
			if LA='1' then
				A <= data;
			else
				A <= '0' & A(15 downto 1);
			end if;
		end if;
	end process;
	LA <= LA_in; -- direct drive!

	-- B Register; sync load(LB=1,EB=1) or increment(LB=0,EB=1)
	process(clock)
	begin
		wait until rising_edge(clock);
		if EB='1' then
			if LB='1' then
				B <= (others=>'0');
			else
				B <= B + 1;
			end if;
		end if;
	end process;
	B_out <= B;		-- count output

	-- Z flag
	z <= '1' when A=0 else '0';

	-- State Machine (State Transitions Only)
	process(clock,reset)
	begin
		if reset='1' then
			state <= S1;
		elsif rising_edge(clock) then
			case state is
				when S1 =>
					if s='1' then state <= S2; end if;
				when S2 =>
					if z='1' then state <= S3; end if;
				when S3 =>
					if s='0' then state <= S1; end if;
			end case;
		end if;
	end process;

	-- Outputs
	process(state,s,A(0),z)
	begin
		-- default control signals (want no implied latches!)
		EA <= '0';  LB <= '0'; EB <= '0';  done <= '0';
		case state is
			when S1 =>
				LB <= '1';  EB <= '1';
				if s='0' and LA='1' then EA <= '1'; end if;
			when S2 =>
				EA <= '1';
				if A(0)='1' then EB <= '1'; end if;
			when S3 =>
				done <= '1';
		end case;
	end process;
end a;

