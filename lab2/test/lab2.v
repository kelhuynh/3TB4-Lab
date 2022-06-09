
//The function of this starterkit:
//1. After compile and download the starter kit to DE1-SoC board, the HEX LEDs will blink.
//2. After 6 seconds, the LDER9 is on, indicating the player 2 wins one time.
//3. Each tinm the KEY2 is pressed, the player 2 will win one more time after 6 secconds.
//4. Press KEY1 will reset the project.




//The requirements for your project:

// 1.   	Key1 for reset, Key2 for resume, Key0 is player 1, Key3 is for player 2
// 2.   	If Key0 is pressed earlier than Key3, player 1 wins. If Key3 is pressed earlier, player2 wins.
// 3. 	If Key0 and Key3 pressed at the same time, no one wins. 
// 4. 	If player1 wins, one more LEDs of the LED0-4 will light up.If player2 wins, one more LEDs of the LED=9-5 will light up,  
// 5. 	After power up, or after reset, all of LEDs are off. the HEXs will blink for 5 seconds. then will be off for  2+randdom seconds.
			//Here the random ranges form 1 sec to 5 sec
// 6. 	The winner's reaction time will show by the HEXs.
//	7. 	If there is a cheating (press the KEY0 or KEY3 before the timer starts,(in program, (set that if the timer reading is less than 
			//80 ms, it is cheating)
			//the cheater's number, either 111111 or 222222 will show by HEXs. The program then stop for resumeing for next round.
//	8. 	if both player is cheating at the same time (or both player pressed at the same time, which is not likely to happen), display 888888 by HEXs and then wait to resume the game.


module lab2(input CLOCK_50,  input [3:0] KEY,  output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5, output [9:0] LEDR);
		

	parameter [2:0] RESET=3'b000, RESUME=3'b001, BLINKING=3'b010, OFF=3'b011, TIMER_DISPLAY=3'b100, WINNER_TIME_DISPLAY=3'b101,
						 CHEAT=3'b110;
	parameter KEYDOWN = 1'b0, KEYUP = 1'b1;
	parameter FALSE = 1'b0, TRUE = 1'b1;
	
	reg [2:0] state=RESET, next_state=RESET;
	
	
	wire clk_ms;
	wire [19:0] ms, display_ms, rand_ms;
	wire [3:0] w_ms0,w_ms1,w_ms2,w_ms3, w_ms4,w_ms5; //wires after hex_to_bcd_converter.v for displayed time
	wire [3:0] w_blink0, w_blink1, w_blink2, w_blink3, w_blink4, w_blink5;  //wires afer  blinking 
	wire [3:0] winner_ms0,winner_ms1,winner_ms2,winner_ms3, winner_ms4,winner_ms5; //wires afer hex_to_bcd_converter.v for winner time

	
	wire [3:0] digit0, digit1, digit2, digit3, digit4, digit5;  //wires afer mux.v
	wire [3:0] bcd0, bcd1, bcd2, bcd3, bcd4, bcd5;
	wire [3:0] bcd_rng0, bcd_rng1, bcd_rng2, bcd_rng3, bcd_rng4, bcd_rng5;
	
	
	wire [13:0] random_wait_time;

	
	reg [1:0]  hex_sel=2'b00;  //whether blinking or not
	wire [1:0] w_hex_sel; 
	
	
	reg display_counter_start;
	wire w_display_counter_start;
	
	
	reg player1_win, player2_win;   // if is 0, not win, if 1 win,
	reg p1state, p2state;
	reg p1cheat, p2cheat;
	
	reg[4:0] win1=5'b00000, win2=5'b00000;   // score for player 1 and 2.

	reg [19:0]temp;

	reg [19:0] winner_time=8888;
	wire [19:0] w_winner_time;
	
	wire conditioned_key0, conditioned_key3;

	assign w_winner_time=winner_time;
	
	
	assign w_hex_sel=hex_sel;
	
	assign w_display_counter_start=display_counter_start; 
	
	assign LEDR[4:0]=win1;
	assign LEDR[9:5]={win2[0],win2[1],win2[2],win2[3],win2[4]};
	
	wire rand_rdy;
	
	reg [3:0] set_all_hex;

	clock_divider #(.factor(50000)) (.Clock(CLOCK_50), .Reset_n(KEY[1]), .Pulse_ms(clk_ms));
	
	counter (.clk(clk_ms), .reset_n(KEY[1]), .resume_n(KEY[2]), .enable(1), .ms_count(ms));

	counter (.clk(clk_ms), .reset_n(KEY[1]), .resume_n(KEY[2]), .enable(w_display_counter_start), .ms_count(display_ms));
	
	random (.clk(clk_ms), .reset_n(KEY[1]), .resume_n(KEY[2]), .random(random_wait_time), .rand_rdy(rand_rdy));

	
	blinkHEX #(.factor(200) ) (.ms_clk(clk_ms), .Reset_n(KEY[1]), .d0(w_blink0), .d1(w_blink1), .d2(w_blink2), .d3(w_blink3), .d4(w_blink4),.d5(w_blink5));
	
	hex_to_bcd_converter (.clk(CLOCK_50), .hex_number(display_ms), .bcd_digit_0(bcd0), .bcd_digit_1(bcd1), .bcd_digit_2(bcd2), .bcd_digit_3(bcd3), .bcd_digit_4(bcd4), .bcd_digit_5(bcd5));

	hex_to_bcd_converter (.clk(CLOCK_50), .hex_number(display_ms), .bcd_digit_0(bcd_rng0), .bcd_digit_1(bcd_rng1), .bcd_digit_2(bcd_rng2), .bcd_digit_3(bcd_rng3), .bcd_digit_4(bcd_rng4), .bcd_digit_5(bcd_rng5));
	
	mux_4to1 (.s(w_hex_sel), .a(w_blink0), .b(set_all_hex), .c(bcd0), .d(bcd_rng0), .out(digit0));
	mux_4to1 (.s(w_hex_sel), .a(w_blink1), .b(set_all_hex), .c(bcd1), .d(bcd_rng1), .out(digit1));
	mux_4to1 (.s(w_hex_sel), .a(w_blink2), .b(set_all_hex), .c(bcd2), .d(bcd_rng2), .out(digit2));
	mux_4to1 (.s(w_hex_sel), .a(w_blink3), .b(set_all_hex), .c(bcd3), .d(bcd_rng3), .out(digit3));
	mux_4to1 (.s(w_hex_sel), .a(w_blink4), .b(set_all_hex), .c(bcd4), .d(bcd_rng4), .out(digit4));
	mux_4to1 (.s(w_hex_sel), .a(w_blink5), .b(set_all_hex), .c(bcd5), .d(bcd_rng5), .out(digit5));
	
	
	seven_seg_decoder  decoder0(digit0, HEX0);
	seven_seg_decoder  decoder1(digit1, HEX1);
	seven_seg_decoder  decoder2(digit2, HEX2);
	seven_seg_decoder  decoder3(digit3, HEX3);
	seven_seg_decoder  decoder4(digit4, HEX4);
	seven_seg_decoder  decoder5(digit5, HEX5);

	
	always @ (posedge CLOCK_50, negedge KEY[1], negedge KEY[2])
	begin
		if (!KEY[1])    // reset
			begin
				state<=RESET;
			end
		else if (!KEY[2])   //start/resume
			begin
				state<=RESUME;
			end
	
		else
			begin
				state<=next_state;
			end
	end
	
	always @ (posedge CLOCK_50)
	begin
		p1state = KEY[0];
		p2state = KEY[3];
	end

	  
	always @(posedge CLOCK_50, negedge KEY[1] )    //for solving the inferred latch problem caused by win1 and win2.
	begin 
		if (!KEY[1]) begin
			win1<=5'b00000;
			win2<=5'b00000;
		end			
		else if (player1_win==1)
				win1<=(win1<<1) | 5'b00001;
		else if (player2_win==1)
				win2<=(win2<<1) | 5'b00001;
		
	
	end
	
		
	
	
	always @ (*) 
	begin
		next_state=state;   //default
		player1_win=0;
		player2_win=0;
		display_counter_start = 0;
		
		case (state)
			RESET: 
				begin					
					display_counter_start=0;
					winner_time=0;					
									
					hex_sel=2'b00;
					next_state=BLINKING;			
				end
				
			RESUME:
				begin					
					hex_sel=2'b00;
					display_counter_start=0;
					winner_time=0;
					hex_sel=2'b00;
					next_state=BLINKING;
				end
				
			BLINKING:
				begin
					hex_sel=2'b00;
					
	
					if (ms>=5000)        //blink for  about 5 second	
						begin
							hex_sel=2'b01;
							next_state=OFF;
						end
					else 
						next_state=BLINKING;
						
				end
			
			OFF:
				begin
					set_all_hex = 4'b1111;
					hex_sel=2'b01;
					
									
					if (ms>(7000+random_wait_time)) begin     //(7-5) seconds + random seconds)
						display_counter_start = 0;
						next_state=TIMER_DISPLAY;	
					end
					
					if (p1state == KEYDOWN)
					begin
						p1cheat = TRUE;
					end
					else 
					begin 
						p1cheat = FALSE;
					end
					if (p2state == KEYDOWN)
					begin
						p2cheat = TRUE;
					end
					else 
					begin 
						p2cheat = FALSE;
					end
				end
				
			TIMER_DISPLAY:
				begin
					set_all_hex = 4'b0000;
					display_counter_start=1;  
					hex_sel=2'b10;	
					
					if ((p1cheat == TRUE && p2cheat == TRUE) || (p1state == KEYDOWN && p2state == KEYDOWN)) // display all 8
					begin 
						set_all_hex = 4'b1000;
						next_state=CHEAT;
					end
					else if (p1cheat == TRUE) // display all 1
					begin 
						set_all_hex = 4'b0001;
						next_state=CHEAT;
					end
					else if (p2cheat == TRUE) // display all 2
					begin 
						set_all_hex = 4'b0010;
						next_state=CHEAT;
					end
				
					else if (p1state == KEYDOWN)
					begin
					   display_counter_start=0;
						player1_win=1;
						winner_time = display_ms;
						next_state=WINNER_TIME_DISPLAY;
					end
					else if (p2state == KEYDOWN)
					begin
					   display_counter_start=0;
						player2_win=1;
						winner_time = display_ms;
						next_state=WINNER_TIME_DISPLAY;
					end
				end


			WINNER_TIME_DISPLAY:
				begin
					hex_sel=2'b11;
					winner_time=winner_time;
					
				end
			
			CHEAT:
				begin
					hex_sel=2'b01;
				end
			
			default: 
				begin
					next_state=RESET;
				end
		endcase	
	
	
	end
	
	
	


	
	
	
		
	

endmodule
