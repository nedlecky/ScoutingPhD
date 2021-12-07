-- n-bit LPM Adder

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY adderlpm IS
	GENERIC
	(
		width : integer := 16
	);
	PORT
	(
		x,y	: IN	STD_LOGIC_VECTOR(width-1 downto 0);
		s	: OUT	STD_LOGIC_VECTOR(width downto 0);
		ov	: out	STD_LOGIC
	);
END adderlpm;

ARCHITECTURE arch OF adderlpm IS
	-- grab the component definition by copying from MP2's Help window!
	-- note use of default values in generics and inputs, so we only have to specify
	-- those we wish to modify or use
	COMPONENT lpm_add_sub
	   GENERIC (LPM_WIDTH: POSITIVE;
	      LPM_REPRESENTATION: STRING := "SIGNED";
	      LPM_DIRECTION: STRING := "UNUSED";
	      LPM_PIPELINE: INTEGER := 0;
	      LPM_TYPE: STRING := "LPM_ADD_SUB";
	      LPM_HINT: STRING := "UNUSED");
	   PORT (dataa, datab: IN STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0);
	      aclr, clock, cin: IN STD_LOGIC := '0';
	      add_sub: IN STD_LOGIC := '1';
	      clken: IN STD_LOGIC := '1';
	      result: OUT STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0);
	      cout, overflow: OUT STD_LOGIC);
	END COMPONENT;
BEGIN
	-- now we just instantiate it, set necessary parameters, and wire it up
	adder: lpm_add_sub
		generic map
		(
			lpm_width => width, lpm_representation => "unsigned"
		)
		port map
		(
			dataa => x, datab => y, result => s(width-1 downto 0),
			cout => s(width), overflow => ov
		);
END arch;

