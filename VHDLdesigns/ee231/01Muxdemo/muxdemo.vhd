-- Mux demo with several variations

-- Includes a 1-bit 2-1 mux and a re-definable n-bit 3-1 mux
-- Each is implemented four different ways to demonstrate VHDL syntax

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity muxdemo is
	generic
	(
		width : integer := 4
	);
	port
	(
		x,y,z		: in	std_logic_vector(width-1 downto 0);
		s_xy		: in	std_logic;
		s_xyz		: in	std_logic_vector(1 downto 0);
		xy_mux1		: out	std_logic_vector(width-1 downto 0);
		xy_mux2		: out	std_logic_vector(width-1 downto 0);
		xy_mux3		: out	std_logic_vector(width-1 downto 0);
		xy_mux4		: out	std_logic_vector(width-1 downto 0);
		xyz_mux1	: out	std_logic_vector(width-1 downto 0);
		xyz_mux2	: out	std_logic_vector(width-1 downto 0);
		xyz_mux3	: out	std_logic_vector(width-1 downto 0);  -- semi=sep
		xyz_mux4	: out	std_logic_vector(width-1 downto 0) -- no semi
	);
	
end muxdemo;

architecture a of muxdemo is
begin

	-- Version 1:
	-- selected assignment (must be out of process)
	xy_mux1 <= x when s_xy='0' else y; 
	xyz_mux1 <= x when s_xyz="00" else y when s_xyz="01" else z;

	-- Version 2:
	-- select statement assignment (must be out of process)
	with s_xy select
		xy_mux2 <= 	x when '0',
					y when '1',
					x when others;  -- need others to deal with s_xy="X", etc.
	with s_xyz select
		xyz_mux2 <= 	x when "00",
						y when "01",
						z when others;  -- using others for "10" and "11" and "X0", etc.

	-- Version 3: Nested If (must be in-process)
	-- This is a bad way to do things!
	process (s_xy,s_xyz,x,y,z)
	begin
		if s_xy='0' then
			xy_mux3<=x;
		else
			xy_mux3<=y;
		end if;
		if s_xyz="00" then
			xyz_mux3<=x;
		else
			if s_xyz="01" then
				xyz_mux3<=y;
			else
				xyz_mux3<=z;
			end if;
		end if;
	end process;

	-- Version 4: Case statement (must be in-process)
	-- Like Select, but must be used in-process and can have
	--  several statements per action, all executed sequentially
	process (s_xy,s_xyz,x,y,z)
	begin
		case s_xy is
			when '0' =>
				xy_mux4<=x;
			when '1' =>
				xy_mux4<=y;
			when others =>
				xy_mux4<=x;
		end case;

		-- cute twist- interpret as integers; needs USE ieee.std_logic_unsigned.all 
		case conv_integer(s_xyz) is
			when 0 =>
				xyz_mux4<=x;
			when 1 =>
				xyz_mux4<=y;
			when 2 =>
				xyz_mux4<=z;
			when others =>
				xyz_mux4<=x;
		end case;
	end process;
end a;

