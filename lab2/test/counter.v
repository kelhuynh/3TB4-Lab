module counter(input clk, input reset_n, resume_n, enable,  output reg [19:0] ms_count);
	//since DE1-SoC board has only 6 HEX, for six digits of decimal , 20 bits on binary is enough.
	//therefore declare ms_count as 20bits

	always @ (posedge clk, negedge reset_n, negedge resume_n)  
		
	begin 
			
			
			if (!reset_n ||  !resume_n) begin
			 	ms_count<=   20'h00000;
			end
			else begin 
				if (enable)
					ms_count<=ms_count+1;			
				
		   end
			
  end // End of Block COUNTER
  

  
endmodule

