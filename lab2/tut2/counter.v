module counter(input clk, input reset_n, start_n, stop_n, output reg [19:0] ms_count);

	reg state = 1'b0;

	always@(posedge clk, negedge reset_n) begin
		if (!reset_n)
			ms_count <= 1'b0;
		else if (!stop_n)
			state <= 1'b0;
		else if (!start_n)
			state <= 1'b1;
		else if (state)
			ms_count <= ms_count + 1'b1;
	end
endmodule 