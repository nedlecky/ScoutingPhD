-- Synaptic Mux
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY syn_mux IS
	PORT
	(
		x				: IN	std_logic;
		e_plus,e_minus	: IN	std_logic;
		err				: OUT	std_logic;
		y				: OUT	std_logic;
		clk				: IN	std_logic
	);
	
END syn_mux ;

ARCHITECTURE a OF syn_mux IS
	TYPE MuxSelectType is (MUX_ZERO,MUX_ONE,MUX_X,MUX_NOTX);
	SIGNAL setup	: MuxSelectType;
	SIGNAL yout		: std_logic;
	SIGNAL random	: std_logic_vector(3 downto 0);
	SIGNAL flippybits : std_logic_vector(3 downto 0);

BEGIN
	-- random number generator
	flippybits <= not flippybits;

	-- latch random number on clock
	process (clk)
	begin
		if clk'event and clk='1' then
			random<=flippybits;
		end if;
	end process;

	process(clk)
	begin
		if clk'event and clk='1' then
			-- if neuron wants more ones, we give it with probability 1
			-- if neuron wants more zeros, we give it with probability 1/4
			if	(e_plus='1' and yout ='0') or --  and random(3 downto 2)="00") or  
				(e_minus='1' and yout ='1' and random(3 downto 2)="00") then -- we might be a problem
				case setup is
					when MUX_ZERO => -- currently selecting '0'
						-- change to either '1' or whichever of x, not x is '1'
						if random(0)='1' then
							setup <= MUX_ONE;
						else
							if x='1' then setup <= MUX_X; else setup <= MUX_NOTX; end if;
						end if;
						err <= '0';
					when MUX_ONE => -- currently selecting '1'
						-- change to either '0' or whichever of x, not x is '0'
						if random(0)='1' then
							setup <= MUX_ZERO;
						else
							if x='0' then setup <= MUX_X; else setup <= MUX_NOTX; end if;
						end if;
						err <= '0';
					when MUX_X => -- currently selecting x
						-- change to not x, 0/1 depending on which is not x, or signal error
						case random(1 downto 0) is
							when "00" =>
								setup <= MUX_NOTX;
								err <= '0';
							when "01" =>
								if x='0' then setup <= MUX_ONE; else setup <= MUX_ZERO; end if;
								err <= '0';
							when "10" =>
								err <= '1';
							when others =>
								err <= '0';
						end case;
					when others => -- MUX_NOTX
						-- change to x, 0/1 depending on which is x, or signal error
						case random(1 downto 0) is
							when "00" =>
								setup <= MUX_X;
								err <= '0';
							when "01" =>
								if not x='0' then setup <= MUX_ONE; else setup <= MUX_ZERO; end if;
								err <= '0';
							when "10" =>
								err <= '1';
							when others =>
								err <= '0';
						end case;
				end case;
			end if;
		end if;
	end process;

	-- the mux
	with setup select
		yout <=	'0'		when MUX_ZERO,
				'1'		when MUX_ONE,
				x		when MUX_X,
				not x	when others; -- MUX_NOTX

	-- the output
	y <= yout;
END a;

