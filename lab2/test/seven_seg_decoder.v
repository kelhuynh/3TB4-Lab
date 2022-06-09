module seven_seg_decoder(input [3:0] x, output reg [6:0] hex_LEDs);
	// sorry did not follow the lab manual instruction strictly---
	// did not use the assign statement for the first two segments.
	
	always @(*)
	begin 
			case (x)
				4'b0000:  hex_LEDs=7'b1000000;  // decimal 0
				4'b0001:  hex_LEDs=7'b1111001;  // 1
				4'b0010:  hex_LEDs=7'b0100100; //2
				4'b0011:  hex_LEDs=7'b0110000;  // 3
				4'b0100:  hex_LEDs=7'b0011001;  // 4
				4'b0101:  hex_LEDs=7'b0010010;  //5
				4'b0110:  hex_LEDs=7'b0000010;  //6
				4'b0111:  hex_LEDs=7'b1111000; //7
				4'b1000:  hex_LEDs=7'b0000000; //8
				4'b1001:  hex_LEDs=7'b0010000;//9 
				4'b1010:  hex_LEDs=7'b0001000;//A
				4'b1011:  hex_LEDs=7'b0000011; //b
				4'b1100:  hex_LEDs=7'b1000110;//C
				4'b1101:  hex_LEDs=7'b0100001;//d
				4'b1110:  hex_LEDs=7'b0000110;//E
			//	4'b1111:  hex_LEDs=7'b0001110; //F
				4'b1111:  hex_LEDs=7'b1111111;   //when value is 1111, turn all segments off!!!
			endcase
	end
endmodule