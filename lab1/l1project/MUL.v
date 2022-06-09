module four_bit_MUL (sel, a, b, c, d, q);
	// ==============in out dec=============//
	input [1:0]sel;
	input [3:0]a;		// 4 bits for inputs and output
	input [3:0]b;
	input [3:0]c;
	input [3:0]d;
	
	output reg [3:0]q;
	
	always @ (sel) begin  
      case (sel)  
         2'b00 : q <= a;  
         2'b01 : q <= b;  
         2'b10 : q <= c;  
         2'b11 : q <= d;  
      endcase  
   end  
endmodule