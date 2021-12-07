module ALU ( ALU_control, Ainput, Binput, Clock, Shift_output);
  input [2:0] ALU_control;
  input [15:0] Ainput;
  input [15:0] Binput;
  input Clock;
  output[15:0] Shift_output;
  reg [15:0] Shift_output;
  reg [15:0] ALU_output;
always @(ALU_control or Ainput or Binput)
	case (ALU_control[2:1])
		0: ALU_output = Ainput + Binput;
		1: ALU_output = Ainput - Binput;
		2: ALU_output = Ainput & Binput;
		3: ALU_output = Ainput | Binput;
        	default: ALU_output = 0;
	endcase
always @(posedge Clock)
	if (ALU_control[0]==1)
		Shift_output = ALU_output << 1;
	else
		Shift_output = ALU_output;
endmodule

