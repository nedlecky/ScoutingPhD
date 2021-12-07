//Simple Computer Design
module SCOMP (clock,reset,program_counter,register_A, 
			  memory_data_register_out, instruction_register);

   input clock,reset;
   output [7:0] program_counter;
   output [15:0] register_A, memory_data_register_out, instruction_register;

   reg  [15:0] register_A,  instruction_register;
   reg  [7:0] program_counter;
   reg  [3:0] state;

// State Encodings
parameter	reset_pc 		= 0,
			fetch			= 1,
			decode			= 2,
			execute_add 	= 3,
			execute_store 	= 4,
			execute_store2 	= 5,
			execute_store3 	= 6,
			execute_load	= 7,
			execute_jump	= 8;

	reg [7:0] memory_address_register;
	reg memory_write;
	
	wire [15:0] memory_data_register;
	wire [15:0] memory_data_register_out = memory_data_register;
	wire [15:0] memory_address_register_out = memory_address_register;
	wire memory_write_out = memory_write;

// Use LPM function for computer's memory (256 16-bit words)
LPM_RAM_DQ	LPM_RAM_DQ_component (
				.address (memory_address_register_out),
				.inclock (clock),
				.data (register_A),
				.we (memory_write_out),
				.q (memory_data_register));
	defparam
		LPM_RAM_DQ_component.LPM_WIDTH = 16,
		LPM_RAM_DQ_component.LPM_WIDTHAD = 8,
		LPM_RAM_DQ_component.LPM_INDATA = "REGISTERED",
		LPM_RAM_DQ_component.LPM_ADDRESS_CONTROL = "UNREGISTERED",
		LPM_RAM_DQ_component.LPM_OUTDATA = "UNREGISTERED",
		LPM_RAM_DQ_component.USE_EAB = "ON",
// Reads in mif file for initial program and data values
		LPM_RAM_DQ_component.LPM_FILE = "program.mif";


   always @(posedge clock or posedge reset)
     begin
        if (reset)
            state = reset_pc;
        else 
			case (state)
// reset the computer, need to clear some registers
       		reset_pc :
       		begin
					program_counter = 8'b00000000;
					memory_address_register = 8'b00000000;
					register_A = 16'b0000000000000000;
					memory_write = 0;
					state = fetch;
       		end
// Fetch instruction from memory and add 1 to program counter
       		fetch :
       		begin
					instruction_register = memory_data_register;
					program_counter = program_counter + 1;
					memory_write = 0;
					state = decode;
       		end
// Decode instruction and send out address of any required data operands
       		decode :
       		begin
					memory_address_register = instruction_register[7:0];
					case (instruction_register[15:8])
						8'b00000000:
						    state = execute_add;
						8'b00000001:
						    state = execute_store;
						8'b00000010:
						    state = execute_load;
						8'b00000011:
						    state = execute_jump;
						default:
						    state = fetch;
					endcase
       		end
// Execute the ADD instruction
       		execute_add :
       		begin
					register_A = register_A + memory_data_register;
					memory_address_register = program_counter;
					state = fetch;
       		end
// Execute the STORE instruction (needs three clock cycles for memory write)
       		execute_store :
       		begin
// write register_A to memory
					memory_write = 1;
 					state = execute_store2;
// This state ensures that the memory address is valid until after memory_write goes low
       		end
       		execute_store2 :
       		begin
					memory_write = 0;
					state = execute_store3;
       		end
       		execute_store3 :
       		begin
					memory_address_register = program_counter;
					state = fetch;
// Execute the LOAD instruction
       		end
       		execute_load :
       		begin
					register_A = memory_data_register;
					memory_address_register = program_counter;
					state = fetch;
// Execute the JUMP instruction
       		end
       		execute_jump :
       		begin
 					memory_address_register = instruction_register[7:0];
					program_counter = instruction_register[7:0];
					state = fetch;
       		end
       		default :
       		begin
					memory_address_register = program_counter;
					memory_write = 0;
            		state = fetch;
       		end
		endcase
     end
endmodule



