module mux_4to1(input [1:0]s, input [3:0] a,b,c,d, output reg[3:0] out);

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