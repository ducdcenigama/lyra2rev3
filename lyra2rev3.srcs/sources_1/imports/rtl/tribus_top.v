//======================================================================
//
// tribus_top.v
// --------
// Top level wrapper for the tribus/PHASE-2 block
//
//
// 
//
// 
// 
// 
//
//======================================================================

module tribus_top(
		clk, 
		chip_rst_n, 
		reg_addr,			  
		reg_wdata,		  
		reg_rdata,		  
		reg_wr,		
		reg_rd,		
		reg_wstrb,		  
		reg_bsy,				
		interrupt_o
    );	
    

  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
		parameter CORE_NUM     = 1;
  //----------------------------------------------------------------
  // Wires.
  //------------------
  input 				clk,  	chip_rst_n;
  input 		[8:0]	 	reg_addr;			     
  input  		[127:0]		reg_wdata;		     
  output 		[127:0]		reg_rdata;		     
  input 	 			reg_wr;		
  input 	 			reg_rd;		   		     
  input 	 	[15:0] 		reg_wstrb;	
  output 	 			reg_bsy;				     
  output 	 			interrupt_o;         
 
  //----------------------------------------------

//  wire [16:0]	 addr_tribus;

//  wire 		 oe_tribus;
//  wire 		 phase2;
//  wire [255:0]	 keccak_state;

//----------------------------------------------------------------
// Concurrent connectivity for ports etc.
//----------------------------------------------------------------
// assign read_data = tmp_read_data;

//----------------------------------------------------------------
// phase1 instantiation.
//----------------------------------------------------------------
wire 							softreset_sig, clk_DLL0,clk_DLL1,clk_DLL2,clk_DLL3;
wire 	rst_n		= chip_rst_n & ~softreset_sig;
wire 	reset		= ~rst_n;
wire  	[(32*CORE_NUM)-1:0]		FifoOut_all;
wire	[1151:0] 			Tribus144B;
wire 	[(CORE_NUM-1):0] 		fifo_overflow_all,	fifo_empty_all, RdFifoHit_all;


wire 	[(CORE_NUM-1):0]		coreRst;
wire 					reg_bsy=1'b0;
wire 	[3:0] 				clk_sel;
reg [(CORE_NUM-1):0] 			coreRstF1, coreRstF1_d1;
wire 	[31:0] 				target_2;
wire 	 				core_clk_enb;


if (CORE_NUM>=1)
begin
	always @ (posedge clk_DLL0)
	begin 
		coreRstF1_d1[0]	<=	(coreRst[0]|reset);
		coreRstF1[0]	<=	coreRstF1_d1[0];		
	end
end

if (CORE_NUM>=2)
begin
	always @ (posedge clk_DLL0)
	begin 
		coreRstF1_d1[1]	<=	(coreRst[1]|reset);
		coreRstF1[1]	<=	coreRstF1_d1[1];		
	end
end

if (CORE_NUM>=3)
begin
	always @ (posedge clk_DLL0)
	begin 
		coreRstF1_d1[2]	<=	(coreRst[2]|reset);
		coreRstF1[2]	<=	coreRstF1_d1[2];		
	end
end

if (CORE_NUM>=4)
begin
	always @ (posedge clk_DLL0)
	begin 
		coreRstF1_d1[3]	<=	(coreRst[3]|reset);
		coreRstF1[3]	<=	coreRstF1_d1[3];		
	end
end


genvar gi;

wire 	[31:0] 	fifo_out[0:(CORE_NUM-1)];

generate
	for (gi=0;gi<CORE_NUM;gi=gi+1)
	begin:set_FifoOut_all_loop
		assign FifoOut_all[(32*gi)+:32] = fifo_out[gi];
	end
endgenerate									
          
   
wire 		fifo_overflow[0:(CORE_NUM-1)];    
generate
	for (gi=0;gi<CORE_NUM;gi=gi+1)
	begin:set_fifo_overflow_all_loop
		assign fifo_overflow_all[gi] = fifo_overflow[gi];
	end
endgenerate	                                                                  
   

wire 				fifo_empty[0:(CORE_NUM-1)];
generate
	for (gi=0;gi<CORE_NUM;gi=gi+1)
	begin:set_fifo_empty_all_loop
		assign fifo_empty_all[gi] = fifo_empty[gi];
	end
endgenerate	                                                             

wire 				RdFifoHit[0:(CORE_NUM-1)];
generate
	for (gi=0;gi<CORE_NUM;gi=gi+1)
	begin:set_RdFifoHit_loop
		assign RdFifoHit[gi] = RdFifoHit_all[gi];
	end
endgenerate	                                                                                       

wire [127:0] 	coreNonceAll;
wire [31:0] 	nonce_start[0:(CORE_NUM-1)];
generate
	for (gi=0;gi<CORE_NUM;gi=gi+1)
	begin:set_nonce_start_loop
		assign nonce_start[gi] = coreNonceAll[32*gi+:32];
	end
endgenerate	  

wire [127:0] 	nonce_value_All;
wire [31:0] 	nonce_stp_value[0:(CORE_NUM-1)];

generate
	for (gi=0;gi<CORE_NUM;gi=gi+1)
	begin:set_nonce_stop_loop
		assign nonce_stp_value[gi] = nonce_value_All[32*gi+:32];
	end
endgenerate	 

wire [(CORE_NUM-1):0]	nonce_stp_flag_All;
wire  					nonce_stp_flag[0:(CORE_NUM-1)];

generate
	for (gi=0;gi<CORE_NUM;gi=gi+1)
	begin:set_nonce_stp_flag
		assign nonce_stp_flag_All[gi] = nonce_stp_flag[gi];
	end
endgenerate	 


tribus_regs #(
				.CORE_NUM(CORE_NUM)
		)  u_tribus_regs		(
        .clk				(clk),         //125Mhz from the pcie_module 
        .chip_rst_n			(chip_rst_n),                                                            
        .rst_n				(rst_n), 
	.reg_wr				(reg_wr),					                                                      
        .reg_rd				(reg_rd),                                                                
        .reg_addr			(reg_addr),                                                              
        .reg_wdata			(reg_wdata),                                                             
        .reg_rdata			(reg_rdata),                                                             
      	.reg_wstrb			(reg_wstrb),                                                             
      	                                                                                        	     	                
        .soc_id_pad			(8'h0A),  
        .Tribus144B		   	(Tribus144B),                                                        				  
        .coreNonceAll			(coreNonceAll),                                                              
        .nonce_value_All     		(nonce_value_All),                     
        .nonce_stp_flag_All		(nonce_stp_flag_All), 
        .coreRst			(coreRst),
        .clk_sel			(clk_sel[3:0]),
        .RdFifoHit			(RdFifoHit_all),
        .FifoOut_all			(FifoOut_all),
        .fifo_overflow			(fifo_overflow_all),
	.fifo_empty			(fifo_empty_all),
        .interrupt_top			(interrupt_o),                                                             
        .softreset_sig			(softreset_sig),
	.target_2			(target_2),
	.core_clk_enb			(core_clk_enb)
  );                                                                                                             

//--- link by the Xilinx MMCM module ---
mmcm_blk u_mmcm_blk
 (// Clock in ports
  // Clock out ports
  .clk_out0(clk_DLL0),
  // Status and control signals
  .resetn(chip_rst_n),
  //.locked(),
  .clk_in1(clk),
  .clk_sel(clk_sel[3:0]),
  .core_clk_enb(core_clk_enb)
 );

//======================================
//2 core for invalid debug used...
wire nonce_found[0:3];
wire [31:0] nonce_out[0:3];
wire nonce_found_same,nonce_out_same,fifo_out_same;
//assign nonce_found_same = (nonce_found[0]==nonce_found[1]);
//assign nonce_out_same   = (nonce_out[0]==nonce_out[1]);
//assign fifo_out_same    = (fifo_out[0]==fifo_out[1]);

if (CORE_NUM>=1)
tribus_core #(.RAM_MOD(3)) u_core_00 (.clk(clk_DLL0),.clk_axi(clk),.rst_n(rst_n),.chip_rst_n(chip_rst_n),.reset(coreRstF1[0]),.in(Tribus144B),.fifo_out(fifo_out[0]),.RdFifoHit(RdFifoHit[0]),.fifo_overflow(fifo_overflow[0]),.fifo_empty(fifo_empty[0]),.nonce_start(nonce_start[0]),.nonce_stp_value(nonce_stp_value[0]),.nonce_stp_flag(nonce_stp_flag[0]),.nonce_found(nonce_found[0]),.nonce_out(nonce_out[0]),.target_2(target_2));   //.in_ready(coreGo[00]),.re_go(re_go[00]),                                                                                                                                                                     

if (CORE_NUM>=2)
tribus_core #(.RAM_MOD(3)) u_core_01 (.clk(clk_DLL1),.clk_axi(clk),.rst_n(rst_n),.chip_rst_n(chip_rst_n),.reset(coreRstF1[1]),.in(Tribus144B),.fifo_out(fifo_out[1]),.RdFifoHit(RdFifoHit[1]),.fifo_overflow(fifo_overflow[1]),.fifo_empty(fifo_empty[1]),.nonce_start(nonce_start[1]),.nonce_stp_value(nonce_stp_value[1]),.nonce_stp_flag(nonce_stp_flag[1]),.nonce_found(nonce_found[1]),.nonce_out(nonce_out[1]),.target_2(target_2));   //.in_ready(coreGo[01]),.re_go(re_go[01]),

if (CORE_NUM>=3)
tribus_core #(.RAM_MOD(3)) u_core_02 (.clk(clk_DLL2),.clk_axi(clk),.rst_n(rst_n),.chip_rst_n(chip_rst_n),.reset(coreRstF1[2]),.in(Tribus144B),.fifo_out(fifo_out[2]),.RdFifoHit(RdFifoHit[2]),.fifo_overflow(fifo_overflow[2]),.fifo_empty(fifo_empty[2]),.nonce_start(nonce_start[2]),.nonce_stp_value(nonce_stp_value[2]),.nonce_stp_flag(nonce_stp_flag[2]),.nonce_found(nonce_found[2]),.nonce_out(nonce_out[2]),.target_2(target_2));   //.in_ready(coreGo[01]),.re_go(re_go[01]),

if (CORE_NUM>=4)
tribus_core #(.RAM_MOD(3)) u_core_03 (.clk(clk_DLL3),.clk_axi(clk),.rst_n(rst_n),.chip_rst_n(chip_rst_n),.reset(coreRstF1[3]),.in(Tribus144B),.fifo_out(fifo_out[3]),.RdFifoHit(RdFifoHit[3]),.fifo_overflow(fifo_overflow[3]),.fifo_empty(fifo_empty[3]),.nonce_start(nonce_start[3]),.nonce_stp_value(nonce_stp_value[3]),.nonce_stp_flag(nonce_stp_flag[3]),.nonce_found(nonce_found[3]),.nonce_out(nonce_out[3]),.target_2(target_2));   //.in_ready(coreGo[01]),.re_go(re_go[01]),
  


endmodule 
