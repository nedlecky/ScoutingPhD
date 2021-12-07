		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY control IS
   PORT( 	
	SIGNAL Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	SIGNAL RegDst 		: OUT 	STD_LOGIC;
	SIGNAL ALUSrc 		: OUT 	STD_LOGIC;
	SIGNAL MemtoReg 	: OUT 	STD_LOGIC;
	SIGNAL RegWrite 	: OUT 	STD_LOGIC;
	SIGNAL MemRead 		: OUT 	STD_LOGIC;
	SIGNAL MemWrite 	: OUT 	STD_LOGIC;
	SIGNAL Branch 		: OUT 	STD_LOGIC;
	SIGNAL ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS
   
COMPONENT LCELL
	PORT (	a_in	: IN STD_LOGIC; 
   			a_out	: OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL  R_format, Lw, Sw, Beq 	: STD_LOGIC;
	SIGNAL  Opcode_out				: STD_LOGIC_VECTOR( 5 DOWNTO 0 );

BEGIN           
	Op_Buf0: LCELL	PORT MAP ( a_in 	=> Opcode( 0 ), a_out => Opcode_out( 0 ) );
	Op_Buf1: LCELL	PORT MAP ( a_in	=> Opcode( 1 ), a_out => Opcode_out( 1 ) );
	Op_Buf2: LCELL	PORT MAP ( a_in	=> Opcode( 2 ), a_out => Opcode_out( 2 ) );
	Op_Buf3: LCELL	PORT MAP ( a_in	=> Opcode( 3 ), a_out => Opcode_out( 3 ) );
	Op_Buf4: LCELL	PORT MAP ( a_in	=> Opcode( 4 ), a_out => Opcode_out( 4 ) );
	Op_Buf5: LCELL	PORT MAP ( a_in	=> Opcode( 5 ), a_out => Opcode_out( 5 ) );

				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode_out = "000000"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode_out = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode_out = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode_out = "000100"  ELSE '0';
  	RegDst    	<=  R_format;
 	ALUSrc  	<=  Lw OR Sw;
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  R_format OR Lw;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch      <=  Beq;
	ALUOp( 1 ) 	<=  R_format;
	ALUOp( 0 ) 	<=  Beq; 

   END behavior;


