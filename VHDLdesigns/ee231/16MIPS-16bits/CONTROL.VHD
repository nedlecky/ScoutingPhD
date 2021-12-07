-- MIPS Control Module
-- 16-bit Version
-- Enhanced from Hamblen&Furman Rapid Prototyping of Digital Systems

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
library lpm;
use lpm.lpm_components.all;

entity control is
	port
	( 	
		opcode		: in 	std_logic_vector(5 downto 0);
		regdst 		: out	std_logic;
		alusrc 		: out	std_logic;
		memtoreg 	: out	std_logic;
		regwrite 	: out	std_logic;
		memread 	: out	std_logic;
		memwrite 	: out	std_logic;
		bne,beq		: out	std_logic;
		r_format	: out	std_logic;
		branch		: out	std_logic
	);
end control;

architecture behavior of control is
	signal  r_format_i,lw,sw,bne_i,beq_i	: std_logic;
begin           
	-- code to generate control signals using opcode bits
	r_format_i	<=  '1'  when  opcode = "000000"  else '0';
	r_format	<=	r_format_i;
	lw			<=  '1'  when  opcode = "100011"  else '0';
 	sw			<=  '1'  when  opcode = "101011"  else '0';
   	beq_i		<=  '1'  when  opcode = "000100"  else '0';
   	bne_i		<=  '1'  when  opcode = "000101"  else '0';
  	regdst		<=  r_format_i;
 	alusrc		<=  lw or sw;
	memtoreg	<=  lw;
  	regwrite	<=  r_format_i or lw;
  	memread		<=  lw;
   	memwrite	<=  sw; 
	branch		<=  beq_i or bne_i; 
	bne			<=	bne_i;
	beq			<=	beq_i;
end behavior;

