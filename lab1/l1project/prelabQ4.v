module d_ff (input d, input clk, output reg q);
	always @(posedge clk)
	begin
		q <= d;
	end
endmodule

module d_ff_lowsync_rst(input d, input clk, input reset, output reg q);
	always @(posedge clk)
	begin
	if (!reset)
		q <= 0;
	else
		q <= d;
	end
endmodule 

module d_ff_lowsync_rst_enable(input d, input clk, input CE, input reset, output reg q);
	always @(posedge clk)
	begin
	if (!reset)
		q <= 0;
	else if (CE)
		q = d;
	else
		q <= d;
	end
endmodule 

module d_latch_enable(input d, input EN, output reg q);
	always @(en or d)
	begin
		if (en)
		begin
			q <= d;
		end
	end
endmodule

module mux_4to1(input a,b,c,d, input[1:0] s, output reg out);
	always @(*)
	begin
		case(s)
			2'b00 : out <= a;
			2'b01 : out <= b;
			2'b10 : out <= c;
			2'b11 : out <= d;
		endcase
	end
endmodule 

module counter (input clk, input reset, output reg[3:0] out);
	always @(posedge clk) 
	begin
	if (!reset)
		out <= 0;
	else
		out <= out+1;
	end
endmodule 