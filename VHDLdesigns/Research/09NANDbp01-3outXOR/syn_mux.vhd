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
	type oscbits is array (0 to 1) of std_logic_vector(3 downto 0);
	TYPE MuxSelectType is (MUX_ZERO,MUX_ONE,MUX_X,MUX_NOTX);
	signal newerr			: std_logic;
	SIGNAL setup,newsetup	: MuxSelectType;
	SIGNAL yout				: std_logic;
	SIGNAL random			: std_logic_vector(3 downto 0);
	SIGNAL flippybits		: oscbits;
	SIGNAL flatch			: oscbits;
	SIGNAL lastx			: std_logic;

BEGIN
	flippybits(0) <= not flippybits(0);
	flippybits(1) <= not flippybits(1);

	process (clk)
	begin
		wait until rising_edge(clk);
		flatch(0)<=flippybits(0);
		flatch(1)<=flippybits(1);
		random<=flatch(0) xor flatch(1);
	end process;

	process(setup,lastx,e_plus,e_minus,yout,random(3 downto 0))
	begin
		newerr <= '0';
		newsetup <= setup;
		if	(e_plus='1' and yout ='0') or -- and random(3)='1') or  
			(e_minus='1' and yout ='1' and random(3 downto 2)="00") then
			case setup is
				when MUX_ZERO => -- currently selecting '0'
					-- change to either '1' or whichever of x, not x is '1'
					if random(0)='1' then
						newsetup <= MUX_ONE;
					else
						--if random(1)='1' then
							if lastx='1' then newsetup <= MUX_X; else newsetup <= MUX_NOTX; end if;
						--else
						--	if lastx='0' then newsetup <= MUX_X; else newsetup <= MUX_NOTX; end if;
						--	newerr <= '1';
						--end if;
					end if;
				when MUX_ONE => -- currently selecting '1'
					-- change to either '0' or whichever of x, not x is '0'
					if random(0)='1' then
						newsetup <= MUX_ZERO;
					else
						--if random(1)='1' then
							if lastx='0' then newsetup <= MUX_X; else newsetup <= MUX_NOTX; end if;
						--else
						--	if lastx='1' then newsetup <= MUX_X; else newsetup <= MUX_NOTX; end if;
						--	newerr <= '1';
						--end if;
					end if;
				when MUX_X => -- currently selecting x
					-- change to not x, 0/1 depending on which is not x, or signal error
					case random(1 downto 0) is
						when "00" =>
							newsetup <= MUX_NOTX;
						when "01" =>
							if lastx='0' then newsetup <= MUX_ONE; else newsetup <= MUX_ZERO; end if;
						when "10" =>
							newerr <= '1';
						when others =>
					end case;
				when others => -- MUX_NOTX
					-- change to x, 0/1 depending on which is x, or signal error
					case random(1 downto 0) is
						when "00" =>
							newsetup <= MUX_X;
						when "01" =>
							if not lastx='0' then newsetup <= MUX_ONE; else newsetup <= MUX_ZERO; end if;
						when "10" =>
							newerr <= '1';
						when others =>
					end case;
			end case;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			setup <= newsetup;
			lastx <= x;
		end if;
	end process;
	err <= newerr;

	-- the mux
	with setup select
		yout <=	'0'		when MUX_ZERO,
				'1'		when MUX_ONE,
				x		when MUX_X,
				not x	when others; -- MUX_NOTX

	-- the output
	y <= yout;
END a;

