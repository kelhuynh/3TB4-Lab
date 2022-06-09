module random (input clk, reset_n, resume_n, output reg [11:0] random, output reg rand_rdy);
	//for 14 bits Liner Feedback Shift Register,
	//the Taps that need to be XNORed are: 14, 5, 3, 1
	wire xnor_taps, and_allbits, feedback;
	
	reg [11:0] reg_values;
	reg enable=1;
	
	assign feedback = reg_values[0] ^ reg_values[2] ^ reg_values[4] ^ reg_values[11];
	
	initial
	begin
		reg_values=12'b111111111111;
		//the LFSR cannot be all 0 at beginning.
		enable=1;
		rand_rdy=0;
	end
	always @ (posedge clk, negedge reset_n, negedge resume_n)
	begin
		if (!reset_n)
		begin
			reg_values=12'b111111111111;
			//the LFSR cannot be all 0 at beginning.
			enable=1;
			rand_rdy=0;
		end
		else if (!resume_n)
		begin
			enable=1;
			rand_rdy=0;
			//reg_values=reg_values;
		end
		else
		begin
			if (enable)
			begin
				
				reg_values[11]=reg_values[0];
				reg_values[10:5]=reg_values[11:6];
				reg_values[4]=reg_values[0] ^ reg_values[5];
				// tap 5 of the diagram from the lab manual
				reg_values[3]=reg_values[4];
				reg_values[2]=reg_values[0] ^ reg_values[3];
				// tap 3 of the diagram from the lab manual
				reg_values[1]=reg_values[2];
				reg_values[0]=reg_values[0] ^ reg_values[1];
				//tap 1 of the diagram from the lab manual
				
				random = {reg_values[11:1], feedback} + 12'd2000; //can change 200 accordingly
				
			end //end of ENABLE.
		end
	end
endmodule