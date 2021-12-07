LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY mult IS
	PORT(	A,B		: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			Product	: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0));
END mult;

ARCHITECTURE a OF mult IS
BEGIN
 multiply: lpm_mult
   GENERIC MAP(	LPM_WIDTHA => 8,
      			LPM_WIDTHB => 8,
				LPM_WIDTHS => 16,
      			LPM_WIDTHP => 16,
      			LPM_REPRESENTATION => "UNSIGNED")
   PORT MAP (	dataa => A,
      			datab => B,
      			result => Product);
END a;

