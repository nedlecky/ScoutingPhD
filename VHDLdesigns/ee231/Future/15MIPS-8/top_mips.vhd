-- MIPS Processor  (Top Level Design)
-- 8-bit Version
-- Enhanced from Hamblen&Furman Rapid Prototyping of Digital Systems

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity top_mips is
	port
	(
		reset, clock					: in 	std_logic; 
		-- output important signals to pins for easy display in simulator
		pc, alu_result_out, read_data_1_out, 
		read_data_2_out, write_data_out	: out 	std_logic_vector(7 downto 0);
     	instruction_out					: out 	std_logic_vector(31 downto 0);
		branch_out, zero_out, memwrite_out, 
		regwrite_out					: out 	std_logic
	);
end	top_mips;

architecture structure of top_mips is
	component ifetch
		port
		(
			instruction			: out 	std_logic_vector(31 downto 0);
        	pc_plus_4_out 		: out  	std_logic_vector(7 downto 0);
        	add_result 			: in 	std_logic_vector(7 downto 0);
        	branch 				: in 	std_logic;
        	zero 				: in 	std_logic;
        	pc_out 				: out 	std_logic_vector(7 downto 0);
        	clock,reset 		: in 	std_logic
		);
	end component; 

	component idecode
		port
		(
			read_data_1 		: out 	std_logic_vector(7 downto 0);
        	read_data_2 		: out 	std_logic_vector(7 downto 0);
        	instruction 		: in 	std_logic_vector(31 downto 0);
        	read_data 			: in 	std_logic_vector(7 downto 0);
        	alu_result 			: in 	std_logic_vector(7 downto 0);
        	regwrite, memtoreg 	: in 	std_logic;
        	regdst 				: in 	std_logic;
        	sign_extend 		: out 	std_logic_vector(7 downto 0);
        	clock, reset		: in 	std_logic
		);
	end component;

	component control
		port
		(
			opcode 				: in 	std_logic_vector(5 downto 0);
            regdst 				: out 	std_logic;
            alusrc 				: out 	std_logic;
            memtoreg 			: out 	std_logic;
            regwrite 			: out 	std_logic;
            memread 			: out 	std_logic;
            memwrite 			: out 	std_logic;
            branch 				: out 	std_logic;
            aluop 				: out 	std_logic_vector(1 downto 0)
		);
	end component;

	component execute
		port
		(
			read_data_1 		: in 	std_logic_vector(7 downto 0);
            read_data_2 		: in 	std_logic_vector(7 downto 0);
            sign_extend 		: in 	std_logic_vector(7 downto 0);
            function_opcode		: in 	std_logic_vector(5 downto 0);
            aluop 				: in 	std_logic_vector(1 downto 0);
            alusrc 				: in 	std_logic;
            zero 				: out	std_logic;
            alu_result 			: out	std_logic_vector(7 downto 0);
            add_result 			: out	std_logic_vector(7 downto 0);
            pc_plus_4 			: in 	std_logic_vector(7 downto 0)
		);
	end component;

	component dmemory
		port
		(
			read_data 			: out 	std_logic_vector(7 downto 0);
        	address 			: in 	std_logic_vector(7 downto 0);
        	write_data 			: in 	std_logic_vector(7 downto 0);
        	memread, memwrite 	: in 	std_logic;
        	clock				: in 	std_logic
		);
	end component;

	-- declare signals used to connect vhdl components
	signal pc_plus_4 		: std_logic_vector(7 downto 0);
	signal read_data_1 		: std_logic_vector(7 downto 0);
	signal read_data_2 		: std_logic_vector(7 downto 0);
	signal sign_extend 		: std_logic_vector(7 downto 0);
	signal add_result 		: std_logic_vector(7 downto 0);
	signal alu_result 		: std_logic_vector(7 downto 0);
	signal read_data 		: std_logic_vector(7 downto 0);
	signal alusrc 			: std_logic;
	signal branch 			: std_logic;
	signal regdst 			: std_logic;
	signal regwrite 		: std_logic;
	signal zero 			: std_logic;
	signal memwrite 		: std_logic;
	signal memtoreg 		: std_logic;
	signal memread 			: std_logic;
	signal aluop 			: std_logic_vector(1 downto 0);
	signal instruction		: std_logic_vector(31 downto 0);

begin
	-- copy important signals to output pins for easy 
	-- display in simulator
   instruction_out 	<= instruction;
   alu_result_out 	<= alu_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;
   write_data_out  	<= read_data when memtoreg = '1' else alu_result;
   branch_out 		<= branch;
   zero_out 		<= zero;
   regwrite_out 	<= regwrite;
   memwrite_out 	<= memwrite;	

	-- connect the 5 mips components   
	ife : ifetch
		port map
		(
			instruction 	=> instruction,
    	    pc_plus_4_out 	=> pc_plus_4,
			add_result 		=> add_result,
			branch 			=> branch,
			zero 			=> zero,
			pc_out 			=> pc,        		
			clock 			=> clock,  
			reset 			=> reset
		);

	id : idecode
	   	port map
		(
			read_data_1 	=> read_data_1,
        	read_data_2 	=> read_data_2,
        	instruction 	=> instruction,
        	read_data 		=> read_data,
			alu_result 		=> alu_result,
			regwrite 		=> regwrite,
			memtoreg 		=> memtoreg,
			regdst 			=> regdst,
			sign_extend 	=> sign_extend,
        	clock 			=> clock,  
			reset 			=> reset
		);

	ctl: control
		port map
		(
			opcode 			=> instruction(31 downto 26),
			regdst 			=> regdst,
			alusrc 			=> alusrc,
			memtoreg 		=> memtoreg,
			regwrite 		=> regwrite,
			memread 		=> memread,
			memwrite 		=> memwrite,
			branch 			=> branch,
			aluop 			=> aluop
		);

	exe: execute
		port map
		(
			read_data_1 	=> read_data_1,
            read_data_2 	=> read_data_2,
			sign_extend 	=> sign_extend,
            function_opcode	=> instruction( 5 downto 0 ),
			aluop 			=> aluop,
			alusrc 			=> alusrc,
			zero 			=> zero,
            alu_result		=> alu_result,
			add_result 		=> add_result,
			pc_plus_4		=> pc_plus_4
		);

	mem:  dmemory
		port map
		(
			read_data 		=> read_data,
			address 		=> alu_result,
			write_data 		=> read_data_2,
			memread 		=> memread, 
			memwrite 		=> memwrite, 
            clock 			=> clock
		);
end structure;

