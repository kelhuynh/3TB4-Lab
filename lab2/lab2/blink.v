module blink (input clock, output reg [23:0] display);
	parameter factor=500;		//blink 2 times every second at 1khz freq

	reg [11:0] counter = 12'b0;
	initial display = 24'b0;
	
	always@(posedge clock)begin
	
		if(counter<factor)begin
			counter <= counter + 1'b1;
		end else begin // greater or equal
			counter <= 1'b0;
			display <= display ^ 24'b111111111111111111111111;
		end
	end
							
endmodule