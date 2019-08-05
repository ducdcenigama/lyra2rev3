`define DMA_MODE 1
//`define fifo_sim 1

module tribus_regs #(
		//parameter DMA_MODE		=	1,
		parameter CORE_NUM     = 1
)(
//from top
        clk,
        //clk_DLL,
        chip_rst_n,
        rst_n,
        reg_wr,
        reg_rd,
        reg_addr,
        reg_wdata,
        reg_rdata,
	reg_wstrb, 
//to tribus cores 
        soc_id_pad,
	Tribus144B, 
	coreNonceAll,
	nonce_value_All,
        //phase3_doneF,
        nonce_stp_flag_All,
        coreRst,
        clk_sel,
        
        RdFifoHit, 
        FifoOut_all,
        fifo_overflow,
	fifo_empty,
        interrupt_top, 
        softreset_sig,
	target_2,
	core_clk_enb
 );
		
input   			clk;
//input 				clk_DLL;
input				chip_rst_n;
input				rst_n;
input           	reg_wr;
input          	  	reg_rd;
input   [8:0]   	reg_addr;
input   [127:0]  	reg_wdata;
input   [15:0] 		reg_wstrb;
output  [127:0]  	reg_rdata;
input   [7:0]   	soc_id_pad;
input 	[(CORE_NUM-1):0]	nonce_stp_flag_All;
output  [1151:0]  	Tribus144B;
input  [(32*CORE_NUM)-1:0] 	FifoOut_all;
output  [127:0] 	coreNonceAll;
output  [127:0] 	nonce_value_All;
//input 	[(CORE_NUM-1):0] 	phase3_doneF; 
//input 	[(CORE_NUM-1):0]		re_go;
input 	[(CORE_NUM-1):0] 		fifo_overflow;
input 	[(CORE_NUM-1):0] 		fifo_empty;
output 	[(CORE_NUM-1):0] 		RdFifoHit;

//----------------
//output  [16:0]   	mem_addr; 
//output  [127:0]   mem_wdata;       
//input   [127:0]   mem_rdata;       
//output          	mem_cs;
//output            mem_wr; 

//output [127:0]		axiwrenb;
//output [127:0]		axiwrnob;

//input	[(CORE_NUM-1):0]			tribus_active;

//output  					debug_en;
//output	[(CORE_NUM-1):0] 		debug_cnt;


//output 						mem_lock;
//output 		[(CORE_NUM-1):0]		coreGo;
output 		[(CORE_NUM-1):0]		coreRst;
output 		[3:0]			clk_sel;

output  				softreset_sig;
output 					interrupt_top;		
//input                   with_equal;		
output [31:0] 			target_2;
output 			core_clk_enb;
//input  [(CORE_NUM-1):0]		phase3_done;				

//-----------------------------------------
//set the PARAMETER of register addr.

//parameter XMR_CTRL0		= 9'h00;
//parameter MEM2M_WR_PORT	= 9'h01;
//parameter MEM2M_RD_PORT	= 9'h02;

parameter XMR_CTRL0		= 9'h00;
parameter XMR_STATUS	= 9'h01;
parameter START_NONCE	= 9'h02;
parameter NONCE_CNT_VALUE= 9'h03;
//parameter TARGET_2		= 9'h04;
parameter FPGA_DNA	= 9'h05;
//parameter NONCE_CHK3	= 9'h06;
//parameter NONCE_CHK4	= 9'h07;

parameter DLL_CTRL		= 9'h04;

parameter Tribus144B_W0	= 9'h07;
parameter Tribus144B_W1	= 9'h08;
parameter Tribus144B_W2	= 9'h09;
parameter Tribus144B_W3	= 9'h0A;
parameter Tribus144B_W4	= 9'h0B;
parameter Tribus144B_W5	= 9'h0C;
parameter Tribus144B_W6	= 9'h0D;
parameter Tribus144B_W7	= 9'h0E;
parameter Tribus144B_W8	= 9'h0F;

//parameter INITNONCE_W0	= 9'h19;
//parameter INITNONCE_W1	= 9'h1A;
//parameter INITNONCE_W2	= 9'h1B;
//parameter INITNONCE_W3	= 9'h1C; 
//parameter INITNONCE_W4	= 9'h1D; 

//===================================
parameter DMABUFF_B00	= 9'h10;
/*
parameter DMABUFF_B01	= 9'h11;
parameter DMABUFF_B02	= 9'h12;
parameter DMABUFF_B03	= 9'h13;
parameter DMABUFF_B03	= 9'h163;
parameter DMABUFF_B04	= 9'h164;
parameter DMABUFF_B05	= 9'h165;
parameter DMABUFF_B06	= 9'h166;
parameter DMABUFF_B07	= 9'h167;
parameter DMABUFF_B08	= 9'h168; 
parameter DMABUFF_B09	= 9'h169; 
parameter DMABUFF_B10	= 9'h16A; 
parameter DMABUFF_B11	= 9'h16B; 
parameter DMABUFF_B12	= 9'h16C;
parameter DMABUFF_B13	= 9'h16D;
parameter DMABUFF_B14	= 9'h16E;
parameter DMABUFF_B15	= 9'h16F;
parameter DMABUFF_B16	= 9'h170;
parameter DMABUFF_B17	= 9'h171; 
parameter DMABUFF_B18	= 9'h172; 
parameter DMABUFF_B19	= 9'h173; 
*/
//for 9-bit addr test
parameter TEST_1F0= 'h1F0; 
parameter TEST_1F1= 'h1F1;
//-------------------------------------------------------------
genvar gi;

//--------------------------------------------------------------
reg  [127:0] 	Tribus144B_00,	Tribus144B_01,	Tribus144B_02,	Tribus144B_03,	Tribus144B_04,
				Tribus144B_05,	Tribus144B_06,	Tribus144B_07,	Tribus144B_08,	xmr_ctrl0, 
				nonce_stp_value; //Nonce_CNT_VL00,	initnonce_01,	initnonce_02,	initnonce_03,	initnonce_04,	
				//xmr_ctrl0, 		test_reg1F0; 					
wire [16:0] 	t0=reg_wstrb;

wire [127:0] 	axiwrenb	= { {8{t0[15]}},{8{t0[14]}},{8{t0[13]}},{8{t0[12]}},
								{8{t0[11]}},{8{t0[10]}},{8{t0[9]}},	{8{t0[8]}},
								{8{t0[7]}}, {8{t0[6]}},	{8{t0[5]}},	{8{t0[4]}},
								{8{t0[3]}}, {8{t0[2]}},	{8{t0[1]}},	{8{t0[0]}}};
								
wire 	[127:0]	axiwrnob	=	~axiwrenb[127:0];
wire 	[127:0]	reg_wdata_1	=	reg_wdata[127:0] & axiwrenb[127:0];
reg 	[127:0] start_nonce;
reg   	[(CORE_NUM-1):0]	coreGoST0,coreGoST1,coreGoST2,coreGoST3,coreGoST4,coreGoST5,coreGoST6;
//wire                    with_equal;

	
always @ (posedge clk)
begin
  if(!rst_n)
  begin
		xmr_ctrl0  	<= 'd0;  
    	start_nonce <='d0;
		nonce_stp_value <='d0;
		
//    	DLL_CTRL	<='d0;
		
		Tribus144B_00 <= 'd0;
		Tribus144B_01 <= 'd0;  
		Tribus144B_02 <= 'd0;  	
		Tribus144B_03 <= 'd0;  
		Tribus144B_04 <= 'd0;  
		Tribus144B_05 <= 'd0;
		Tribus144B_06 <= 'd0;  
		Tribus144B_07 <= 'd0;  	
		Tribus144B_08 <= 'd0;  
				
		//initnonce_00 <= 'd0;
		//initnonce_01 <= 'd0;  
		//initnonce_02 <= 'd0;  	
		//initnonce_03 <= 'd0;  
		//initnonce_04 <= 'd0;  
	    //test_reg1F0  <= 'd0;		
  end	
  else 
  begin
  	if (reg_wr)
  	begin
  		case (reg_addr[8:0])  
  		 	XMR_CTRL0	:xmr_ctrl0 		<= reg_wdata_1[127:0]|xmr_ctrl0 & axiwrnob[127:0];
  		 	START_NONCE	:start_nonce 	<= reg_wdata_1[127:0]|start_nonce & axiwrnob[127:0];
			NONCE_CNT_VALUE: nonce_stp_value <=	reg_wdata_1[127:0]|nonce_stp_value & axiwrnob[127:0];
			
			Tribus144B_W0:Tribus144B_00 <= reg_wdata_1[127:0]|Tribus144B_00 & axiwrnob[127:0];   
			Tribus144B_W1:Tribus144B_01 <= reg_wdata_1[127:0]|Tribus144B_01 & axiwrnob[127:0];  
			Tribus144B_W2:Tribus144B_02 <= reg_wdata_1[127:0]|Tribus144B_02 & axiwrnob[127:0];  	
			Tribus144B_W3:Tribus144B_03 <= reg_wdata_1[127:0]|Tribus144B_03 & axiwrnob[127:0];  	
			Tribus144B_W4:Tribus144B_04 <= reg_wdata_1[127:0]|Tribus144B_04 & axiwrnob[127:0];   
			Tribus144B_W5:Tribus144B_05 <= reg_wdata_1[127:0]|Tribus144B_05 & axiwrnob[127:0];   
			Tribus144B_W6:Tribus144B_06 <= reg_wdata_1[127:0]|Tribus144B_06 & axiwrnob[127:0];  
			Tribus144B_W7:Tribus144B_07 <= reg_wdata_1[127:0]|Tribus144B_07 & axiwrnob[127:0];  	
			Tribus144B_W8:Tribus144B_08 <= reg_wdata_1[127:0]|Tribus144B_08 & axiwrnob[127:0];  	

//			INITNONCE_W0:initnonce_00 <= reg_wdata_1[127:0]|initnonce_00 & axiwrnob[127:0];   
//			INITNONCE_W1:initnonce_01 <= reg_wdata_1[127:0]|initnonce_01 & axiwrnob[127:0];  
//			INITNONCE_W2:initnonce_02 <= reg_wdata_1[127:0]|initnonce_02 & axiwrnob[127:0];  	
//			INITNONCE_W3:initnonce_03 <= reg_wdata_1[127:0]|initnonce_03 & axiwrnob[127:0];  	
// 			INITNONCE_W4:initnonce_04 <= reg_wdata_1[127:0]|initnonce_04 & axiwrnob[127:0];  
 			   
 			//TEST_1F0    :test_reg1F0  <= reg_wdata_1[127:0]|test_reg1F0 & axiwrnob[127:0];
  		endcase     
 	end 
 	else 
 		xmr_ctrl0[(CORE_NUM-1+32):32]	<=	xmr_ctrl0[(CORE_NUM-1+32):32] ^ coreGoST0[(CORE_NUM-1):0];
		//xmr_ctrl0[32]	<=	xmr_ctrl0[32] ^ coreGoST0[0];  //ok
		//xmr_ctrl0[32]	<=	xmr_ctrl0[32]^coreGoST0[0];  //ok
		//if (coreGoST0[0])  xmr_ctrl0[32]	<=1'b0; //ok
    end     
end

assign coreNonceAll[127:0] = start_nonce[127:0];
assign nonce_value_All[127:0] = nonce_stp_value[127:0]; 


//==========================================================
//set the DLL clock 
//parameter DLL_CTRL		= 9'h0A;
//chip_rst_n
wire 	[3:0] 	clk_sel;
reg 	[127:0] DLL_ctrl;
wire 		core_clk_enb;
 
always @ (posedge clk)
if(!chip_rst_n)    //only reset by chip_rst_n
begin 
    DLL_ctrl[127:0]	 	<= 'h0;
end
else
begin
  	if (reg_wr & (reg_addr==DLL_CTRL))
	    DLL_ctrl[127:0]	 	<= reg_wdata_1[127:0]|DLL_ctrl[127:0]& axiwrnob[127:0]; 
end 

assign 	clk_sel[3:0]	=	DLL_ctrl[3:0];
assign 	core_clk_enb	=	DLL_ctrl[32];


//==============================================================
//set the control register signal here...
wire 		 sw_rst; //interrupt_top_mask, 
//wire [31:0] coremask;

//assign 		coremask[(CORE_NUM-1):0]= xmr_ctrl0[83:64];
//assign 		interrupt_top_mask		= xmr_ctrl0[2];
//assign stop						= xmr_ctrl0[1];
assign sw_rst						= xmr_ctrl0[0];
//assign with_equal                   = xmr_ctrl0[3];
assign target_2                   	= xmr_ctrl0[95:64];
/*
wire 	coreGoReg19,coreGoReg18,coreGoReg17,coreGoReg16,coreGoReg15,
			coreGoReg14,coreGoReg13,coreGoReg12,coreGoReg11,coreGoReg10,
			coreGoReg09,coreGoReg08,coreGoReg07,coreGoReg06,coreGoReg05,
			coreGoReg04,coreGoReg03,coreGoReg02,coreGoReg01,coreGoReg00;
*/
reg 	[(CORE_NUM-1):0] coreGoD1, coreGoD2;
//reg 	[(CORE_NUM-1):0] re_go;



/*			
wire 	coreMsk19,coreMsk18,coreMsk17,coreMsk16,coreMsk15,
			coreMsk14,coreMsk13,coreMsk12,coreMsk11,coreMsk10,
			coreMsk09,coreMsk08,coreMsk07,coreMsk06,coreMsk05,
			coreMsk04,coreMsk03,coreMsk02,coreMsk01,coreMsk00;
			
assign {coreMsk19,coreMsk18,coreMsk17,coreMsk16,coreMsk15,
			coreMsk14,coreMsk13,coreMsk12,coreMsk11,coreMsk10,
			coreMsk09,coreMsk08,coreMsk07,coreMsk06,coreMsk05,
			coreMsk04,coreMsk03,coreMsk02,coreMsk01,coreMsk00}	=	xmr_ctrl0	[83:64];			
*/

//wire [(CORE_NUM-1):0] coreMask;
//reg [(CORE_NUM-1):0]  phase3_doneF;	

//assign 	coreMask[(CORE_NUM-1):0] = xmr_ctrl0[83:64];
reg 	[(CORE_NUM-1):0] nonce_stp_rst;

always @ (posedge clk)
if(!rst_n)
begin 
    coreGoD1 <= 'h0;
    coreGoD2 <= 'h0;
    coreGoST0 <= 'h0;
    coreGoST1 <= 'h0;    
    coreGoST2 <= 'h0;
    coreGoST3 <= 'h0;    
    coreGoST4 <= 'h0;
    coreGoST5 <= 'h0;  
    coreGoST6 <= 'h0;    
	nonce_stp_rst <= 'h0; 
end
else
begin
    coreGoD1 <= xmr_ctrl0[51:32];   //[corego19:corego00]
    coreGoD2 <= coreGoD1;			
    coreGoST0 <= (coreGoD1 & ~coreGoD2); //|(xmr_ctrl0[51:32] & re_go[(CORE_NUM-1):0]); 
    coreGoST1 <= coreGoST0;    
    coreGoST2 <= coreGoST1;
    coreGoST3 <= coreGoST2;    
    coreGoST4 <= coreGoST3;
    coreGoST5 <= coreGoST4;  
    coreGoST6 <= coreGoST5;   
	nonce_stp_rst <= nonce_stp_flag_All|nonce_stp_rst & ~coreGoST0;
end

wire [(CORE_NUM-1):0] coreRst_P,coreGo_P,coreRst;	
assign  		coreRst_P	= (coreGoST0|coreGoST1|coreGoST2); //|nonce_stp_rst;  //hold the rst when nonce_stop trigger.....
assign  		coreGo_P	= (coreGoST5|coreGoST6);
assign  		coreRst		= coreRst_P;
//=======================================================
/*
//set the CDC process here
reg [(CORE_NUM-1):0] coreRstDLL2, coreRstDLL1, coreRstDLL0;	
reg [(CORE_NUM-1):0] coreGoDLL2, coreGoDLL1, coreGoDLL0;	

always @ (posedge clk_DLL)
if(!rst_n)
begin 
    {coreRstDLL2, coreRstDLL1, coreRstDLL0}	 	<= 'h0;
    {coreGoDLL2,  coreGoDLL1,  coreGoDLL0} 		<= 'h0;
end
else
begin
    {coreRstDLL2, coreRstDLL1, coreRstDLL0}	 	<= {coreRstDLL1, coreRstDLL0, coreRst_P};	
    {coreGoDLL2, coreGoDLL1, coreGoDLL0} 		<= {coreGoDLL1, coreGoDLL0, coreGo_P};
end    

wire [(CORE_NUM-1):0] coreRst,coreGo;	
assign  coreRst	=	coreRstDLL2; //(coreGoST0|coreGoST1);  
assign  coreGo	=	~coreGoDLL2 & coreGoDLL1;	//coreGoST4;
*/

//set the phase3_done
//reg [(CORE_NUM-1):0] phase3doneFlag; //,phase3doneClr;
//reg [4:0] fifoCore;
//reg [15:0] fifoWrST;
/*
reg [(CORE_NUM-1):0] phase3doneDLL2, phase3doneDLL1, phase3doneDLL0;


always @ (posedge clk or negedge rst_n)
if(!rst_n)
begin 
    {phase3doneDLL2, phase3doneDLL1, phase3doneDLL0}	 	<= 'h0;
end
else
begin
    {phase3doneDLL2, phase3doneDLL1, phase3doneDLL0}	 	<= {phase3doneDLL1, phase3doneDLL0, phase3_done};	
end   

wire [(CORE_NUM-1):0] phase3_doneF;	
assign  phase3_doneF	= ~phase3doneDLL1 & phase3doneDLL2; 
*/

	
//==============================================================
/*
always @ (posedge clk or negedge rst_n)
if(!rst_n)
begin 
     phase3doneFlag[(CORE_NUM-1):0] 	<= 'h0;
end
else
begin
    phase3doneFlag[(CORE_NUM-1):0]	 	<=  phase3_done[(CORE_NUM-1):0]|(phase3doneFlag[(CORE_NUM-1):0] & ~phase3_doneF[(CORE_NUM-1):0]);	
end   
*/

reg [7:0] softreset_cnt;

always @ (posedge clk)
      if(!chip_rst_n)
      	softreset_cnt  <= 'b0;
      else 
       	softreset_cnt[7:0]  <= {softreset_cnt[6:0],sw_rst};
       	
(* dont_touch = "true" *) wire softreset_sig;
assign 	softreset_sig = |softreset_cnt[7:0];
//------------------------------------------------------
//set the start nonce and nonce increase function here
/*
wire [31:0]	InitNonce03,InitNonce02,InitNonce01,InitNonce00,
						InitNonce07,InitNonce06,InitNonce05,InitNonce04,									
						InitNonce11,InitNonce10,InitNonce09,InitNonce08,											
						InitNonce15,InitNonce14,InitNonce13,InitNonce12,											
						InitNonce19,InitNonce18,InitNonce17,InitNonce16;

reg [31:0]	NonceCnt03,NonceCnt02,NonceCnt01,NonceCnt00,
						NonceCnt07,NonceCnt06,NonceCnt05,NonceCnt04,									
						NonceCnt11,NonceCnt10,NonceCnt09,NonceCnt08,											
						NonceCnt15,NonceCnt14,NonceCnt13,NonceCnt12,											
						NonceCnt19,NonceCnt18,NonceCnt17,NonceCnt16;	
						
wire [607:0] 	Tribus144B_c00, Tribus144B_c01,	Tribus144B_c02,	Tribus144B_c03,
							Tribus144B_c04, Tribus144B_c05,	Tribus144B_c06,	Tribus144B_c07,
							Tribus144B_c08, Tribus144B_c09,	Tribus144B_c10,	Tribus144B_c11,
							Tribus144B_c12, Tribus144B_c13,	Tribus144B_c14,	Tribus144B_c15,
							Tribus144B_c16, Tribus144B_c17,	Tribus144B_c18,	Tribus144B_c19;	
*/

//wire 	[31:0]		InitNonce [0:(CORE_NUM-1)];
//reg 	[31:0]		NonceCnt [0:(CORE_NUM-1)];
//wire 	[1152:0] 	Tribus144B[0:(CORE_NUM-1)];
						
wire 	[1151:0] 	Tribus144B;
assign 				Tribus144B[1151:0]={Tribus144B_00,Tribus144B_01,Tribus144B_02,Tribus144B_03,Tribus144B_04,Tribus144B_05,Tribus144B_06,Tribus144B_07,Tribus144B_08};


//----------------------------------------------------------
//=====================================
// Read Logic
//=====================================
//to read the FPGA DNA data 	
reg  	[6:0]  	DnaSmCnt;
reg 	[95:0]  DnaReg;
wire 	[127:0] DnaData;
wire 	DnaDin, DnaDout;
reg 	DnaRead, DnaShift, DnaRdOk;

assign DnaDin=1'b0;
assign DnaData[127:0]= DnaRdOk ? {32'h0,DnaReg[95:0]}:'h0;

always @ (posedge clk)
begin
	if(!rst_n)
	begin
    DnaSmCnt	<='h0;
    DnaReg		<='h0;
    DnaRead	<='b0;
    DnaShift	<='b0;
    DnaRdOk	<='b0;
	end    
	else 
	begin
  	if (DnaSmCnt < 99) 	DnaSmCnt	<= DnaSmCnt +1;
  
  	if (DnaSmCnt==0) 
  	begin
  		DnaRead	<='b1;
  		DnaShift	<='b0;
  	end
  	else if (DnaSmCnt > 0 & DnaSmCnt < 97)
  	begin
    	DnaRead	<='b0;
  		DnaShift	<='b1;
  	end
  	else 
  	begin
    	DnaRead	<='b0;
  		DnaShift	<='b0;
  	end  
    
  	if (DnaSmCnt >=2 & DnaSmCnt <=97)
  	begin
    	DnaReg[95:0] <=  {DnaDout, DnaReg[95:1]};
  	end
  	
  	if (DnaSmCnt > 98)  DnaRdOk	<='b1;
  	
  end	
end  
   
  
DNA_PORTE2 #(
      //.SIM_DNA_VALUE(96'h000000000000000000000000)  // Specifies a sample 96-bit DNA value for simulation
        .SIM_DNA_VALUE(96'h5aa55aa55aa55aa55aa55aa5)  // Specifies a sample 96-bit DNA value for simulation  
) DNA_PORTE2_inst (
      .DOUT(DnaDout),   	// 1-bit output: DNA output data
      .CLK(clk),     			// 1-bit input: Clock input
      .DIN(DnaDin),     	// 1-bit input: User data input pin
      .READ(DnaRead),   	// 1-bit input: Active-High load DNA, active-Low read input
      .SHIFT(DnaShift)  	// 1-bit input: Active-High shift enable input
  );


//-------------------------------------
//SOC_STATUS 0x60 
//reg  	[4:0]  	coreid_reg;
wire 	[127:0] 	core_status_sig;

//reg       interrupt_core00_reg;
   //coremask         

reg 	[(CORE_NUM-1):0] coreInterrupt; 
reg     interrupt_top_reg; 
reg 	START_NONCE_up_reg;

wire 	rd_status, rd_status_fall;
reg  	rd_status_d1;
assign  rd_status=(reg_addr==XMR_STATUS) & reg_rd;

always @ (posedge clk)
begin
if(!rst_n)
    rd_status_d1<='h0;
else 
    rd_status_d1<=rd_status; 
end    
 
assign rd_status_fall = ~rd_status & rd_status_d1;

always @ (posedge clk)
  if(!rst_n)
  begin
    interrupt_top_reg	<=	'b0;
    coreInterrupt		<=	'h0;
    START_NONCE_up_reg	<=	'b0;
  end  
  else 
  begin
  		if (rd_status_fall)  //clear after rd
  		begin
  		    interrupt_top_reg		<=	'b0;
    		coreInterrupt[(CORE_NUM-1):0]	<=	'h0;
    		START_NONCE_up_reg		<=	'b0;
  		end
  		else
  		begin
     		coreInterrupt[(CORE_NUM-1):0] 	<= 'h0; //coreInterrupt |(~coreMask[(CORE_NUM-1):0] & phase3_doneF[(CORE_NUM-1):0]);  	
    		//interrupt_top_reg 		<= (~interrupt_top_mask & (|coreInterrupt)| START_NONCE_up_reg); 
    		interrupt_top_reg 		<= 'h0; 
    		//START_NONCE_up_reg		<=	START_NONCE_up ? 1'b1: START_NONCE_up_reg ;
    		START_NONCE_up_reg		<=	1'b0 ;
    	end 
  end   
  
assign interrupt_top=interrupt_top_reg;

wire [7:0] core_num=CORE_NUM;

//for mod




wire [7:0] fifo_empty_t,fifo_overflow_t,nonce_stp_flag_All_t;

if (CORE_NUM==1)
		assign fifo_empty_t={7'h0,fifo_empty[0]};
else if (CORE_NUM==2)
		assign fifo_empty_t={6'h0,fifo_empty[1],fifo_empty[0]};
else if (CORE_NUM==3)
		assign fifo_empty_t={5'h0,fifo_empty[2],fifo_empty[1],fifo_empty[0]};		
else if (CORE_NUM==4)
		assign fifo_empty_t={4'h0,fifo_empty[3],fifo_empty[2],fifo_empty[1],fifo_empty[0]};		
		
if (CORE_NUM==1)
		assign fifo_overflow_t={7'h0,fifo_overflow[0]};
else if (CORE_NUM==2)
		assign fifo_overflow_t={6'h0,fifo_overflow[1],fifo_overflow[0]};
else if (CORE_NUM==3)
		assign fifo_overflow_t={5'h0,fifo_overflow[2],fifo_overflow[1],fifo_overflow[0]};		
else if (CORE_NUM==4)
		assign fifo_overflow_t={4'h0,fifo_overflow[3],fifo_overflow[2],fifo_overflow[1],fifo_overflow[0]};		
		
if (CORE_NUM==1)
		assign nonce_stp_flag_All_t={7'h0,nonce_stp_flag_All[0]};
else if (CORE_NUM==2)
		assign nonce_stp_flag_All_t={6'h0,nonce_stp_flag_All[1],nonce_stp_flag_All[0]};
else if (CORE_NUM==3)
		assign nonce_stp_flag_All_t={5'h0,nonce_stp_flag_All[2],nonce_stp_flag_All[1],nonce_stp_flag_All[0]};		
else if (CORE_NUM==4)
		assign nonce_stp_flag_All_t={4'h0,nonce_stp_flag_All[3],nonce_stp_flag_All[2],nonce_stp_flag_All[1],nonce_stp_flag_All[0]};		
	
	
assign  core_status_sig =  {
			80'h00,
			//START_NONCE_up_reg,	
			//interrupt_top_reg, 
			//coreInterrupt[(CORE_NUM-1):0],
			nonce_stp_flag_All_t[7:0],
			//fifo_overflow_t[7:0],			
			fifo_empty_t[7:0],
			16'h00,
			core_num[7:0],		   
			soc_id_pad[7:0]
			};
            
reg 	[127:0]   	reg_rdata;

wire 	[31:0]  	FifoOut[0:(CORE_NUM-1)];
generate
	for(gi=0;gi<CORE_NUM;gi=gi+1)
	begin:set_fifo_out_loop
		assign 	 FifoOut[gi]=FifoOut_all[32*gi+:32];
	end
endgenerate	
       
always @ (*) 
begin
        case (reg_addr)
          	XMR_CTRL0		: reg_rdata <= xmr_ctrl0; 
        	XMR_STATUS		: reg_rdata <= core_status_sig;
        	START_NONCE		:	reg_rdata <= start_nonce;
					NONCE_CNT_VALUE: reg_rdata <= nonce_stp_value;			
					FPGA_DNA			: reg_rdata <= DnaData[127:0];	
//         	NONCE_CHK0	:	reg_rdata <= {NonceCnt[03],NonceCnt[02],NonceCnt[01],NonceCnt[00]};    
//         	NONCE_CHK1	:	reg_rdata <= {NonceCnt[07],NonceCnt[06],NonceCnt[05],NonceCnt[04]};            		
//         	NONCE_CHK2	:	reg_rdata <= {NonceCnt[11],NonceCnt[10],NonceCnt[09],NonceCnt[08]};            		
//         	NONCE_CHK3	:	reg_rdata <= {NonceCnt[15],NonceCnt[14],NonceCnt[13],NonceCnt[12]};            		
//         	NONCE_CHK4	:	reg_rdata <= {NonceCnt[19],NonceCnt[18],NonceCnt[17],NonceCnt[16]};  
          	//wait to add other core cnt here.................
          	
          	
          	DLL_CTRL	:	reg_rdata <= DLL_ctrl[127:0];          		
         		          		       		        		        		        		
            Tribus144B_W0: 	reg_rdata <= Tribus144B_00; 
            Tribus144B_W1: 	reg_rdata <= Tribus144B_01; 
            Tribus144B_W2: 	reg_rdata <= Tribus144B_02; 
            Tribus144B_W3: 	reg_rdata <= Tribus144B_03; 
            Tribus144B_W4: 	reg_rdata <= Tribus144B_04; 
            Tribus144B_W5: 	reg_rdata <= Tribus144B_05; 
            Tribus144B_W6: 	reg_rdata <= Tribus144B_06; 
            Tribus144B_W7: 	reg_rdata <= Tribus144B_07; 
            Tribus144B_W8: 	reg_rdata <= Tribus144B_08; 
		
            //Tribus144B_05: reg_rdata <= Tribus144B_05; 
            //Tribus144B_06: reg_rdata <= Tribus144B_06; 
            //Tribus144B_07: reg_rdata <= Tribus144B_07; 
            //Tribus144B_08: reg_rdata <= Tribus144B_08; 
            //Tribus144B_09: reg_rdata <= Tribus144B_09; 
            //Tribus144B_0A: reg_rdata <= Tribus144B_0A; 
            //Tribus144B_0B: reg_rdata <= Tribus144B_0B; 
            //Tribus144B_0C: reg_rdata <= Tribus144B_0C;   
            
         	//INITNONCE_W0: reg_rdata <= initnonce_00;   
  	  		//INITNONCE_W1: reg_rdata <= initnonce_01;  
  	  		//INITNONCE_W2: reg_rdata <= initnonce_02;  	
  	  		//INITNONCE_W3: reg_rdata <= initnonce_03;  	
 			//INITNONCE_W4: reg_rdata <= initnonce_04; 
 			
            DMABUFF_B00: reg_rdata <=  FifoOut[00];  
			/*
            DMABUFF_B01: reg_rdata <=  FifoOut[01];  
            DMABUFF_B02: reg_rdata <=  FifoOut[02];  
            DMABUFF_B03: reg_rdata <=  FifoOut[03];  
            DMABUFF_B03: reg_rdata <=  FifoOut[03];  
            DMABUFF_B04: reg_rdata <=  FifoOut[04];  
            DMABUFF_B05: reg_rdata <=  FifoOut[05];  
            DMABUFF_B06: reg_rdata <=  FifoOut[06];  
            DMABUFF_B07: reg_rdata <=  FifoOut[07];  
            DMABUFF_B08: reg_rdata <=  FifoOut[08];   
            DMABUFF_B09: reg_rdata <=  FifoOut[09];   
            DMABUFF_B10: reg_rdata <=  FifoOut[10];   
            DMABUFF_B11: reg_rdata <=  FifoOut[11];   
            DMABUFF_B12: reg_rdata <=  FifoOut[12];  
            DMABUFF_B13: reg_rdata <=  FifoOut[13]; 
            DMABUFF_B14: reg_rdata <=  FifoOut[14]; 
            DMABUFF_B15: reg_rdata <=  FifoOut[15]; 
            DMABUFF_B16: reg_rdata <=  FifoOut[16]; 
            DMABUFF_B17: reg_rdata <=  FifoOut[17]; 
            DMABUFF_B18: reg_rdata <=  FifoOut[18]; 
            DMABUFF_B19: reg_rdata <=  FifoOut[19]; 
*/     
                     
//-------------------------------------------------------------            
            //TEST_1F0: reg_rdata <= test_reg1F0;
            //TEST_1F1: reg_rdata <= 128'h00112233445566778899aabbccddeeff;	    
//-------------------------------------------------------------            
            default     : reg_rdata <= 128'd0;
        endcase
end

wire reg_rd_pulse;
reg reg_rd_d1;

always @ (posedge clk or negedge rst_n)
begin
if (!rst_n)
    reg_rd_d1<='h0;
else 
   reg_rd_d1<=reg_rd; 
end 

assign reg_rd_pulse = reg_rd & reg_rd_d1;

reg 	[(CORE_NUM-1):0] 		 RdFifoHit;

always @(*)
begin
		RdFifoHit[00] <= (reg_rd_pulse & (reg_addr==DMABUFF_B00)); 
/*		
		RdFifoHit[01] <= (reg_rd_pulse & (reg_addr==DMABUFF_B01));
		RdFifoHit[02] <= (reg_rd_pulse & (reg_addr==DMABUFF_B02));
		RdFifoHit[03] <= (reg_rd_pulse & (reg_addr==DMABUFF_B03));
		RdFifoHit[04] <= (reg_rd_pulse & (reg_addr==DMABUFF_B04));
		RdFifoHit[05] <= (reg_rd_pulse & (reg_addr==DMABUFF_B05));
		RdFifoHit[06] <= (reg_rd_pulse & (reg_addr==DMABUFF_B06));
		RdFifoHit[07] <= (reg_rd_pulse & (reg_addr==DMABUFF_B07));
		RdFifoHit[08] <= (reg_rd_pulse & (reg_addr==DMABUFF_B08));
		RdFifoHit[09] <= (reg_rd_pulse & (reg_addr==DMABUFF_B09));
		RdFifoHit[10] <= (reg_rd_pulse & (reg_addr==DMABUFF_B10));
		RdFifoHit[11] <= (reg_rd_pulse & (reg_addr==DMABUFF_B11));
		RdFifoHit[12] <= (reg_rd_pulse & (reg_addr==DMABUFF_B12));
		RdFifoHit[13] <= (reg_rd_pulse & (reg_addr==DMABUFF_B13));
		RdFifoHit[14] <= (reg_rd_pulse & (reg_addr==DMABUFF_B14));
		RdFifoHit[15] <= (reg_rd_pulse & (reg_addr==DMABUFF_B15));
		RdFifoHit[16] <= (reg_rd_pulse & (reg_addr==DMABUFF_B16));
		RdFifoHit[17] <= (reg_rd_pulse & (reg_addr==DMABUFF_B17));
		RdFifoHit[18] <= (reg_rd_pulse & (reg_addr==DMABUFF_B18));
		RdFifoHit[19] <= (reg_rd_pulse & (reg_addr==DMABUFF_B19));
*/		
end

//==================================================================
//---------------------------------------------------------------
 //---- for reg axi Rd-end invalid share debug here ---------------
reg [31:0] golden_regRd[0:3] = {32'h50918763,32'hb62b496e,32'hcc1a9b4d,32'hd9cb5952};
 
wire regAxiRd_hitAll_tmp, regAxiRd_hit0_tmp, regAxiRd_hit1_tmp, regAxiRd_hit2_tmp, regAxiRd_hit3_tmp;
reg regAxiRd_hitAll, regAxiRd_hit0, regAxiRd_hit1, regAxiRd_hit2, regAxiRd_hit3;

assign  regAxiRd_hitAll_tmp		= regAxiRd_hit0_tmp| regAxiRd_hit1_tmp|regAxiRd_hit2_tmp|regAxiRd_hit3_tmp;
assign  regAxiRd_hit0_tmp		= (reg_rdata[31:0]==golden_regRd[0]);
assign  regAxiRd_hit1_tmp		= (reg_rdata[31:0]==golden_regRd[1]);
assign 	regAxiRd_hit2_tmp		= (reg_rdata[31:0]==golden_regRd[2]);
assign 	regAxiRd_hit3_tmp		= (reg_rdata[31:0]==golden_regRd[3]);
 
reg got_invalid_regRd;

 
 always @(posedge clk)
 begin 
	if (~rst_n)
	begin	
	
		regAxiRd_hit0<=0;
		regAxiRd_hit1<=0;
		regAxiRd_hit2<=0;
		regAxiRd_hit3<=0;
		
		got_invalid_regRd<=0;
		
	end
	else
	begin
	
		regAxiRd_hit0 <= (RdFifoHit[00] & regAxiRd_hit0_tmp);
		regAxiRd_hit1 <= (RdFifoHit[00] & regAxiRd_hit1_tmp);
		regAxiRd_hit2 <= (RdFifoHit[00] & regAxiRd_hit2_tmp);
		regAxiRd_hit3 <= (RdFifoHit[00] & regAxiRd_hit3_tmp);
		
		got_invalid_regRd<= (RdFifoHit[00] & ~regAxiRd_hitAll_tmp);		
	end
end	 

endmodule    
