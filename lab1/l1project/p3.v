module lab1part3 (input [9:0] SW,
						input [3:0] KEY,
						input CLOCK_50,
						output [6:0] HEX0);
						
	
	
	wire [3:0]off = 4'b1111;				//hard code off
	wire [3:0]key_counter_val;				//output of button counter
	wire [29:0]clock_counter_val;			//output of clock counter
		
	wire [3:0]display_in;					//multiplexer output
	wire [6:0]display_out;					//display
	
	
	assign HEX0 = display_out;
	
	button_counter c1(	.key_press(KEY[3]),
								.reset(KEY[0]),
								.result(key_counter_val));
	
	clock_counter c2(		.clk(CLOCK_50),
								.reset(KEY[0]),
								.result(clock_counter_val));
	
	four_bit_MUL m1(		.sel(SW[9:8]), 
								.a(SW[3:0]), 
								.b(key_counter_val), 
								.c(clock_counter_val[29:26]), 		//4 most significant bits
								.d(off),
								.q(display_in));
	
	seven_seg_decoder d1(.x(display_in),
								.hex_LEDs(display_out));
		

endmodule