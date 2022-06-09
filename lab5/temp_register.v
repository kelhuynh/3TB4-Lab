module temp_register (input clk, reset_n, load, increment, decrement, input [7:0] data,
					output reg negative, positive, zero);

	reg signed [7:0] counter /*synthesis keep*/;
					
	always @(posedge clk) begin
		
		if (!reset_n) counter <= 0;
		else if (load) counter <= data;
		else if (increment) counter <= counter + 8'b00000001;
		else if (decrement) counter <= counter - 8'b00000001;
		
		if (counter < 0) begin
			negative <= 1;
			positive <= 0;
			zero <= 0;
		end
		
		else if (counter == 0) begin
			zero <= 1;
			negative <= 0;
			positive <= 0;
		end
		
		else if (counter > 0) begin
			positive <= 1;
			negative <= 0;
			zero <= 0;
		end
	
	end

endmodule
