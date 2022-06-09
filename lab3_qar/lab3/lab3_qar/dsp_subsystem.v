module dsp_subsystem (input sample_clock,  input reset, input [1:0] selector, input [15:0] input_sample, output reg [15:0] output_sample);

	wire [15:0] filter_out;
	wire [15:0] echo_out;
	wire [15:0] output_sample_w;
	
	assign output_sample_w = output_sample;
	
	
	fir_filter (
		.clk(sample_clock),
		.input_sample(input_sample),
		.taps(8'd65),
		.output_sample(filter_out)
	);

		
	shiftregister (
		.clock(sample_clock),
		.shiftin(output_sample_w),
		.shiftout(echo_out),
		.taps()
	);
	

	always@(*)begin
	
		case(selector) 
			2'b00:
				output_sample = input_sample;
			
			2'b01:
				output_sample = filter_out;
			
			2'b10: begin
				//if(echo_out[15] == 1'b1)begin
					//output_sample = input_sample + (echo_out >> 2)|(15'b11 << 15);
				//end else begin
					output_sample = input_sample + (echo_out >> 2);
				//end
			end
			
			default:
				output_sample = input_sample;
			
		endcase
	
	
	end

endmodule
