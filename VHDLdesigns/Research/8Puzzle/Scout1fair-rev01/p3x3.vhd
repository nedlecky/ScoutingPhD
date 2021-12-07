-- 8 Puzzle Scout
-- Scout-1
-- J.E. Lecky 5-2002

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity p3x3 is port
	(
		clk:	in std_logic;
		reinit:	in std_logic;
		init:	in std_logic_vector(35 downto 0);

		solved:	out std_logic
	);
end;

architecture p3x3_arch of p3x3 is
	subtype cur4 is std_logic_vector(3 downto 0);
	type state_type is array(0 to 8) of cur4;
	signal state: state_type;
	signal stateswap1: cur4;
	signal last: 	integer range 0 to 9;
	signal swap0,swap1,swap1_copy: integer range 0 to 8;
	signal step1:	std_logic;
	signal solved_int:	std_logic;
	type randosc is array(0 to 1) of std_logic_vector(3 downto 0);
	signal flippybits:	randosc;
	signal rand:	std_logic_vector(3 downto 0);
	signal r2: std_logic;
	signal r3,r4: std_logic_vector(1 downto 0);
begin
	-- random number generator
	flippybits(0) <= not flippybits(0);
	flippybits(1) <= not flippybits(1);

	-- latch random number on clock
	process (clk)
	begin
		if rising_edge(clk) then
			rand <= flippybits(0) xor flippybits(1);
--			rand<=rand+1;
		end if;
	end process;
	-- r2, r3 and r4
	r2 <= rand(0);
--	r3 <= rand(1 downto 0);
	r3 <=	"00" when rand<=5 else
			"10" when rand>=10 else
			"01";
	r4 <= rand(1 downto 0);

	-- Goal Check Block
	solved_int <= '1' when
		state(0)=1 and state(1)=2 and state(2)=3 and
		state(3)=8 and state(4)=0 and state(5)=4 and
		state(6)=7 and state(7)=6 and state(8)=5
	else '0';
	solved <= solved_int;

	-- Pick Action Block
	process(state,r2,r3,r4,last) begin
		swap0 <= 0;
		swap1 <= 0;

		-- Blank in square 0
		if state(0)=0 then
			swap0 <= 0;
			if last=1 then
				swap1 <= 3;
			elsif last=3 then
				swap1 <= 1;
			else
				if r2='0' then
					swap1 <= 1;
				else
					swap1 <= 3;
				end if;
			end if;
		end if;

		-- Blank in square 1
		if state(1)=0 then
			swap0 <= 1;
			if last=0 then
				if r2='0' then
					swap1 <= 2;
				else
					swap1 <= 4;
				end if;
			elsif last=2 then
				if r2='0' then
					swap1 <= 0;
				else
					swap1 <= 4;
				end if;
			elsif last=4 then
				if r2='0' then
					swap1 <= 0;
				else
					swap1 <= 2;
				end if;
			else
				case r3 is
					when "00" => swap1 <= 0;
					when "01" => swap1 <= 2;
					when others => swap1 <= 4;
				end case;
			end if;
		end if;

		-- Blank in square 2
		if state(2)=0 then
			swap0 <= 2;
			if last=1 then
				swap1 <= 5;
			elsif last=5 then
				swap1 <= 1;
			else
				if r2='0' then
					swap1 <= 1;
				else
					swap1 <= 5;
				end if;
			end if;
		end if;

		-- Blank in square 3
		if state(3)=0 then
			swap0 <= 3;
			if last=0 then
				if r2='0' then
					swap1 <= 4;
				else
					swap1 <= 6;
				end if;
			elsif last=4 then
				if r2='0' then
					swap1 <= 0;
				else
					swap1 <= 6;
				end if;
			elsif last=6 then
				if r2='0' then
					swap1 <= 0;
				else
					swap1 <= 4;
				end if;
			else
				case r3 is
					when "00" => swap1 <= 0;
					when "01" => swap1 <= 4;
					when others => swap1 <= 6;
				end case;
			end if;
		end if;

		-- Blank in square 4
		if state(4)=0 then
			swap0 <= 4;
			if last=1 then
				case r3 is
					when "00" => swap1 <= 3;
					when "01" => swap1 <= 5;
					when others => swap1 <= 7;
				end case;
			elsif last=3 then
				case r3 is
					when "00" => swap1 <= 1;
					when "01" => swap1 <= 5;
					when others => swap1 <= 7;
				end case;
			elsif last=5 then
				case r3 is
					when "00" => swap1 <= 1;
					when "01" => swap1 <= 3;
					when others => swap1 <= 7;
				end case;
			elsif last=7 then
				case r3 is
					when "00" => swap1 <= 1;
					when "01" => swap1 <= 3;
					when others => swap1 <= 5;
				end case;
			else
				case r4 is
					when "00" => swap1 <= 1;
					when "01" => swap1 <= 3;
					when "10" => swap1 <= 5;
					when others => swap1 <= 7;
				end case;
			end if;
		end if;

		-- Blank in square 5
		if state(5)=0 then
			swap0 <= 5;
			if last=2 then
				if r2='0' then
					swap1 <= 4;
				else
					swap1 <= 8;
				end if;
			elsif last=4 then
				if r2='0' then
					swap1 <= 2;
				else
					swap1 <= 8;
				end if;
			elsif last=8 then
				if r2='0' then
					swap1 <= 2;
				else
					swap1 <= 4;
				end if;
			else
				case r3 is
					when "00" => swap1 <= 2;
					when "01" => swap1 <= 4;
					when others => swap1 <= 8;
				end case;
			end if;
		end if;

		-- Blank in square 6
		if state(6)=0 then
			swap0 <= 6;
			if last=3 then
				swap1 <= 7;
			elsif last=7 then
				swap1 <= 3;
			else
				if r2='0' then
					swap1 <= 3;
				else
					swap1 <= 7;
				end if;
			end if;
		end if;

		-- Blank in square 7
		if state(7)=0 then
			swap0 <= 7;
			if last=4 then
				if r2='0' then
					swap1 <= 6;
				else
					swap1 <= 8;
				end if;
			elsif last=6 then
				if r2='0' then
					swap1 <= 4;
				else
					swap1 <= 8;
				end if;
			elsif last=8 then
				if r2='0' then
					swap1 <= 4;
				else
					swap1 <= 6;
				end if;
			else
				case r3 is
					when "00" => swap1 <= 4;
					when "01" => swap1 <= 6;
					when others => swap1 <= 8;
				end case;
			end if;
		end if;

		-- Blank in square 8
		if state(8)=0 then
			swap0 <= 8;
			if last=5 then
				swap1 <= 7;
			elsif last=7 then
				swap1 <= 5;
			else
				if r2='0' then
					swap1 <= 5;
				else
					swap1 <= 7;
				end if;
			end if;
		end if;
	end process;

	-- Next State Block
	process(clk)
	begin
		wait until rising_edge(clk);
		if reinit='1' then
			state(0) <= init(35 downto 32);
			state(1) <= init(31 downto 28);
			state(2) <= init(27 downto 24);
			state(3) <= init(23 downto 20);
			state(4) <= init(19 downto 16);
			state(5) <= init(15 downto 12);
			state(6) <= init(11 downto 8);
			state(7) <= init(7 downto 4);
			state(8) <= init(3 downto 0);
			last <= 9;
			step1 <= '1';
		else
			if solved_int='0' then
				if step1='1' then
					state(swap0) <= state(swap1);
					swap1_copy <= swap1;
					step1 <= '0';
					last <= swap0;
				else
					state(swap1_copy) <= x"0";
					step1 <= '1';
				end if;
			end if;
--			state(swap0) <= state(swap1);
--			state(swap1) <= state(swap0);
--			last <= swap0;
		end if;
	end process;
end;
 

