module lab2 (input CLOCK_50, input [3:0] KEY, output [6:0] HEX0, HEX1, HEX2,
HEX3, HEX4, HEX5, output [9:0] LEDR);

	parameter reset_btn=1, p1=0, resume=2, p2=3;		//keys
	parameter [2:0] RESET= 3'b000, START= 3'b001, WAIT_RNG= 3'b010, WAIT_MS= 3'b011, COUNTING=3'b100, CHEATING= 1'b110;
							
	reg [2:0] curr_state = RESET; 			//states
	reg [2:0] next_state = RESET;
	
	reg [4:0] LED1 = 5'b0;				//scores
	reg [4:0] LED2 = 5'b0;			
	
	reg p1cheat, p2cheat;
	reg [1:0] winner = 2'b0;
	
	reg [1:0] select;					//mul selector
	wire [1:0] w_select;
	assign w_select = select;
	
	reg enable;									//counter enable
	wire w_enable;
	assign w_enable = enable;
	
	
	wire clock_1_khz;
	wire [19:0] counter_hex;
	wire rng_rdy;
	wire [13:0] rand_num;
	
	
	wire [23:0] b_out;
	wire [23:0] off = 24'b111111111111111111111111;
	wire [23:0] blinking = 24'b0;
	wire [23:0] cheat = 24'b111111111111111111111111;
 	
	wire [23:0] MUL_out;
	
	//display outputs
	wire [6:0] d0;
	wire [6:0] d1;
	wire [6:0] d2;
	wire [6:0] d3;
	wire [6:0] d4;
	wire [6:0] d5;
	
	//assign displays
	assign HEX0 = d0;
	assign HEX1 = d1;
	assign HEX2 = d2;
	assign HEX3 = d3;
	assign HEX4 = d4;
	assign HEX5 = d5;
	
	assign LEDR[4:0]=LED1;
	assign LEDR[9:5]={LED2[0],LED2[1],LED2[2],LED2[3],LED2[4]} ;
	
	
	clock_divider 		  cl1(.clk(CLOCK_50), 
									.reset_n(KEY[reset_btn]), 
									.clk_ms(clock_1_khz));
									
	counter 				  co1(.clk(clock_1_khz),
									.reset_n(KEY[reset_btn]),
									.resume_n(KEY[resume]),
									.stop_n(w_enable),
									.ms_count(counter_hex));
									
	rng 						r1(.clk(CLOCK_50),
									.reset(KEY[reset_btn]),
									.resume(KEY[resume]),
									.random(rand_num),
									.rng_rdy(rng_rdy));
									
	hex_to_bcd_converter	h1(.clk(clock_1_khz),
									.hex_number(counter_hex-3000-rand_num),
									.bcd_digit_0(b_out[3:0]),
									.bcd_digit_1(b_out[7:4]),
									.bcd_digit_2(b_out[11:8]),
									.bcd_digit_3(b_out[15:12]),
									.bcd_digit_4(b_out[19:16]),
									.bcd_digit_5(b_out[23:20]));
									
	mux_4to1 					 m1(.s(w_select), 
									.a(b_out), 
									.b(off), 
									.c(blinking), 				//flashing
									.d(cheat),
									.out(MUL_out));
									
									
	seven_segment 	s0(.x(MUL_out[3:0]), .hex_LEDs(d0));
	seven_segment 	s1(.x(MUL_out[7:4]), .hex_LEDs(d1));
	seven_segment 	s2(.x(MUL_out[11:8]), .hex_LEDs(d2));
	seven_segment 	s3(.x(MUL_out[15:12]), .hex_LEDs(d3));
	seven_segment 	s4(.x(MUL_out[19:16]), .hex_LEDs(d4));
	seven_segment 	s5(.x(MUL_out[23:20]), .hex_LEDs(d5));
	
		
	always @(posedge CLOCK_50, negedge KEY[reset_btn], negedge KEY[resume], negedge KEY[p1], negedge KEY[p2])begin
		
		if(!KEY[reset_btn]) begin
			curr_state <= RESET;
			enable <= 1'b1;
			LED1 <= 5'b0;	
			LED2 <= 5'b0;							//LEDRs
		end else if (!KEY[resume]) begin
			curr_state <= START;
			enable <= 1'b1;
		end else if (!KEY[p1])begin
			enable <= 1'b0;
			LED1 <= (LED1<<1) | 5'b1;
		end else if (!KEY[p2]) begin 
			enable <= 1'b0;
			LED1 <= (LED2<<1) | 5'b1;
		end else begin
			curr_state <= next_state;
		//LEDR <= curr_state;
		end
	end
	
	
	always @(*)begin
	
		case(curr_state)
		
			RESET: begin
				
				next_state <= WAIT_RNG;
			end
			
			START: begin
				next_state <= WAIT_RNG;
			end
			
			WAIT_RNG: begin
				select <= 2'b10;							// 10 sel for blinking
				if(!KEY[p1]) begin
					p1cheat = 1'b1;
					next_state <= CHEATING;
				end else if (!KEY[p2]) begin
					p2cheat = 1'b1;
					next_state <= CHEATING;
				else begin
					p1cheat = 1'b0;
					P2cheat = 1'b0;
					next_state <= WAIT_MS;
				end
				if(counter_hex >= 3000) begin				
				 	next_state <= WAIT_MS;
				end else begin
					next_state <= WAIT_RNG;
				end
			end			
	
			WAIT_MS: begin
				select <= 2'b01;						//all hex off
				if(counter_hex < rand_num + 3000) begin
					next_state <= WAIT_MS;
				end else begin
					next_state <= COUNTING;
				end
			end
			
			COUNTING: begin
				select <= 2'b00;				//counter to display
				next_state <= COUNTING;
			end
			
			
			CHEATING: begin
				select <= 2'b11;
				if(p1cheat) begin
					cheat = 24'b000100010001000100010001;
				end else if (p2cheat) begin
					cheat = 24'b001000100010001000100010;
				end
			end
		
			default: begin
				next_state <= RESET;
			end
			
		
		endcase
	
	end
							
endmodule