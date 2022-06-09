module lab2 (input CLOCK_50, input [3:0] KEY, output [6:0] HEX0, HEX1, HEX2,
HEX3, HEX4, HEX5, output [9:0] LEDR);

	parameter reset_btn=1, p1=0, resume=2, p2=3;		//keys
	parameter [2:0] RESET= 3'b000, START= 3'b001, WAIT_FOR_RAND= 3'b010, WAIT_MS= 3'b011, COUNTING=3'b100, CHEATING= 1'b110;
							
	reg [2:0] PS = RESET; 			//states
	reg [2:0] NS = RESET;
	
	reg [4:0] LED1 = 5'b0;				//scores
	reg [4:0] LED2 = 5'b0;			
	
	reg [1:0] winner = 2'b0;
	
	reg [1:0] MUL_sel;					//mul selector
	wire [1:0] w_MUL_sel;
	assign w_MUL_sel = MUL_sel;
	
	reg counter_en;									//counter enable
	wire w_counter_en;
	assign w_counter_en = counter_en;
	
	
	wire clock_1_khz;
	wire [19:0] counter_hex;
	wire rnd_ready;
	wire [13:0] rand_num;
	
	
	wire [23:0] bcd_out;
	wire [23:0] off = 24'b111111111111111111111111;
	wire [23:0] blinking = 24'b0;
 	
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
	
	
	clock_divider 		  cl1(.clock(CLOCK_50), 
									.reset(KEY[reset_btn]), 
									.clk_ms(clock_1_khz));
									
	counter 				  co1(.clock(clock_1_khz),
									.reset(KEY[reset_btn]),
									.resume(KEY[resume]),
									.enable(w_counter_en),
									.ms_count(counter_hex));
									
	random 					r1(.clk(CLOCK_50),
									.reset_n(KEY[reset_btn]),
									.resume_n(KEY[resume]),
									.random(rand_num),
									.rnd_ready(rnd_ready));
									
	hex_to_bcd_converter	h1(.clock(clock_1_khz),
									.hex_number(counter_hex-3000-rand_num),
									.bcd_digit_0(bcd_out[3:0]),
									.bcd_digit_1(bcd_out[7:4]),
									.bcd_digit_2(bcd_out[11:8]),
									.bcd_digit_3(bcd_out[15:12]),
									.bcd_digit_4(bcd_out[19:16]),
									.bcd_digit_5(bcd_out[23:20]));
									
	MUL 						m1(.sel(w_MUL_sel), 
									.a(bcd_out), 
									.b(off), 
									.c(blinking), 				//flashing
									.d(off),
									.q(MUL_out));
									
									
	seven_seg_decoder 	s0(.x(MUL_out[3:0]), .hex_LEDs(d0));
	seven_seg_decoder 	s1(.x(MUL_out[7:4]), .hex_LEDs(d1));
	seven_seg_decoder 	s2(.x(MUL_out[11:8]), .hex_LEDs(d2));
	seven_seg_decoder 	s3(.x(MUL_out[15:12]), .hex_LEDs(d3));
	seven_seg_decoder 	s4(.x(MUL_out[19:16]), .hex_LEDs(d4));
	seven_seg_decoder 	s5(.x(MUL_out[23:20]), .hex_LEDs(d5));
	
		
	always @(posedge CLOCK_50, negedge KEY[reset_btn], negedge KEY[resume], negedge KEY[p1], negedge KEY[p2])begin
		
		if(!KEY[reset_btn]) begin
			PS <= RESET;
			counter_en <= 1'b1;
			LED1 <= 5'b0;	
			LED2 <= 5'b0;							//LEDRs
		end else if (!KEY[resume]) begin
			PS <= START;
			counter_en <= 1'b1;
		end else if (!KEY[p1])begin
			counter_en <= 1'b0;
			LED1 <= (LED1<<1) | 5'b1;
		end else if (!KEY[p2]) begin 
			counter_en <= 1'b0;
			LED1 <= (LED2<<1) | 5'b1;
		end else begin
			PS <= NS;
		//LEDR <= PS;
		end
	end
	
	
	always @(*)begin
	
		case(PS)
		
			RESET: begin
				
				NS <= WAIT_FOR_RAND;
			end
			
			START: begin
				NS <= WAIT_FOR_RAND;
			end
			
			WAIT_FOR_RAND: begin
				MUL_sel <= 2'b10;							// 10 sel for blinking
				if(counter_hex >= 3000) begin				
				 	NS <= WAIT_MS;
				end else begin
					NS <= WAIT_FOR_RAND;
				end
			end			
	
			WAIT_MS: begin
				MUL_sel <= 2'b01;						//all hex off
				if(counter_hex < rand_num + 3000) begin
					NS <= WAIT_MS;
				end else begin
					NS <= COUNTING;
				end
			end
			
			COUNTING: begin
				MUL_sel <= 2'b00;				//counter to display
				NS <= COUNTING;
				
			end
			
			
			CHEATING: begin
			end
		
			default: begin
				NS <= RESET;
			end
			
		
		endcase
	
	end
							
endmodule