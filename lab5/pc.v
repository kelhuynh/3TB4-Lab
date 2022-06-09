module pc (input clk, reset_n, branch, increment, input [7:0] newpc,
			output reg [7:0] pc);
	parameter RESET_LOCATION = 8'h00;
	
	always @(posedge clk) begin
		
		if (!reset_n) pc <= RESET_LOCATION;
		else if (increment) pc = pc + 8'b00000001;
		else if (branch) pc <= newpc;

	end
			
endmodule
