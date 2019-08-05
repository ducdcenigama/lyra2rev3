//`define fifo_sim 1

module tribus_core #(
parameter RAM_MOD=3
) (
	clk,
	clk_axi,
	rst_n,
	chip_rst_n,
	reset,					
	//variant,
	in,							
//	in_ready,	

	RdFifoHit,
	fifo_out,			
//	re_go,
	fifo_overflow,
	fifo_empty,
	nonce_start,
	nonce_stp_value,
	nonce_stp_flag,
	nonce_found,
	nonce_out,
//	with_equal,
	target_2 
	);
	
input   						clk, clk_axi;
input 	rst_n,chip_rst_n,reset; 
//input              	variant;                          
input   [1151:0]  		in;                                 
//input              	in_ready;    
//input 	[31:0] 		coreNonce;      
input               RdFifoHit;
//output 				re_go;
output 				fifo_overflow;
output 				fifo_empty;
input 	[31:0]      nonce_start, nonce_stp_value; 
output  [31:0] 		fifo_out;                            
output          	nonce_stp_flag;
output         	nonce_found;    
output  [31:0] 		nonce_out;
//input               with_equal;  
input 	[31:0] 		target_2;    



//=======================================================

//====================================================

wire    [31:0]  nonce_out;
reg 	[1151:0] 	in_cdc; 
reg 	[31:0] 	nonce_start_cdc, nonce_stp_value_cdc; 
wire            nonce_found,	nonce_stop;
reg 	[1:0]  	nonce_stp_dly;
reg 		nonce_stp_flag, fifo_wr_disable;
wire 	[31:0] 	target_2; 

always @ (posedge clk)
begin 
	if (~rst_n)
	begin
    		in_cdc		<= 'h0;	
    		nonce_start_cdc		<= 'h0;
    		nonce_stp_value_cdc	<= 'h0;		
		//nonce_stp_dly[1:0] 	<= 'h0;
	end	
	else
	begin
    		in_cdc		        <= in;		
    		nonce_start_cdc	 	<=  nonce_start;	
    		nonce_stp_value_cdc	<=  nonce_stp_value;	
		//nonce_stp_dly[1:0] 	<=  {nonce_stp_dly[0],nonce_stop};
	end	
end

wire nonce_stp_flag_tmp	=	|nonce_stp_dly;

always @ (posedge clk)
begin 
	if (reset)
	begin
		nonce_stp_dly[1:0] 	<= 'h0;
		fifo_wr_disable		<= 'h0;
	end	
	else
	begin
        nonce_stp_dly[1:0] 	<=  {nonce_stp_dly[0],nonce_stop};
		//fifo_wr_disable		<=  nonce_stp_dly[1]|fifo_wr_disable;
		fifo_wr_disable		<=  nonce_stp_flag_tmp|fifo_wr_disable;				
	end	
end



always @ (posedge clk_axi)
begin 
	if (~rst_n)
	begin
    	nonce_stp_flag		<= 'h0;
	end	
	else
	begin
    	//nonce_stp_flag	 	<=  nonce_stp_flag_tmp;
    	nonce_stp_flag	 	<=  fifo_wr_disable;	
	end	
end


 miner  u_tribus_miner (
	.clk			(clk), 
	.reset			(reset), 
	.block			(in_cdc[1151:512]),
	.nonce_start	(nonce_start_cdc[31:0]),
	.nonce_stop	(nonce_stp_value_cdc[31:0]),
//	.with_equal     (with_equal),
	.nonce_found	(nonce_found),
	.core_stop		(nonce_stop),
	.nonce_out		(nonce_out[31:0])
 );	

	
	


//==========================================================
//for the fifo data signal...
reg 	[31:0]	fifo_in;         
wire  			fifo_we;       
     
wire  [31:0]	fifo_out;        
wire 			fifo_full;         
wire 			fifo_almost_full;        
wire 			fifo_wr_ack;       
wire 			fifo_overflow;       
wire 			fifo_empty;       
wire 			fifo_almost_empty;        
wire 			fifo_valid;         
wire 			fifo_underflow;       
wire [5:0] 		fifo_data_count;   
//wire 			fifo_we_rst_busy;        
//wire 			fifo_rst_busy;
//wire	[31:0] 	coreNonce;  

//assign  fifo_in_ok	= ~phase3doneD1 & phase3doneD2; 
//reg [15:0] fifoWrST;
reg fifoWrST;



//new design for nonce_stop flag

always @ (posedge clk)
begin
	if (~rst_n)
	begin
     		fifoWrST 		<= 'h0;
	end	
	else 
	begin
		if   (fifo_wr_disable) 
			fifoWrST 	<= 'h0;
		else 	
			fifoWrST 	<= nonce_found; 
	end		
end




reg [9:0] FifoWrCnt;
always @ (posedge clk)
begin
	if (~rst_n)
	begin
     fifo_in 	<= 'h0;
	 FifoWrCnt<='h00;
	 //FifordCnt<='h00; 
	end
	else 
	begin
/*
		case(fifoWrST)
			{16'b0000000000000001}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000000000000010}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000000000000100}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000000000001000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000000000010000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000000000100000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000000001000000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000000010000000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000000100000000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000001000000000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000010000000000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0000100000000000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
			{16'b0001000000000000}:fifo_in 	 <=  {4{nonce_out[31:0]}};
//DEFAULT
 		  default				fifo_in 	 <=  'h00;
		endcase
*/
			if (nonce_found) 	fifo_in		<=  nonce_out[31:0];
			else 				fifo_in		<=  'h00;

			FifoWrCnt	<=		nonce_found ? FifoWrCnt+1:FifoWrCnt;		
			
			
	 //FifordCnt<='h00; 			
			
	end	
end

assign fifo_we=fifoWrST;

//set the fifo rd signals here
//reg				reg_rd_d1, reg_rd_d2, reg_rd_d3; 
reg 			fifo_rd_trig, fifo_rd_trig_d1;
wire 			fifo_rd;
//wire 			reg_rd_pulse	= reg_rd & ~reg_rd_d1;  //the axi reg_rd=2 clk period

reg 	[9:0] 	FifoRdCnt;
//reg 			fifo_1st_rd,	fifo_1st_rd_d1;
reg 	[9:0] 	reg_rd_cnt_sum;

//wire 					fifo_rd_pulse_test	=	reg_rd_pulse & (reg_addr==DMABUFF_W00);

always @ (posedge clk_axi)
begin
	if (~rst_n)
	begin
//  	fifo_1st_rd			<=  'b0;
//   	fifo_1st_rd_d1	<=  'b0; 	
		//reg_rd_d1				<=  'b0;
   	FifoRdCnt			<=  'h0;
  	fifo_rd_trig		<= 	'h0;		
  	fifo_rd_trig_d1	<= 	'h0;
  	reg_rd_cnt_sum	<= 	'h0;  	
   	//{reg_rd_d3,reg_rd_d2,reg_rd_d1}	<=	'h0;
   	//dma_buf_00			<=	'h0;
	end	
	else 
	begin

//for debug used				
    if (RdFifoHit)
       reg_rd_cnt_sum <= reg_rd_cnt_sum+1'b1;				
	
			
  	fifo_rd_trig		<= RdFifoHit; //(FifoRdCnt=='d4);		
  	fifo_rd_trig_d1		<= fifo_rd_trig;	
  	//{reg_rd_d3,reg_rd_d2,reg_rd_d1}	<=	{reg_rd_d2,reg_rd_d1,reg_rd};
  	//dma_buf_00		<=	reg_rd_d2?fifo_out[127:0]:dma_buf_00;
	end	
end

//wire 	fifo_1st_rd_trig	=	fifo_1st_rd & ~fifo_1st_rd_d1;
wire 	fifo_rd_others		=	~fifo_rd_trig & fifo_rd_trig_d1;
//assign 	fifo_rd				=	fifo_1st_rd_trig|fifo_rd_others;
assign 	fifo_rd			=	fifo_rd_others;

wire 	fifo_empty_t, 		fifo_overflow_t;
//reg 	fifo_empty_d2, 		fifo_empty_d1;
//reg 	fifo_overflow_d2, fifo_overflow_d1;



assign 	fifo_empty			=  fifo_empty_t;   		
assign 	fifo_overflow		=  fifo_overflow_t;	
//==========================================

fifo_generator_dp1_ff_32x64
`ifdef fifo_sim
#(
    .C_COMMON_CLOCK(0),
//    .C_SELECT_XPM(0),
    .C_COUNT_TYPE(0),
    .C_DATA_COUNT_WIDTH(6),
    .C_DEFAULT_VALUE("BlankString"),
    .C_DIN_WIDTH(32),
    .C_DOUT_RST_VAL("0"),
    .C_DOUT_WIDTH(32),
    .C_ENABLE_RLOCS(0),
    .C_FAMILY("virtexuplus"),
    .C_FULL_FLAGS_RST_VAL(1),
    .C_HAS_ALMOST_EMPTY(1),
    .C_HAS_ALMOST_FULL(1),
    .C_HAS_BACKUP(0),
    .C_HAS_DATA_COUNT(0),
    .C_HAS_INT_CLK(0),
    .C_HAS_MEMINIT_FILE(0),
    .C_HAS_OVERFLOW(1),
    .C_HAS_RD_DATA_COUNT(1),
    .C_HAS_RD_RST(0),
    .C_HAS_RST(1),
    .C_HAS_SRST(0),
    .C_HAS_UNDERFLOW(1),
    .C_HAS_VALID(1),
    .C_HAS_WR_ACK(1),
    .C_HAS_WR_DATA_COUNT(1),
    .C_HAS_WR_RST(0),
    .C_IMPLEMENTATION_TYPE(2),
    .C_INIT_WR_PNTR_VAL(0),
    .C_MEMORY_TYPE(2),
    .C_MIF_FILE_NAME("BlankString"),
    .C_OPTIMIZATION_MODE(0),
    .C_OVERFLOW_LOW(0),
    .C_PRELOAD_LATENCY(0),
    .C_PRELOAD_REGS(1),
    .C_PRIM_FIFO_TYPE("512x36"),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL(4),
    .C_PROG_EMPTY_THRESH_NEGATE_VAL(5),
    .C_PROG_EMPTY_TYPE(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL(63),
    .C_PROG_FULL_THRESH_NEGATE_VAL(62),
    .C_PROG_FULL_TYPE(0),
    .C_RD_DATA_COUNT_WIDTH(6),
    .C_RD_DEPTH(64),
    .C_RD_FREQ(1),
    .C_RD_PNTR_WIDTH(6),
    .C_UNDERFLOW_LOW(0),
    .C_USE_DOUT_RST(1),
    .C_USE_ECC(0),
    .C_USE_EMBEDDED_REG(0),
    .C_USE_PIPELINE_REG(0),
    .C_POWER_SAVING_MODE(0),
    .C_USE_FIFO16_FLAGS(0),
    .C_USE_FWFT_DATA_COUNT(0),
    .C_VALID_LOW(0),
    .C_WR_ACK_LOW(0),
    .C_WR_DATA_COUNT_WIDTH(6),
    .C_WR_DEPTH(64),
    .C_WR_FREQ(1),
    .C_WR_PNTR_WIDTH(6),
    .C_WR_RESPONSE_LATENCY(1),
    .C_MSGON_VAL(1),
    .C_ENABLE_RST_SYNC(1),
    .C_EN_SAFETY_CKT(0),
    .C_ERROR_INJECTION_TYPE(0),
    .C_SYNCHRONIZER_STAGE(2),
    .C_INTERFACE_TYPE(0),
    .C_AXI_TYPE(1),
    .C_HAS_AXI_WR_CHANNEL(1),
    .C_HAS_AXI_RD_CHANNEL(1),
    .C_HAS_SLAVE_CE(0),
    .C_HAS_MASTER_CE(0),
    .C_ADD_NGC_CONSTRAINT(0),
    .C_USE_COMMON_OVERFLOW(0),
    .C_USE_COMMON_UNDERFLOW(0),
    .C_USE_DEFAULT_SETTINGS(0),
    .C_AXI_ID_WIDTH(1),
    .C_AXI_ADDR_WIDTH(32),
    .C_AXI_DATA_WIDTH(64),
    .C_AXI_LEN_WIDTH(8),
    .C_AXI_LOCK_WIDTH(1),
    .C_HAS_AXI_ID(0),
    .C_HAS_AXI_AWUSER(0),
    .C_HAS_AXI_WUSER(0),
    .C_HAS_AXI_BUSER(0),
    .C_HAS_AXI_ARUSER(0),
    .C_HAS_AXI_RUSER(0),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_AWUSER_WIDTH(1),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_AXI_RUSER_WIDTH(1),
    .C_HAS_AXIS_TDATA(1),
    .C_HAS_AXIS_TID(0),
    .C_HAS_AXIS_TDEST(0),
    .C_HAS_AXIS_TUSER(1),
    .C_HAS_AXIS_TREADY(1),
    .C_HAS_AXIS_TLAST(0),
    .C_HAS_AXIS_TSTRB(0),
    .C_HAS_AXIS_TKEEP(0),
    .C_AXIS_TDATA_WIDTH(8),
    .C_AXIS_TID_WIDTH(1),
    .C_AXIS_TDEST_WIDTH(1),
    .C_AXIS_TUSER_WIDTH(4),
    .C_AXIS_TSTRB_WIDTH(1),
    .C_AXIS_TKEEP_WIDTH(1),
    .C_WACH_TYPE(0),
    .C_WDCH_TYPE(0),
    .C_WRCH_TYPE(0),
    .C_RACH_TYPE(0),
    .C_RDCH_TYPE(0),
    .C_AXIS_TYPE(0),
    .C_IMPLEMENTATION_TYPE_WACH(1),
    .C_IMPLEMENTATION_TYPE_WDCH(1),
    .C_IMPLEMENTATION_TYPE_WRCH(1),
    .C_IMPLEMENTATION_TYPE_RACH(1),
    .C_IMPLEMENTATION_TYPE_RDCH(1),
    .C_IMPLEMENTATION_TYPE_AXIS(1),
    .C_APPLICATION_TYPE_WACH(0),
    .C_APPLICATION_TYPE_WDCH(0),
    .C_APPLICATION_TYPE_WRCH(0),
    .C_APPLICATION_TYPE_RACH(0),
    .C_APPLICATION_TYPE_RDCH(0),
    .C_APPLICATION_TYPE_AXIS(0),
    .C_PRIM_FIFO_TYPE_WACH("512x36"),
    .C_PRIM_FIFO_TYPE_WDCH("512x72"),
    .C_PRIM_FIFO_TYPE_WRCH("512x36"),
    .C_PRIM_FIFO_TYPE_RACH("512x36"),
    .C_PRIM_FIFO_TYPE_RDCH("512x72"),
    .C_PRIM_FIFO_TYPE_AXIS("1kx18"),
    .C_USE_ECC_WACH(0),
    .C_USE_ECC_WDCH(0),
    .C_USE_ECC_WRCH(0),
    .C_USE_ECC_RACH(0),
    .C_USE_ECC_RDCH(0),
    .C_USE_ECC_AXIS(0),
    .C_ERROR_INJECTION_TYPE_WACH(0),
    .C_ERROR_INJECTION_TYPE_WDCH(0),
    .C_ERROR_INJECTION_TYPE_WRCH(0),
    .C_ERROR_INJECTION_TYPE_RACH(0),
    .C_ERROR_INJECTION_TYPE_RDCH(0),
    .C_ERROR_INJECTION_TYPE_AXIS(0),
    .C_DIN_WIDTH_WACH(1),
    .C_DIN_WIDTH_WDCH(64),
    .C_DIN_WIDTH_WRCH(2),
    .C_DIN_WIDTH_RACH(32),
    .C_DIN_WIDTH_RDCH(64),
    .C_DIN_WIDTH_AXIS(1),
    .C_WR_DEPTH_WACH(16),
    .C_WR_DEPTH_WDCH(1024),
    .C_WR_DEPTH_WRCH(16),
    .C_WR_DEPTH_RACH(16),
    .C_WR_DEPTH_RDCH(1024),
    .C_WR_DEPTH_AXIS(1024),
    .C_WR_PNTR_WIDTH_WACH(4),
    .C_WR_PNTR_WIDTH_WDCH(10),
    .C_WR_PNTR_WIDTH_WRCH(4),
    .C_WR_PNTR_WIDTH_RACH(4),
    .C_WR_PNTR_WIDTH_RDCH(10),
    .C_WR_PNTR_WIDTH_AXIS(10),
    .C_HAS_DATA_COUNTS_WACH(0),
    .C_HAS_DATA_COUNTS_WDCH(0),
    .C_HAS_DATA_COUNTS_WRCH(0),
    .C_HAS_DATA_COUNTS_RACH(0),
    .C_HAS_DATA_COUNTS_RDCH(0),
    .C_HAS_DATA_COUNTS_AXIS(0),
    .C_HAS_PROG_FLAGS_WACH(0),
    .C_HAS_PROG_FLAGS_WDCH(0),
    .C_HAS_PROG_FLAGS_WRCH(0),
    .C_HAS_PROG_FLAGS_RACH(0),
    .C_HAS_PROG_FLAGS_RDCH(0),
    .C_HAS_PROG_FLAGS_AXIS(0),
    .C_PROG_FULL_TYPE_WACH(0),
    .C_PROG_FULL_TYPE_WDCH(0),
    .C_PROG_FULL_TYPE_WRCH(0),
    .C_PROG_FULL_TYPE_RACH(0),
    .C_PROG_FULL_TYPE_RDCH(0),
    .C_PROG_FULL_TYPE_AXIS(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
    .C_PROG_EMPTY_TYPE_WACH(0),
    .C_PROG_EMPTY_TYPE_WDCH(0),
    .C_PROG_EMPTY_TYPE_WRCH(0),
    .C_PROG_EMPTY_TYPE_RACH(0),
    .C_PROG_EMPTY_TYPE_RDCH(0),
    .C_PROG_EMPTY_TYPE_AXIS(0),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1022),
    .C_REG_SLICE_MODE_WACH(0),
    .C_REG_SLICE_MODE_WDCH(0),
    .C_REG_SLICE_MODE_WRCH(0),
    .C_REG_SLICE_MODE_RACH(0),
    .C_REG_SLICE_MODE_RDCH(0),
    .C_REG_SLICE_MODE_AXIS(0)
  )
`endif  //of fifo_sim
   u_fifo_32x64 (									       
  .wr_clk				(clk           		),					
  .rd_clk				(clk_axi  	   		),					
  //.rst					(~rst_n 	   		),  //ori       
  .rst					(reset 	   		),  	//mod. 
  .din					(fifo_in[31:0]  	),         
  .wr_en				(fifo_we 			),         
  .rd_en				(fifo_rd			),         
  .dout					(fifo_out[31:0]		),         
  .full					(fifo_full  		),         
  .almost_full	        (fifo_almost_full 	),         
  .wr_ack				(fifo_wr_ack   		),         
  .overflow			    (fifo_overflow_t	),         
  .empty				(fifo_empty_t		),         
  .almost_empty	        (fifo_almost_empty	),         
  .valid				(fifo_valid   		),         
  .underflow		    (fifo_underflow  	),         
  .wr_data_count		(fifo_data_count[5:0]),  
  .rd_data_count		() 
  //.wr_rst_busy	(fifo_we_rst_busy ),         
  //.rd_rst_busy	(fifo_rst_busy  	)          
  );                                         
//========================================== 
 //---- for invalid share debug here ---------------
reg [31:0] golden_nonce[0:3] = {32'h50918763,32'hb62b496e,32'hcc1a9b4d,32'hd9cb5952};
 
wire gnonce_hitAll_tmp, gnonce_hit0_tmp, gnonce_hit1_tmp, gnonce_hit2_tmp, gnonce_hit3_tmp;
reg gnonce_hitAll, gnonce_hit0, gnonce_hit1, gnonce_hit2, gnonce_hit3;

assign  gnonce_hitAll_tmp	= gnonce_hit0_tmp|gnonce_hit1_tmp|gnonce_hit2_tmp|gnonce_hit3_tmp;
assign  gnonce_hit0_tmp		= (nonce_out[31:0]==golden_nonce[0]);
assign  gnonce_hit1_tmp		= (nonce_out[31:0]==golden_nonce[1]);
assign 	gnonce_hit2_tmp		= (nonce_out[31:0]==golden_nonce[2]);
assign 	gnonce_hit3_tmp		= (nonce_out[31:0]==golden_nonce[3]);
 
reg got_invalid_op1;
 
always @(posedge clk)
begin 
	if (reset)
	begin	
	
		gnonce_hit0<=0;
		gnonce_hit1<=0;
		gnonce_hit2<=0;
		gnonce_hit3<=0;
		
		got_invalid_op1<=0;
		
	end
	else
	begin
	
		gnonce_hit0 <= (nonce_found & gnonce_hit0_tmp);
		gnonce_hit1 <= (nonce_found & gnonce_hit1_tmp);
		gnonce_hit2 <= (nonce_found & gnonce_hit2_tmp);
		gnonce_hit3 <= (nonce_found & gnonce_hit3_tmp);
		
		got_invalid_op1<= (nonce_found & ~gnonce_hitAll_tmp);		
	end
end	
 
 
//---- for fifo Wr-end invalid share debug here ---------------
//reg [31:0] golden_fifo[0:2] = {32'h50918763,32'hb62b496e,32'hcc1a9b4d};
 
wire gfifoWr_hitAll_tmp, gfifoWr_hit0_tmp, gfifoWr_hit1_tmp, gfifoWr_hit2_tmp, gfifoWr_hit3_tmp;
reg gfifoWr_hitAll, gfifoWr_hit0, gfifoWr_hit1, gfifoWr_hit2, gfifoWr_hit3;

assign  gfifoWr_hitAll_tmp		= gfifoWr_hit0_tmp|gfifoWr_hit1_tmp|gfifoWr_hit2_tmp|gfifoWr_hit3_tmp;
assign  gfifoWr_hit0_tmp		= (fifo_in[31:0]==golden_nonce[0]);
assign  gfifoWr_hit1_tmp		= (fifo_in[31:0]==golden_nonce[1]);
assign 	gfifoWr_hit2_tmp		= (fifo_in[31:0]==golden_nonce[2]);
assign 	gfifoWr_hit3_tmp		= (fifo_in[31:0]==golden_nonce[3]);
 
reg got_invalid_FifoWr;

 
 always @(posedge clk)
 begin 
	if (reset)
	begin	
	
		gfifoWr_hit0<=0;
		gfifoWr_hit1<=0;
		gfifoWr_hit2<=0;
		gfifoWr_hit3<=0;
		
		got_invalid_FifoWr<=0;
		
	end
	else
	begin
	
		gfifoWr_hit0 <= (fifo_we & gfifoWr_hit0_tmp);
		gfifoWr_hit1 <= (fifo_we & gfifoWr_hit1_tmp);
		gfifoWr_hit2 <= (fifo_we & gfifoWr_hit2_tmp);
		gfifoWr_hit3 <= (fifo_we & gfifoWr_hit3_tmp);
		
		got_invalid_FifoWr<= (fifo_we & ~gfifoWr_hitAll_tmp);		
	end
end	
 
 
//======================================================================== 
 //---- for fifo Rd-end invalid share debug here ---------------
//reg [31:0] golden_fifo[0:2] = {32'h50918763,32'hb62b496e,32'hcc1a9b4d};
 
wire gfifoRd_hitAll_tmp, gfifoRd_hit0_tmp, gfifoRd_hit1_tmp, gfifoRd_hit2_tmp, gfifoRd_hit3_tmp;
reg gfifoRd_hitAll, gfifoRd_hit0, gfifoRd_hit1, gfifoRd_hit2, gfifoRd_hit3;

assign  gfifoRd_hitAll_tmp		= gfifoRd_hit0_tmp|gfifoRd_hit1_tmp|gfifoRd_hit2_tmp|gfifoRd_hit3_tmp;
assign  gfifoRd_hit0_tmp		= (fifo_out[31:0]==golden_nonce[0]);
assign  gfifoRd_hit1_tmp		= (fifo_out[31:0]==golden_nonce[1]);
assign 	gfifoRd_hit2_tmp		= (fifo_out[31:0]==golden_nonce[2]);
assign 	gfifoRd_hit3_tmp		= (fifo_out[31:0]==golden_nonce[3]);
 
reg got_invalid_FifoRd;

 
 always @(posedge clk_axi)
 begin 
	if (reset)
	begin	
	
		gfifoRd_hit0<=0;
		gfifoRd_hit1<=0;
		gfifoRd_hit2<=0;
		gfifoRd_hit3<=0;
		
		got_invalid_FifoRd<=0;
		
	end
	else
	begin
	
		gfifoRd_hit0 <= (fifo_rd & gfifoRd_hit0_tmp);
		gfifoRd_hit1 <= (fifo_rd & gfifoRd_hit1_tmp);
		gfifoRd_hit2 <= (fifo_rd & gfifoRd_hit2_tmp);
		gfifoRd_hit3 <= (fifo_rd & gfifoRd_hit3_tmp);
		
		got_invalid_FifoRd<= (fifo_rd & ~gfifoRd_hitAll_tmp);		
	end
end	
 
//==============================================================
//=========== chech bad nonce ================================== 
 //---- for invalid share debug here ---------------
reg [31:0] bad_nonce[0:1] = {32'h4eb20725,32'h7a3e2128};
 
wire BadNonceHitAll_tmp, BadNonceHit0_tmp, BadNonceHit1_tmp;
reg  BadNonceHitAll, BadNonceHit0, BadNonceHit1;

assign  BadNonceHitAll_tmp		= BadNonceHit0_tmp|BadNonceHit1_tmp;
assign  BadNonceHit0_tmp		= (nonce_out[31:0]==bad_nonce[0]);
assign  BadNonceHit1_tmp		= (nonce_out[31:0]==bad_nonce[1]);

 
reg got_bad_op1;
 
always @(posedge clk)
begin 
	if (reset)
	begin	
	
		BadNonceHit0<=0;
		BadNonceHit1<=0;
		
		got_bad_op1<=0;
		
	end
	else
	begin
		BadNonceHit0 <= (nonce_found & BadNonceHit0_tmp);
		BadNonceHit1 <= (nonce_found & BadNonceHit1_tmp);
		
		got_bad_op1<= (nonce_found & ~BadNonceHitAll_tmp);		
	end
end	
 
 
//---- for fifo Wr-end invalid share debug here ---------------
//reg [31:0] golden_fifo[0:2] = {32'h50918763,32'hb62b496e,32'hcc1a9b4d};
 
wire BadFifoWrHitAll_tmp, BadFifoWrHit0_tmp, BadFifoWrHit1_tmp;
reg BadFifoWrHitAll, BadFifoWrHit0, BadFifoWrHit1;

assign  BadFifoWrHitAll_tmp		= BadFifoWrHit0_tmp|BadFifoWrHit1_tmp;
assign  BadFifoWrHit0_tmp		= (fifo_in[31:0]==bad_nonce[0]);
assign  BadFifoWrHit1_tmp		= (fifo_in[31:0]==bad_nonce[1]);
 
reg got_bad_FifoWr;

 
 always @(posedge clk)
 begin 
	if (reset)
	begin	
	
		BadFifoWrHit0<=0;
		BadFifoWrHit1<=0;
		
		got_bad_FifoWr<=0;
		
	end
	else
	begin
		BadFifoWrHit0 <= (fifo_we & BadFifoWrHit0_tmp);
		BadFifoWrHit1 <= (fifo_we & BadFifoWrHit1_tmp);
		
		got_bad_FifoWr<= (fifo_we & ~BadFifoWrHitAll_tmp);		
	end
end	
 
 
//======================================================================== 
 //---- for fifo Rd-end invalid share debug here ---------------
//reg [31:0] golden_fifo[0:2] = {32'h50918763,32'hb62b496e,32'hcc1a9b4d};
 
wire BadFifoRdHitAll_tmp, BadFifoRdHit0_tmp, BadFifoRdHit1_tmp;
reg BadFifoRdHitAll, BadFifoRdHit0, BadFifoRdHit1;

assign  BadFifoRdHitAll_tmp		= BadFifoRdHit0_tmp|BadFifoRdHit1_tmp;
assign  BadFifoRdHit0_tmp		= (fifo_out[31:0]==bad_nonce[0]);
assign  BadFifoRdHit1_tmp		= (fifo_out[31:0]==bad_nonce[1]);
 
reg got_bad_FifoRd;

 
 always @(posedge clk_axi)
 begin 
	if (reset)
	begin	
		BadFifoRdHit0<=0;
		BadFifoRdHit1<=0;
		
		got_bad_FifoRd<=0;
		
	end
	else
	begin
		BadFifoRdHit0 <= (fifo_rd & BadFifoRdHit0_tmp);
		BadFifoRdHit1 <= (fifo_rd & BadFifoRdHit1_tmp);
		
		got_bad_FifoRd<= (fifo_rd & ~BadFifoRdHitAll_tmp);		
	end
end	

 
 
 
 endmodule
