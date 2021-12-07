-- Synaptic NAND Mux
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
		rand			: IN	std_logic_vector(5 downto 0);
		clk				: IN	std_logic
	);
END syn_mux ;

ARCHITECTURE a OF syn_mux IS
	TYPE MuxSelectType is (MUX_ONE,MUX_X,MUX_NOTX);
	SIGNAL setup		: MuxSelectType;
	SIGNAL yout,errout	: std_logic;
BEGIN
	process(clk)
		VARIABLE errout : std_logic;
	begin
		if clk'event and clk='1' then
			errout:='0';
            if rand(5 downto 2) = "0000" then -- makes probablility of modifying synapse 1/16
				if (e_plus='1') then -- we might be a PLUS problem
					case setup is
						when MUX_ONE => -- currently selecting '1'
							-- nothing to do
							null;
						when MUX_X => -- currently selecting x
							if x='0' then
								case rand(1 downto 0) is
									when "00" =>
										setup <= MUX_ONE;
									when "01" =>
										setup <= MUX_NOTX;
									when "10" =>
										errout:='1';
									when others =>
										null;
								end case;
							end if;
						when others => -- MUX_NOTX
							if x='1' then
								case rand(1 downto 0) is
									when "00" =>
										setup <= MUX_ONE;
									when "01" =>
										setup <= MUX_X;
									when "10" =>
										errout:='1';
									when others =>
										null;
								end case;
							end if;
					end case;
				elsif (e_minus='1') then -- we might be a MINUS problem
					case setup is
						when MUX_ONE => -- currently selecting '1'
							if x='0' then setup <= MUX_X; else setup <= MUX_NOTX; end if;
						when MUX_X => -- currently selecting x
							if x='1' then
								if rand(0)='1' then
									setup <= MUX_NOTX;
								else
									errout:='1';
								end if;
							end if;
						when others => -- MUX_NOTX
							if x='0' then
								if rand(0)='1' then
									setup <= MUX_X;
								else
									errout:='1';
								end if;
							end if;
					end case;
				end if;
			end if;
		end if;
		err<=errout;
	end process;

	-- the mux
	with setup select
		yout <=	'1'		when MUX_ONE,
				x		when MUX_X,
				not x	when others; -- MUX_NOTX

	-- the outputs
	y <= yout;
END a;

