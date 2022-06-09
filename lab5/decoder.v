module decoder (input [7:2] instruction,
				output br, brz, addi, subi, sr0, srh0, clr, mov, mova, movr, movrhs, pause
);

	assign br = (instruction[7:5] == 3'b100);
	assign clr = (instruction[7:2] == 6'b011000);

	assign brz = (instruction[7:5] == 3'b101);
	assign addi = (instruction[7:5] == 3'b000);
	assign subi = (instruction[7:5] == 3'b001);
	assign sr0 = (instruction[7:4] == 4'b0100);
	assign srh0 = (instruction[7:4] == 4'b0101);
	assign mov = (instruction[7:4] == 4'b0111);
	assign mova = (instruction[7:2] == 6'b110000);
	assign movr = (instruction[7:2] == 6'b110001);
	assign movrhs = (instruction[7:2] == 6'b110010);
	assign pause = (instruction[7:2] == 6'b0);

endmodule
