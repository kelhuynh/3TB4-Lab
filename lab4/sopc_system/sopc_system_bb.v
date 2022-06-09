
module sopc_system (
	clk_clk,
	reset_n_reset_n,
	sdram_addr_export,
	sdram_ba_export,
	sdram_cas_n_export,
	sdram_cke_export,
	sdram_cs_n_export,
	sdram_dq_export,
	sdram_ldqm_export,
	sdram_ras_n_export,
	sdram_udqm_export,
	sdram_we_n_export,
	sdram_clk_clk);	

	input		clk_clk;
	input		reset_n_reset_n;
	output	[12:0]	sdram_addr_export;
	output	[1:0]	sdram_ba_export;
	output		sdram_cas_n_export;
	output		sdram_cke_export;
	output		sdram_cs_n_export;
	inout	[15:0]	sdram_dq_export;
	output		sdram_ldqm_export;
	output		sdram_ras_n_export;
	output		sdram_udqm_export;
	output		sdram_we_n_export;
	output		sdram_clk_clk;
endmodule
