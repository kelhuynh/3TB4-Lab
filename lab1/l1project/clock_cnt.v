module clock_counter(input clk, reset,  output reg[WIDTH-1:0] result);

	parameter WIDTH=30;
	//2's power of 26 is 67,108,864.
	// that is 1 second (22̂6/50e6 = 1.34), if count is using CLOCK_50

	always@(posedge clk, negedge reset)
	
	if(!reset)begin
		result<=30'b0;
		
	end else begin
		result<=result+1'b1;
		
	end
endmodule