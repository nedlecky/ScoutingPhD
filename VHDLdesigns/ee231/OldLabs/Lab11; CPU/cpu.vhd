-- Simple CPU
-- John E. Lecky
-- 3/3/98

library ieee;
use ieee.std_logic_1164.all;
use work.std_arith.all;

entity CPU is port(
	clk,reset:	in std_logic;
	data:		inout std_logic_vector(7 downto 0);
	addr:		out std_logic_vector(15 downto 0);
	R,W:		out std_logic);
end;

architecture CPU_arch of CPU is
	-- OPCODE  constants
	constant deca:  std_logic_vector(4 downto 0) := "00000";
	constant inca:  std_logic_vector(4 downto 0) := "00001";
	constant rora:  std_logic_vector(4 downto 0) := "00010";
	constant asra:  std_logic_vector(4 downto 0) := "00011";
	constant asla:  std_logic_vector(4 downto 0) := "00100";
	constant incx:  std_logic_vector(4 downto 0) := "00101";
	constant decx:  std_logic_vector(4 downto 0) := "00110";
	constant rts:   std_logic_vector(4 downto 0) := "00111";
	constant bsr:   std_logic_vector(4 downto 0) := "01000";
	constant jmp:   std_logic_vector(4 downto 0) := "01001";
	constant jnz:   std_logic_vector(4 downto 0) := "01010";
	constant sta:   std_logic_vector(4 downto 0) := "01100";
	constant stx:   std_logic_vector(4 downto 0) := "01101";
	constant lda:   std_logic_vector(4 downto 0) := "10000";
	constant adda:  std_logic_vector(4 downto 0) := "10001";
	constant suba:  std_logic_vector(4 downto 0) := "10010";
	constant anda:  std_logic_vector(4 downto 0) := "10011";
	constant ora:   std_logic_vector(4 downto 0) := "10100";
	constant coma:  std_logic_vector(4 downto 0) := "10101";
	constant ldx:   std_logic_vector(4 downto 0) := "11000";

	-- ADDRESSING MODE CONSTANTS
	constant aNo:   std_logic_vector(2 downto 0) := "000";
	constant a8i:   std_logic_vector(2 downto 0) := "010";
	constant a16i:  std_logic_vector(2 downto 0) := "011";
	constant a8d:   std_logic_vector(2 downto 0) := "100";
	constant a16d:  std_logic_vector(2 downto 0) := "101";
	constant a8x:   std_logic_vector(2 downto 0) := "110";
	constant a16x:  std_logic_vector(2 downto 0) := "111";
	
	-- Register Set
	signal OP:      std_logic_vector(7 downto 0);
	signal A:      std_logic_vector(7 downto 0);
	signal X:      std_logic_vector(15 downto 0);
	signal RET:    std_logic_vector(15 downto 0);
	signal PC:     std_logic_vector(15 downto 0);
	signal MAR:    std_logic_vector(15 downto 0);
	signal MDR:    std_logic_vector(15 downto 0);
	signal Z,UseZ: std_logic;

	alias MDRhigh: std_logic_vector(7 downto 0) is MDR(15 downto 8);
	alias MDRlow:  std_logic_vector(7 downto 0) is MDR(7 downto 0);
	
	-- the execution unit
	type state is (Init,Fetch1,Fetch2,Get8imm,Get16imm,GetAddr,GetAddr2,
		Execute,Store8,Store16);
	signal PresentState: state;
	alias NextState:  state is PresentState;  -- enhances readability in 1-process model
	
	begin
	
	-- address bus is always driven by MAR
	addr <= MAR;
	
	main: process begin
		wait until clk='1';
		
		case (PresentState) is
		  -- Initialization state
		  when Init =>
			PC <= (others=> '0');
			A <= (others => '0');
			X <= (others => '0');
			MAR <= (others => '0');
			MDR <= (others => '0');
			RET <= (others => '0');
			NextState <= Fetch1;
			R <= '0';
			W <= '0';
			Z <= '0';
			UseZ <= '0';

		  -- Fetch 1 State; initiate opcode fetch
		  when Fetch1 =>
			MAR <= PC;
			PC <= PC + 1;
			R <= '1';
			W <= '0';
			NextState <= Fetch2;

		  -- Fetch 2 State; got the opcode in
		  when Fetch2 =>
			OP <= data;  -- keep a copy of the opcode
			
			-- don't drop the R line unless no additional operands
			if (data(2 downto 0) = "000") then
				R <= '0';
			else
				-- need operands
				R <= '1';
				-- put X to MAR if indirect, else recently incremented PC 
				if(data(2 downto 1) = "11") then
					MAR <= X;
				else
					MAR <= PC;
				end if;
			end if;

			-- Address Decoder			
			if(data(2 downto 1) = "00") then
				-- Immediate instructions (no operands from mem)
				NextState <= Execute;
			elsif (data(2 downto 1) = "01") then
				-- Direct/immediates need 8 or 16 bits
				if (data(0) = '0') then
					PC <= PC + 1;  -- skip data in instruction stream
					NextState <= Get8imm;
				else
					PC <= PC + 2;  -- skip data...
					NextState <= Get16imm;
				end if;
			elsif (data(2 downto 0) = "110") then
				-- Indirect 8 bits
				NextState <= Get8imm;
			elsif (data(2 downto 0) = "111") then
				-- Indirect 16 bits
				NextState <= Get16imm;
			else
				-- Direct; get address from stream, then fetch later
				PC <= PC + 2;
				NextState <= GetAddr;
			end if;
			
		  -- Get8imm State; Pull 8 bits from wherever MAR is now
		  when Get8imm =>
			MDRlow <= data;
			R <= '0';
			NextState <= Execute;
			
		  -- Get16imm State; Pull 8 bits from MAR, and bump it for next
		  when Get16imm =>
			MDRhigh <= data;
			MAR <= MAR + 1;
			NextState <= Get8imm;
			
		  -- GetAddr State; Pull first half of address from MAR
		  when GetAddr =>
			MDRhigh <= data;
			MAR <= MAR + 1;
			NextState <= GetAddr2;
			
		  -- GetAddr2 State; Get second half of addr
		  when GetAddr2 =>
			MAR <= MDRhigh & data;
			-- now; we need to fetch from the addr, either 8 or 16
			if (OP(0) = '0') then
				NextState <= Get8imm;
			else
				NextState <= Get16imm;
			end if;
			
		  -- Execute State; The Whole Enchilada
		  when Execute =>
		  	if (OP(7 downto 6) = "00") then -- immediates
				if(OP(5 downto 3) = "000") then
					-- DECA
					A <= A - 1;
					UseZ <= '0';
				elsif(OP(5 downto 3) = "001") then
					-- INCA
					A <= A + 1;
					UseZ <= '0';
				elsif(OP(5 downto 3) = "010") then
					-- RORA
					A <= A(0) & A(7 downto 1);
					UseZ <= '0';
				elsif(OP(5 downto 3) = "011") then
					-- ASRA
					A <= A(7) & A(7 downto 1);
					UseZ <= '0';
				elsif(OP(5 downto 3) = "100") then
					-- ASLA
					A <= A(7) & A(5 downto 0) & '0';
					UseZ <= '0';
				elsif(OP(5 downto 3) = "101") then
					-- INCX
					X <= X + 1;
				elsif(OP(5 downto 3) = "110") then
					-- DECX
					X <= X - 1;
				else
					-- RTS
					PC <= RET;
				end if;
				NextState <= Fetch1;
		  	elsif (OP(7 downto 5) = "010") then -- branch/jump
				if (OP(4 downto 3) = "00") then
					-- BSR
					RET <= PC;
					PC <= MDR;
				elsif (OP(4 downto 3) = "01") then
					-- JMP
					PC <= MDR;
				else
					-- JNZ
					-- (Since COMPA sets UseZ, and all other A-math
					--   clears it, we branch on Z if UseZ, and A/=0 oth)
					if (UseZ = '1') then
						if (Z = '1') then
							PC <= MDR;
						end if;
					elsif (A /= "00000000") then
						PC <= MDR;
					end if;
				end if;
				NextState <= Fetch1;
		  	elsif (OP(7 downto 5) = "011") then -- sta, stx
		  		if (OP(3) = '0') then
		  			-- STA
			  	  	MAR <= MDR;
			  	  	MDRlow <= A;
			  	  	NextState <= Store8;
		  		else
		  			-- STX
			  	  	MAR <= MDR;
			  	  	MDR <= X;
			  	  	NextState <= Store16;
		  		end if;
		  	elsif (OP(7 downto 6) = "10") then -- op a,mem
				if(OP(5 downto 3) = "000") then
					-- LDA
					A <= MDRlow;
					UseZ <= '0';
				elsif(OP(5 downto 3) = "001") then
					-- ADDA
					A <= A + MDRlow;
					UseZ <= '0';
				elsif(OP(5 downto 3) = "010") then
					-- SUBA
					A <= A - MDRlow;
					UseZ <= '0';
				elsif(OP(5 downto 3) = "011") then
					-- ANDA
					A <= A and MDRlow;
					UseZ <= '0';
				elsif(OP(5 downto 3) = "100") then
					-- ORA
					A <= A or MDRlow;
					UseZ <= '0';
				else
					-- COMA
					UseZ <= '1'; -- helps JNZ
					if (A = MDRlow) then
						Z <= '1';
					else
						Z <= '0';
					end if;
				end if;
				NextState <= Fetch1;
		  	else
				-- LDX
				X <= MDR;
				NextState <= Fetch1;
		  	end if;
		  	
		  -- Store8 State; Put out MDRlow to MAR
		  when Store8 =>
			data <= MDRlow;
			W <= '1';
			NextState <= Fetch1;
			
		  -- Store16 State; Put out MDRhigh to MAR and bump
		  when Store16 =>
			data <= MDRhigh;
			W <= '1';
			MAR <= MAR + 1;
			NextState <= Store8;
			
		  -- Safety Net
		  when others =>
		  	NextState <= Init;
		end case;
		
		-- Synchronous Reset override
		if (reset = '1') then
			NextState <= Init;
		end if;
	end process;
end;
	