module lab2tut (input CLOCK_50, input [2:0] KEY, output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	wire clk_en; // Clock divider output
	wire [19:0] ms; // Counter output
	wire [3:0] b0, b1, b2, b3, b4, b5; // BCD_digits
	wire [6:0] d0, d1, d2, d3, d4, d5; // hex display
	
	assign HEX0 = d0;
	assign HEX1 = d1;
	assign HEX2 = d2;
	assign HEX3 = d3;
	assign HEX4 = d4;
	assign HEX5 = d5;
	
	clock_divider clk1(.Clk(CLOCK_50), 
							 .Reset_n(KEY[0]), 
							 .clk_ms(clk_en));
	
	counter cnt1(.clk(clk_en), 
					 .reset_n(KEY[0]), 
					 .start_n(KEY[1]), 
					 .stop_n(KEY[2]), 
					 .ms_count(ms));
	
	hex_to_bcd_converter htb1(.clk(CLOCK_50),
									  .hex_number(counter_hex),
									  .bcd_digit_0(b0),
									  .bcd_digit_1(b1),
									  .bcd_digit_2(b2),
									  .bcd_digit_3(b3),
									  .bcd_digit_4(b4),
									  .bcd_digit_5(b5));
	
	seven_segment seg0(.x(b0), .hex_LEDs(d0));
	seven_segment seg1(.x(b1), .hex_LEDs(d1));
	seven_segment seg2(.x(b2), .hex_LEDs(d2));
	seven_segment seg3(.x(b3), .hex_LEDs(d3));
	seven_segment seg4(.x(b4), .hex_LEDs(d4));
	seven_segment seg5(.x(b5), .hex_LEDs(d5));
	
endmodule