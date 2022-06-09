module fir_filter (input clk, input [16:0] input_sample, input [7:0] taps, output [16:0] output_sample);
	// PAY ATTENTION: THE NEXT LINE IS COUNTERINTUITIVE, BUT CORRECT!
	wire [64:0] coeffs [64:0];
	reg [64:0] cascade [64:0];	//cascading input
	wire [64:0] res [64:0];
	
	assign output_sample =  res[ 0]+
									res[ 1]+
									res[ 3]+
									res[ 4]+
									res[ 5]+
									res[ 6]+
									res[ 7]+
									res[ 8]+
									res[ 9]+
									res[10]+
									res[11]+
									res[12]+
									res[13]+
									res[14]+
									res[15]+
									res[16]+
									res[17]+
									res[18]+
									res[19]+
									res[20]+
									res[21]+
									res[22]+
									res[23]+
									res[24]+
									res[25]+
									res[26]+
									res[27]+
									res[28]+
									res[29]+
									res[30]+
									res[31]+
									res[32]+
									res[33]+
									res[34]+
									res[35]+
									res[36]+
									res[37]+
									res[38]+
									res[39]+
									res[40]+
									res[41]+
									res[42]+
									res[43]+
									res[44]+
									res[45]+
									res[46]+
									res[47]+
									res[48]+
									res[49]+
									res[50]+
									res[51]+
									res[52]+
									res[53]+
									res[54]+
									res[55]+
									res[56]+
									res[57]+
									res[58]+
									res[59]+
									res[60]+
									res[61]+
									res[62]+
									res[63]+
									res[64];
									

	assign	coeffs[  0]=        -6;
	assign	coeffs[  1]=        -0;
	assign	coeffs[  2]=        18;
	assign	coeffs[  3]=         0;
	assign	coeffs[  4]=       -43;
	assign	coeffs[  5]=        -0;
	assign	coeffs[  6]=        87;
	assign	coeffs[  7]=         0;
	assign	coeffs[  8]=      -158;
	assign	coeffs[  9]=        -0;
	assign	coeffs[ 10]=       261;
	assign	coeffs[ 11]=         0;
	assign	coeffs[ 12]=      -403;
	assign	coeffs[ 13]=        -0;
	assign	coeffs[ 14]=       585;
	assign	coeffs[ 15]=         0;
	assign	coeffs[ 16]=      -807;
	assign	coeffs[ 17]=        -0;
	assign	coeffs[ 18]=      1061;
	assign	coeffs[ 19]=         0;
	assign	coeffs[ 20]=     -1338;
	assign	coeffs[ 21]=        -0;
	assign	coeffs[ 22]=      1620;
	assign	coeffs[ 23]=         0;
	assign	coeffs[ 24]=     -1890;
	assign	coeffs[ 25]=        -0;
	assign	coeffs[ 26]=      2127;
	assign	coeffs[ 27]=         0;
	assign	coeffs[ 28]=     -2313;
	assign	coeffs[ 29]=        -0;
	assign	coeffs[ 30]=      2431;
	assign	coeffs[ 31]=         0;
	assign	coeffs[ 32]=     30296;
	assign	coeffs[ 33]=         0;
	assign	coeffs[ 34]=      2431;
	assign	coeffs[ 35]=        -0;
	assign	coeffs[ 36]=     -2313;
	assign	coeffs[ 37]=         0;
	assign	coeffs[ 38]=      2127;
	assign	coeffs[ 39]=        -0;
	assign	coeffs[ 40]=     -1890;
	assign	coeffs[ 41]=         0;
	assign	coeffs[ 42]=      1620;
	assign	coeffs[ 43]=        -0;
	assign	coeffs[ 44]=     -1338;
	assign	coeffs[ 45]=         0;
	assign	coeffs[ 46]=      1061;
	assign	coeffs[ 47]=        -0;
	assign	coeffs[ 48]=      -807;
	assign	coeffs[ 49]=         0;
	assign	coeffs[ 50]=       585;
	assign	coeffs[ 51]=        -0;
	assign	coeffs[ 52]=      -403;
	assign	coeffs[ 53]=         0;
	assign	coeffs[ 54]=       261;
	assign	coeffs[ 55]=        -0;
	assign	coeffs[ 56]=      -158;
	assign	coeffs[ 57]=         0;
	assign	coeffs[ 58]=        87;
	assign	coeffs[ 59]=        -0;
	assign	coeffs[ 60]=       -43;
	assign	coeffs[ 61]=         0;
	assign	coeffs[ 62]=        18;
	assign	coeffs[ 63]=        -0;
	assign	coeffs[ 64]=        -6;


	genvar i;
	generate
		for(i=0;i<65;i=i+1) begin: multiply
			multiplier (cascade[i],coeffs[i],res[i]);
		end
	endgenerate

	integer j;
	always @(posedge clk)
	begin
		cascade[0] <= input_sample;
		
		for(j=0;j<63;j=j+1)begin
			cascade[j+1]<=cascade[j];
		end

	end
endmodule