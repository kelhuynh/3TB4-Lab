module button_counter(input key_press, input reset, output reg[3:0] result);

	always@(negedge key_press, negedge reset) begin				//buttons activate on negedge
	
		if(!reset)begin
			result <= 4'b0;
		
		end else begin
			result <= result + 1'b1;
		end
		
	end
endmodule