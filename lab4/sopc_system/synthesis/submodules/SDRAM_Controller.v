/*****************************************************************************
 *                                                                           *
 * Module:       SDRAM_Controller                                             *
 * Description:                                                              *
 *      This module is used for the sram controller for MT3TB4 Lab 4          *
 *                                                                           *
 *****************************************************************************/
`timescale 1ns / 1ps
 
module SDRAM_Controller (  //the ports sequence follows the sequence of wires in the diagram in the lab manual
		//signals through Avalon Interface:  
		input 			clock,
		input 			reset_n,     		
		input 			chipselect,
		input				write_n,
		input				read_n,
		input	 [1:0]	byteenable_n,
		input	 [24:0]	address,   //2's power of 25 is  33,554,432 that is 32M.  (16 bits word, that makes capable for 64MBytes)
		input	 [15:0]	write_data,
		output [15:0]	read_data,
		output 			wait_request,
		output			data_validation,
	
		//signals between Conroller and SDRAM:
			  
		inout	 [15:0]	DRAM_DQ,
		output [12:0]	DRAM_ADDR,
		output [1:0]	DRAM_BA,
	//	output		 	DRAM_CLK,
		output			DRAM_CKE,
		output 			DRAM_LDQM,   
		output			DRAM_UDQM,		
		output 			DRAM_WE_N,
		output			DRAM_CAS_N,
		output 			DRAM_RAS_N,
		output 			DRAM_CS_N
		
);




		wire	 			clock_wire/*synthesis keep*/;
		wire 				reset_n_wire/*synthesis keep*/;     		
		wire 				chipselect_wire/*synthesis keep*/;
		wire				write_n_wire/*synthesis keep*/;
		wire				read_n_wire/*synthesis keep*/;
		wire	[1:0]		byteenable_n_wire/*synthesis keep*/;
		wire	[24:0]	address_wire/*synthesis keep*/;   //2's power of 25 is  33,554,432 that is 32M.  (16 bits word, that makes capable for 64MBytes)
		wire	[15:0]	write_data_wire/*synthesis keep*/;	
		wire 				Wait_request_wire/*synthesis keep*/;
		wire				data_validation_wire/*synthesis keep*/;
				
				
		reg	[15:0]	read_data_reg/*synthesis preserve*/;
		//wire	[15:0]	read_data_wire/*synthesis keep*/;		
		
		//signals between Conroller and SDRAM:
			  
		wire	[15:0]	DRAM_DQ_wire/*synthesis keep*/;
		wire	[12:0]	DRAM_ADDR_wire/*synthesis keep*/;
		wire	[1:0]		DRAM_BA_wire/*synthesis keep*/;
		
		wire				DRAM_CKE_wire/*synthesis keep*/;
		
		wire	[1:0] 	DRAM_DQM_wire/*synthesis keep*/;   	//higher bit for UDQM , lower bit for LDQM
		wire 				DRAM_WE_N_wire/*synthesis keep*/;
		wire				DRAM_CAS_N_wire/*synthesis keep*/;
		wire 				DRAM_RAS_N_wire/*synthesis keep*/;
		wire 				DRAM_CS_N_wire/*synthesis keep*/;
		
		wire [15:0]		m_data_wire;
		wire				output_enable_wire;

		
		
		
		DE1_SoC_QSYS_sdram  my_sdram (
                            // inputs:
                             .az_addr(address_wire),
                             .az_be_n(byteenable_n_wire),
                             .az_cs(chipselect_wire),
                             .az_data(write_data_wire),
                             .az_rd_n(read_n_wire),
                             .az_wr_n(write_n_wire),
                             .clk(clock_wire),
                             .reset_n(reset_n_wire),

                            // outputs:
                            //.za_data(read_data_wire),    //can not get read_data from here.
                             .za_valid(data_validation_wire),
                             .za_waitrequest(Wait_request_wire),
                             .zs_addr(DRAM_ADDR_wire),
                             .zs_ba(DRAM_BA_wire),
                             .zs_cas_n(DRAM_CAS_N_wire),
                             .zs_cke(DRAM_CKE_wire),
                             .zs_cs_n(DRAM_CS_N_wire),
                             //.zs_dq(DRAM_DQ_wire),
                             .zs_dqm(DRAM_DQM_wire),
                             .zs_ras_n(DRAM_RAS_N_wire),
                             .zs_we_n(DRAM_WE_N_wire),
									  .output_enable(output_enable_wire),
									  .internal_m_data(m_data_wire)
                          );

	//=============Make connections =====================	
		
		assign 			DRAM_DQ=output_enable_wire?m_data_wire:{16{1'bz}} ;
 
		//this way works  , get data from za_data port does not works.
		always @(posedge clock or negedge reset_n)   //must be synchronize with the clock! 
		 begin
			if (reset_n == 0)
				read_data_reg<= 0;
			else 
				read_data_reg <= DRAM_DQ;
		 end	
		
		
		assign 			clock_wire=clock;
		assign 			reset_n_wire=reset_n;     		
		assign 			chipselect_wire=chipselect;
		assign			write_n_wire=write_n;
		assign			read_n_wire=read_n;
		assign			byteenable_n_wire=byteenable_n;
		assign			address_wire=address;   //2's power of 25 is  33,554,432 that is 32M.  (16 bits word, that makes capable for 64MBytes)
		assign			write_data_wire=write_data;
		
		
		
		
		//output signals
	
		assign 			read_data=read_data_reg;
		//assign 			read_data=read_data_wire;   //can not get read_data from the za_data port
		
		
		assign 			wait_request=Wait_request_wire;
		assign			data_validation=data_validation_wire;
	
		
		
		
		
		
		//signals between Conroller and SDRAM:
		

		assign 			DRAM_UDQM=DRAM_DQM_wire[1];   	//higher bit for UDQM , lower bit for LDQM
		assign			DRAM_LDQM=DRAM_DQM_wire[0];

	//  ==========Make  more  necessary connections=================		
		
		assign 			DRAM_ADDR=DRAM_ADDR_wire;
		assign 			DRAM_BA=DRAM_CKE_wire;
		assign 			DRAM_WE_N=DRAM_WE_N_wire;
		assign 			DRAM_CAS_N=DRAM_CAS_N_wire;
		assign 			DRAM_RAS_N=DRAM_RAS_N_wire;
		assign 			DRAM_CS_N=DRAM_CS_N_wire;
		
		
		
	//
    //	
	
 
								  
								  
endmodule