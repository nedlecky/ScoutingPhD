LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;
USE  IEEE.STD_LOGIC_ARITH.ALL;
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY LC2 IS
PORT(	clock, reset 	: IN STD_LOGIC;
        PC_out, IR_out 	: OUT STD_LOGIC_VECTOR( 15 DOWNTO 0 );
        MAR_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0 );
		MDR_out	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0 );
		CC_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END LC2;

ARCHITECTURE RTL OF LC2 IS
TYPE STATE_TYPE IS ( reset_S0, fetch_S1, fetch_S2, fetch_S3, decode_S4, rti_S5, add_S6,
	and_S7, not_S8, trap_S9, ret_S10, lea_S11, st_S12, str_S13, sti_S14, ldi_S15, ldr_S16,
	ld_S17, jsrr_S18, jsr_S19, br_S20, trap_S21, trap_S22,  sti_S23, sti_S24, st_S25, st_S26,
	ldi_S27, ldi_S28, ldi_S29, ldi_S30, jsrr_S31, jsrr_S32,  jsr_S33, jsr_S34, br_S35 ); 

TYPE register_file IS ARRAY ( 0 TO 7 ) OF STD_LOGIC_VECTOR( 15 DOWNTO 0 );

SIGNAL R	: register_file;
SIGNAL state: STATE_TYPE;
SIGNAL PC,MAR,MDR,IR,M,LC2_BUS,SR1,SR2, ALU, ZEXT, SEXT, 
	   addr, trapv, Ainput, Binput: STD_LOGIC_VECTOR(15 DOWNTO 0 );
SIGNAL SR1_addr, SR2_addr, DR_addr, CC: STD_LOGIC_VECTOR(2 downto 0);
SIGNAL BEN,N,Z,P,ready, write, ld_reg, setCC, write_clock : STD_LOGIC;

BEGIN
			-- Use LPM function for computer's memory (256 16-bit words)
  memory: lpm_ram_dq
      GENERIC MAP ( 
			lpm_widthad 	=> 8,
        	lpm_outdata 	=> "UNREGISTERED",
        	lpm_indata 		=> "REGISTERED",
       		lpm_address_control => "REGISTERED",
			-- Reads in mif file for initial program and data values
         	lpm_file 		=> "program.mif",
         	lpm_width 		=> 16 )
	PORT MAP (data => MDR, address => MAR(7 downto 0), we => write, inclock => write_clock, q => M );

    PC_out 		<= PC;
	IR_out		<= IR;
    MAR_out 	<= MAR;
    MDR_out 	<= MDR;
	CC_out      <= CC;
	write_clock <= NOT clock;
    -- Conditon Code Bits
	N <= LC2_BUS(15);
	Z <= '1' WHEN LC2_BUS = "0000000000000000" ELSE '0';
	P <= NOT LC2_BUS(15);
	ready <= '1';
	trapv <= "00000000" & IR(7 downto 0);
	addr <= PC(15 downto 9) & IR(8 downto 0);
	-- Read Register SR1 and SR2 Operation
	SR1_addr <= IR(8 downto 6);
	SR2_addr <= IR(2 downto 0);
	DR_addr <= IR(11 downto 9);
	SR1 <= R(CONV_INTEGER( SR1_addr ) );
	SR2 <= R(CONV_INTEGER( SR2_addr ) );
	-- Sign extend immediate value
	SEXT <= "11111111111" & IR(4 downto 0) WHEN IR(4) = '1' 
		ELSE "00000000000" & IR(4 downto 0);
	-- Zero extend immediate value
    ZEXT <= "0000000000" & IR(5 downto 0);
	-- Use one ALU for all add operations 
	-- (Synthesis tools tend to use a new adder for each "+" in VHDL)
	ALU <= Ainput + Binput;
	-- ALU input mux
	Ainput <= SR2 WHEN (IR(15 downto 12) = "0001" OR IR(15 Downto 12) = "0101") 
			AND IR(5) = '0' ELSE SEXT  
			WHEN (IR(15 downto 12) = "0001" OR IR(15 Downto 12) = "0101") 
			AND IR(5) = '1' ELSE ZEXT;
	Binput <= SR1;

PROCESS (clock, reset)
  BEGIN
	IF reset = '1' THEN
		state <= reset_S0;
			FOR i IN 0 TO 7 LOOP
				R(i) <= CONV_STD_LOGIC_VECTOR(i,16);
 			END LOOP;
	ELSIF(clock'EVENT and clock='1') THEN
		CASE state IS
	-- reset the computer, need to clear some registers
		WHEN reset_S0 =>
			PC 	<= "0000000000000000";
			state <= fetch_S1;
			write <= '0';
			setCC <= '0';
			ld_reg <= '0';
	-- Fetch instruction from memory and add 1 to PC
		WHEN fetch_S1 =>
			MAR <= PC;
			PC 	<= PC + 1;
			write <= '0';
	-- Update CC from last instruction?
			IF setCC = '1' THEN CC <= N & Z & P; END IF;
	-- Write to Register from last instruction?
			IF ld_reg = '1' THEN R(CONV_INTEGER(DR_addr)) <= LC2_BUS; END IF;
			setCC <= '0';
			ld_reg <='0';
			state <= fetch_S2;
		WHEN fetch_S2 =>
			MDR <= M;
			CASE ready IS
				WHEN '1' =>
				 state <= fetch_S3;
				WHEN others => 
				 state <= fetch_S2; 
			END CASE;
		WHEN fetch_S3 =>
			IR <= MDR;
			state <= decode_S4;
		WHEN decode_S4 =>
			BEN <= ((IR(11) AND N ) OR (IR(10) AND Z) OR (IR(9) AND P));
			-- decode instruction and jump to execute states
			CASE IR( 15 DOWNTO 12 ) IS
				WHEN "0000" =>
				    state 	<= br_S20;
				WHEN "0001" =>
				    state 	<= add_S6;
				WHEN "0010" =>
				    state 	<= ld_S17;		
				WHEN "0011" =>
				    state 	<= st_S12;
				WHEN "0100" =>
				    state 	<= jsr_S19;
				WHEN "0101" =>
				    state 	<= and_S7;
				WHEN "0110" =>
				    state 	<= ldr_S16;		
				WHEN "0111" =>
				    state 	<= str_S13;
				WHEN "1000" =>
				    state 	<= rti_S5;
				WHEN "1001" =>
				    state 	<= not_S8;
				WHEN "1010" =>
				    state 	<= ldi_S15;		
				WHEN "1011" =>
				    state 	<= sti_S14;
				WHEN "1100" =>
				    state 	<= jsrr_S18;
				WHEN "1101" =>
				    state 	<= ret_S10;
				WHEN "1110" =>
				    state 	<= lea_S11;		
				WHEN "1111" =>
				    state 	<= trap_S9;
				WHEN OTHERS =>
				    state 	<= fetch_S1;
			END CASE;
		-- Execute the instructions
		WHEN add_S6 =>
			LC2_BUS <= ALU;
			setCC <= '1';
			ld_reg <= '1';
			state <= fetch_S1;
		WHEN and_S7 =>
			LC2_BUS <= SR1 AND SR2;
			setCC <= '1';
			ld_reg <= '1';
			state <= fetch_S1;
		WHEN not_S8 =>
			LC2_BUS <= NOT SR1;
			setCC <= '1';
			ld_reg <= '1';
			state <= fetch_S1;
		WHEN ret_S10 =>
			PC <= R(7);
			state <= fetch_S1;
		WHEN lea_S11 =>
			LC2_BUS <= addr;
			state <= fetch_S1;
		WHEN trap_S9 =>
			MAR <= trapv;
			state <= trap_S21;
		WHEN trap_S21 =>
			MDR <= M;
			R(7) <= PC;
			CASE ready IS
				WHEN '1' =>
				 state <= trap_S22;
				WHEN others => 
				 state <= trap_S21; 
			END CASE;
		WHEN trap_S22 =>
			PC <= MDR;
			state <= fetch_S1;
		WHEN st_S12 =>
			MAR <= addr;
			state <= st_S25;
		WHEN st_S25 =>
			MDR <= LC2_BUS;
			state <= st_S26;
		WHEN st_S26 =>
			write <= '1';
			CASE ready IS
				WHEN '1' =>
				 state <= fetch_S1;
				WHEN others => 
				 state <= st_S26; 
			END CASE;
		WHEN str_S13 =>
			MAR <= ALU;
			state <= st_S25;
		WHEN sti_S14 =>
			MAR <= addr;
			state <= sti_S23;
		WHEN sti_S23 =>
			MDR <= M;
			CASE ready IS
				WHEN '1' =>
				 state <= sti_S24;
				WHEN others => 
				 state <= sti_S23; 
			END CASE;
		WHEN sti_S24 =>
			MAR <= MDR;
			state <= st_S25;
		WHEN ldi_S15 =>
			MAR <= addr;
			state <= ldi_S27;
		WHEN ldi_S27 =>
			MDR <= M;
			CASE ready IS
				WHEN '1' =>
				 state <= ldi_S28;
				WHEN others => 
				 state <= ldi_S27; 
			END CASE;
		WHEN ldi_S28 =>
			MAR <= MDR;
			state <= ldi_S29;
		WHEN ldi_S29 =>
			MDR <= M;
			CASE ready IS
				WHEN '1' =>
				 state <= ldi_S30;
				WHEN others => 
				 state <= ldi_S29; 
			END CASE;
		WHEN ldi_S30 =>
			LC2_BUS <= MDR ;
			ld_reg <= '1';
			setCC <= '1';
			state <= fetch_S1;
		WHEN ldr_S16 =>
			MAR <= ALU;
			state <= ldi_S29;
		WHEN ld_S17 =>
			MAR <= addr;
			state <= ldi_S29;
		WHEN jsrr_S18 =>
			CASE IR(11) IS
				WHEN '1' =>
				 state <= jsrr_S31;
				WHEN others => 
				 state <= jsrr_S32; 
			END CASE;
		WHEN jsrr_S31 =>
			R(7) <= PC ;
			state <= jsrr_S32;
		WHEN jsrr_S32 =>
			PC <= ALU;
			state <= fetch_S1;
		WHEN jsr_S19 =>
			CASE IR(11) IS
				WHEN '1' =>
				 state <= jsr_S33;
				WHEN others => 
				 state <= jsr_S34; 
			END CASE;
		WHEN jsr_S33 =>
			R(7) <= PC;
			state <= jsr_S34;
		WHEN jsr_S34 =>
			PC <= addr;
			state <= fetch_S1;
		WHEN br_S20 =>
			CASE BEN IS
				WHEN '1' =>
				 state <= br_S35;
				WHEN others => 
				 state <= fetch_S1; 
			END CASE;
		WHEN br_S35 =>
			PC <= addr;
			state <= fetch_S1;
		WHEN OTHERS =>
			state <= fetch_S1;
		END CASE;
	END IF;
  END PROCESS;
END RTL;

