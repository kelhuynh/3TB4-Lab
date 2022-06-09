module delay_counter (input clk, reset_n, start, enable, input [7:0] delay, output reg done);
	parameter BASIC_PERIOD=20'd500000;   // can change this value to make delay longer

	reg [7:0] downcount;
	reg [19:0] timer;

	always @(posedge clk) begin
		
		if(!reset_n) begin
			timer <= 20'b0;
			downcount <= 8'b00000001;
			done <= 8'b0;
		end
		
		else if (start == 1'b1) begin
			timer <= 20'd0;
			downcount <= delay;
			done <= 0;
		end
		
		else if (enable == 1'b1) begin
			if (timer < BASIC_PERIOD) timer <= timer+20'd1;
			
			else begin
				downcount <= downcount-8'b1;
				if (downcount == 0) done <= 1'b1;
				timer <= 20'd0;
			end
		end
		
	end
	
endmodule
