module seven_segment(input [3:0] x, output [6:0] hex_LEDs);
	reg [6:0] reg_LEDs;
	
	/* Assumption for segment 0 and 1, is that x[3] = A, x[2] = B, x[1] = C, x[0] = D relative to inputs on truth table*/
	assign hex_LEDs[0]= (x[3]&x[2]) | (x[2]&(~x[1])&(~x[0])) | (x[3]&x[1]&(~x[0])) | ((~x[3])&(~x[2])&(~x[1])&x[0]) /* expression for segment 0 */;
	assign hex_LEDs[1]= (x[3]&x[1]&x[0]) | ((~x[3])&x[2]&(~x[1])&x[0]) | ((~x[3])&x[2]&x[1]&(~x[0])) | (x[3]&x[2]&(~x[1])&(~x[0])) /* expression for segment 1 */;
	assign hex_LEDs[6:2]=reg_LEDs[6:2];
	always @(*)
	begin
		case (x)
			4'b0000: reg_LEDs[6:2]=5'b10000; //7'b1000000 decimal 0
			4'b0001: reg_LEDs[6:2]=5'b11110; //7'b1111001 decimal 1
			4'b0010: reg_LEDs[6:2]=5'b01001; //7'b0100100 decimal 2
			4'b0011: reg_LEDs[6:2]=5'b01100; //3 - 0110000
			4'b0100: reg_LEDs[6:2]=5'b00110; //4 - 0011001
			4'b0101: reg_LEDs[6:2]=5'b00100; //5 - 0010010
			4'b0110: reg_LEDs[6:2]=5'b00000; //6 - 0000010
			4'b0111: reg_LEDs[6:2]=5'b11110; //7 - 1111000
			4'b1000: reg_LEDs[6:2]=5'b00000; //8 - 0000000
			4'b1001: reg_LEDs[6:2]=5'b00100; //9 - 0010000
			4'b1010: reg_LEDs[6:2]=5'b00010; //K - 0001001
			4'b1011: reg_LEDs[6:2]=5'b00001; //E - 0000110
			4'b1100: reg_LEDs[6:2]=5'b10001; //L - 1000111
			4'b1101: reg_LEDs[6:2]=5'b10000; //V - 1000001
			4'b1110: reg_LEDs[6:2]=5'b11110; //I - 1111001
			4'b1111: reg_LEDs[6:2]=5'b11111; //All OFF
			/* finish the case block */
		endcase
	end
endmodule 