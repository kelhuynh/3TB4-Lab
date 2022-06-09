module tut4(CLOCK_50, SW, KEY, LEDR);
	input CLOCK_50;
	input [7:0] SW;
	input [0:0] KEY;
	output [7:0] LEDR;
	
	nios_system NiosII(
		.clk_clk(CLOCK_50),
		.reset_reset_n(KEY),
		.switches_export(SW),
		.leds_export(LEDR));

endmodule 