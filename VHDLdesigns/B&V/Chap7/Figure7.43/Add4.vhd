-- megafunction wizard: %LPM_ADD_SUB%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: lpm_add_sub 

-- ============================================================
-- File Name: Add4.vhd
-- Megafunction Name(s):
-- 			lpm_add_sub
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD GENERATED FILE. DO NOT EDIT THIS FILE!
-- ************************************************************


--	Copyright (C) 1988-1998 Altera Corporation

--	Any megafunction design, and related net list (encrypted or decrypted),
--	support information, device programming or simulation file, and any other
--	associated documentation or information provided by Altera or a partner
--	under Altera's Megafunction Partnership Program may be used only to
--	program PLD devices (but not masked PLD devices) from Altera.  Any other
--	use of such megafunction design, net list, support information, device
--	programming or simulation file, or any other related documentation or
--	information is prohibited for any other purpose, including, but not
--	limited to modification, reverse engineering, de-compiling, or use with
--	any other silicon devices, unless such use is explicitly licensed under
--	a separate agreement with Altera or a megafunction partner.  Title to
--	the intellectual property, including patents, copyrights, trademarks,
--	trade secrets, or maskworks, embodied in any such megafunction design,
--	net list, support information, device programming or simulation file, or
--	any other related documentation or information provided by Altera or a
--	megafunction partner, remains with Altera, the megafunction partner, or
--	their respective licensors.  No other licenses, including any licenses
--	needed under any third party's intellectual property, are provided herein.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

ENTITY Add4 IS
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END Add4;


ARCHITECTURE SYN OF Add4 IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (3 DOWNTO 0);



	COMPONENT lpm_add_sub
	GENERIC (
		LPM_WIDTH		: POSITIVE;
		LPM_DIRECTION		: STRING;
		ONE_INPUT_IS_CONSTANT		: STRING
	);
	PORT (
			dataa	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	result    <= sub_wire0(3 DOWNTO 0);

	lpm_add_sub_component : lpm_add_sub
	GENERIC MAP (
		LPM_WIDTH => 4,
		LPM_DIRECTION => "ADD",
		ONE_INPUT_IS_CONSTANT => "NO"
	)
	PORT MAP (
		dataa => dataa,
		datab => datab,
		result => sub_wire0
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: nBit NUMERIC "4"
-- Retrieval info: PRIVATE: Function NUMERIC "0"
-- Retrieval info: PRIVATE: WhichConstant NUMERIC "0"
-- Retrieval info: PRIVATE: ConstantA NUMERIC "0"
-- Retrieval info: PRIVATE: ConstantB NUMERIC "0"
-- Retrieval info: PRIVATE: ValidCtA NUMERIC "0"
-- Retrieval info: PRIVATE: ValidCtB NUMERIC "0"
-- Retrieval info: PRIVATE: CarryIn NUMERIC "0"
-- Retrieval info: PRIVATE: CarryOut NUMERIC "0"
-- Retrieval info: PRIVATE: Overflow NUMERIC "0"
-- Retrieval info: PRIVATE: Latency NUMERIC "0"
-- Retrieval info: PRIVATE: aclr NUMERIC "0"
-- Retrieval info: PRIVATE: LPM_PIPELINE NUMERIC "0"
-- Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "4"
-- Retrieval info: CONSTANT: LPM_DIRECTION STRING "ADD"
-- Retrieval info: CONSTANT: ONE_INPUT_IS_CONSTANT STRING "NO"
-- Retrieval info: USED_PORT: result 0 0 4 0 OUTPUT NODEFVAL result[3..0]
-- Retrieval info: USED_PORT: dataa 0 0 4 0 INPUT NODEFVAL dataa[3..0]
-- Retrieval info: USED_PORT: datab 0 0 4 0 INPUT NODEFVAL datab[3..0]
-- Retrieval info: CONNECT: result 0 0 4 0 @result 0 0 4 0
-- Retrieval info: CONNECT: @dataa 0 0 4 0 dataa 0 0 4 0
-- Retrieval info: CONNECT: @datab 0 0 4 0 datab 0 0 4 0