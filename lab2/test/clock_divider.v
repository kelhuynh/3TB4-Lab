module clock_divider (input Clock, Reset_n, output reg Pulse_ms);
	
	parameter factor=10; //50000;	// 32'h000061a7;
	
	reg [31:0] countQ;
	
	
	always @ (posedge Clock, negedge Reset_n)
	begin
		if (!Reset_n) begin
				countQ<=0;
				Pulse_ms<=0;
			end 
		else
			begin 
				if (countQ<factor/2) 
					begin
						countQ<=countQ+1;
						Pulse_ms<=0;
					end
				else if (countQ<factor) 
					begin
						countQ<=countQ+1;
						Pulse_ms<=1;
					end
				else	//countQ==factor					
					begin 
						countQ<=0;
						Pulse_ms<=0;
					end	
					
			end 

	
	
	end
	
	
	
	
	
	
	
	
endmodule