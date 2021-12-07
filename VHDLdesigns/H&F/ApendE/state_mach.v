module state_mach (clk, reset, input1, input2 ,output1);
	input clk, reset, input1, input2;
	output output1;
	reg output1;
	reg [1:0] state;
	parameter [1:0] state_A = 0, state_B = 1, 
                    state_C = 2;
always@(posedge clk or posedge reset)
	begin
		if (reset)
			state = state_A;
		else
			case (state)
				state_A: if (input1==0)
						state = state_B;
					     else
						state = state_C;
				state_B: state = state_C;
				state_C: if (input2)
						state = state_A;
			endcase
	end
always @(state)
	begin
		case (state)
			state_A: output1 = 0;
			state_B: output1 = 0;
			state_C: output1 = 1;
			default: output1 = 0;
		endcase
	end
endmodule

