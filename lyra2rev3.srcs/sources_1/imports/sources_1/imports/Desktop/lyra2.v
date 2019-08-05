`timescale 1ns / 1ps
module lyra2(
	input clk,
	
	input [255:0] data,
	output [255:0] hash
);
integer j;
reg [1023:0] state_init = {64'h5be0cd19137e2179, 64'h1f83d9abfb41bd6b, 
									64'h9b05688c2b3e6c1f, 64'h510e527fade682d1,
									64'ha54ff53a5f1d36f1, 64'h3c6ef372fe94f82b,
									64'hbb67ae8584caa73b, 64'h6a09e667f3bcc908,
									64'h0, 64'h0, 64'h0, 64'h0, 
									64'h0, 64'h0, 64'h0, 64'h0};
wire [1023:0] data_tmp = {64'h100000000000000, 64'h80, 64'h4, 64'h4, 64'h1, 64'h20, 64'h20, 64'h20, data, data};

wire [1023:0] state_0, state_1, state_2, state_3, state_4, state_5, state_6, state_7, state_8, state_9, state_10;
//////////////////////
absorbBlockBlake2Safe absorbBlockBlake2Safe_inst0(clk, state_init, data_tmp[511:0], state_0);

//////////////////////
absorbBlockBlake2Safe absorbBlockBlake2Safe_inst1(clk, state_0, data_tmp[1023:512], state_1);
//////////////////////
wire [64*12*4-1:0] s0_memMatrix_0;
reducedSqueezeRow0 reducedSqueezeRow0_inst(clk, state_1, s0_memMatrix_0, state_2);

//////////////////////
wire [64*12*4-1:0] s1_memMatrix_0, s1_memMatrix_1;
reducedDuplexRow1 reducedDuplexRow1_inst(clk, state_2, s0_memMatrix_0, state_3, s1_memMatrix_0, s1_memMatrix_1);

//////////////////////
wire [64*12*4-1:0] s2_memMatrix_0, s2_memMatrix_1, s2_memMatrix_2;
reducedDuplexRowSetup reducedDuplexRowSetup_inst0(clk, state_3, s1_memMatrix_1, s1_memMatrix_0,	
																	   state_4, s2_memMatrix_0, s2_memMatrix_2, s2_memMatrix_1);	
			
			
//////////////////////			
wire [64*12*4-1:0] s3_memMatrix_0, s3_memMatrix_1, s3_memMatrix_2, s3_memMatrix_3;								
reducedDuplexRowSetup reducedDuplexRowSetup_inst1(clk, state_4, s2_memMatrix_2, s2_memMatrix_1,	
																	   state_5, s3_memMatrix_1, s3_memMatrix_3, s3_memMatrix_2);	

localparam D2 = 16;
reg [64*12*4-1:0] s2_memMatrix_0_reg[0:D2];
always @(posedge clk)
begin
	s2_memMatrix_0_reg[0] <= s2_memMatrix_0;
	for (j = 0; j < D2; j = j + 1)
		s2_memMatrix_0_reg[j+1] <= s2_memMatrix_0_reg[j];
end			
assign s3_memMatrix_0 = s2_memMatrix_0_reg[D2];
///////////////////////
wire [64*12*4-1:0] memMatrix[0:4][0:3];
assign memMatrix[0][0] = s3_memMatrix_0;
assign memMatrix[0][1] = s3_memMatrix_1;
assign memMatrix[0][2] = s3_memMatrix_2;
assign memMatrix[0][3] = s3_memMatrix_3;

wire [63:0] instance_0;
wire [1:0] rowa_0;

reducedDuplexRow_extend_0 reducedDuplexRow_extend_inst0(clk, state_5, 64'h0, memMatrix[0][0], memMatrix[0][1], memMatrix[0][2], memMatrix[0][3],
																	   state_6, instance_0, rowa_0, memMatrix[1][0], memMatrix[1][1], memMatrix[1][2], memMatrix[1][3]);
///////////////////////
wire [63:0] instance_1;
wire [1:0] rowa_1;

reducedDuplexRow_extend_1 reducedDuplexRow_extend_inst1(clk, state_6, instance_0, memMatrix[1][0], memMatrix[1][1], memMatrix[1][2], memMatrix[1][3],
																	   state_7, instance_1, rowa_1, memMatrix[2][0], memMatrix[2][1], memMatrix[2][2], memMatrix[2][3]);
///////////////////////
wire [63:0] instance_2;
wire [1:0] rowa_2;

reducedDuplexRow_extend_2 reducedDuplexRow_extend_inst2(clk, state_7, instance_1, memMatrix[2][0], memMatrix[2][1], memMatrix[2][2], memMatrix[2][3],
																	   state_8, instance_2, rowa_2, memMatrix[3][0], memMatrix[3][1], memMatrix[3][2], memMatrix[3][3]);
///////////////////////
wire [63:0] instance_3;
wire [1:0] rowa_3;

reducedDuplexRow_extend_3 reducedDuplexRow_extend_inst3(clk, state_8, instance_2, memMatrix[3][0], memMatrix[3][1], memMatrix[3][2], memMatrix[3][3],
																	   state_9, instance_3, rowa_3, memMatrix[4][0], memMatrix[4][1], memMatrix[4][2], memMatrix[4][3]);
///////////////////////
absorb absorb_inst(clk, state_9, memMatrix[4][rowa_3][64*12-1:0], state_10);
///////////////////////
assign hash = state_10[255:0];
endmodule
//////////////////////////////////////////
module g_op(clk, vai, vbi, vci, vdi,
vao,vbo,vco,vdo
);
input clk;
input [63:0] vai, vbi, vci, vdi;
output [63:0] vao, vbo, vco, vdo;

reg [63:0] va[0:3], vb[0:3], vc[0:3], vd[0:3];
wire [63:0] tmp[0:3];

assign tmp[0] = vai + vbi;
always @ (*)
begin
   va[0] = vai + vbi;
	vb[0] = vbi;
	vc[0] = vci;
   vd[0] = (((vdi ^ tmp[0])>>(32))|((vdi ^ tmp[0])<<(64-32)));     
end

assign tmp[1] = vc[0] +  vd[0];   
always @ (posedge clk)
begin
	va[1] <= va[0];
   vc[1] <= vc[0] +  vd[0];   
   vb[1] <= (((vb[0] ^ tmp[1])>>(24))|((vb[0] ^ tmp[1])<<(64-24)));
	vd[1] <= vd[0];
end

assign tmp[2] = va[1] + vb[1];
always @ (*)
begin
   va[2] = va[1] + vb[1];
	vb[2] = vb[1];
	vc[2] = vc[1];
   vd[2] = (((vd[1] ^ tmp[2])>>(16))|((vd[1] ^ tmp[2])<<(64-16)));
end

assign tmp[3] = vc[2] + vd[2];
always @ (posedge clk)
begin
	va[3] <= va[2];
   vc[3] <= vc[2] + vd[2];
   vb[3] <= (((vb[2] ^ tmp[3])>>(63))|((vb[2] ^ tmp[3])<<(64-63)));
	vd[3] <= vd[2];
end

assign vao = va[3];
assign vbo = vb[3];
assign vco = vc[3];
assign vdo = vd[3];
endmodule
//////////////////////////////////////////
module round_lyra(clk, v_in, v_out);
input clk;
input [1023:0] v_in;
output [1023:0] v_out;

wire[63:0] va_in [15:0];
wire[63:0] va_m[15:0];
wire[63:0] va_out[15:0];

genvar i;

generate 
for (i = 0; i < 16; i = i + 1)
	begin
		assign va_in[i] = v_in[64*(i+1)-1:64*i];
		assign v_out[64*(i+1)-1:64*i] = va_out[i];
	end
endgenerate
  
g_op g0(clk, va_in[ 0], va_in[ 4], va_in[ 8], va_in[12],
		  va_m[ 0], va_m[ 4], va_m[ 8], va_m[12]);
		
g_op g1(clk, va_in[ 1],  va_in[ 5],  va_in[ 9],  va_in[13],
		  va_m[ 1], va_m[ 5], va_m[ 9], va_m[13]);
		
g_op g2(clk, va_in[ 2],  va_in[ 6],  va_in[10],  va_in[14],
		  va_m[ 2], va_m[ 6], va_m[10], va_m[14]);
				  
g_op g3(clk, va_in[ 3],  va_in[ 7],  va_in[11],  va_in[15],
		  va_m[ 3], va_m[ 7], va_m[11], va_m[15]);
    
g_op g4(clk, va_m[ 0], va_m[ 5], va_m[10], va_m[15],
		  va_out[ 0], va_out[ 5], va_out[10], va_out[15]);
				  
g_op g5(clk, va_m[ 1], va_m[ 6], va_m[11], va_m[12],
		  va_out[ 1], va_out[ 6], va_out[11], va_out[12]);
							 
g_op g6(clk, va_m[ 2], va_m[ 7], va_m[ 8], va_m[13],
		  va_out[ 2], va_out[ 7], va_out[ 8], va_out[13]);
		 
g_op g7(clk, va_m[ 3], va_m[ 4], va_m[ 9], va_m[14],
		  va_out[ 3], va_out[ 4], va_out[ 9], va_out[14]);
endmodule
//////////////////////////////////////////
module blake2bLyra(clk, v_in, v_out);
input clk;
input [1023:0] v_in;
output [1023:0] v_out;

wire [1023:0] v_temp_in[0:11], v_temp_out[0:11];
    
assign v_temp_in[0] = v_in;
	 
genvar i;
generate 
	for (i = 0; i < 11; i = i + 1)
		begin
			assign v_temp_in[i+1] = v_temp_out[i];
		end
endgenerate

generate 
	for (i = 0; i < 12; i = i + 1)
		begin
			round_lyra round_lyra_inst(clk, v_temp_in[i], v_temp_out[i]);
		end
endgenerate

assign v_out = v_temp_out[11];

endmodule
//////////////////////////////////////////
module absorbBlockBlake2Safe(
	input clk, 
	input [1023:0] state, 
	input [511:0] msg, 
	output [1023:0] state_out
);
reg [1023:0] state_tmp;

always @(posedge clk)
begin
	state_tmp[511:0] <= msg ^ state[511:0];
	state_tmp[1023:512] <= state[1023:512];
end
    
blake2bLyra blake2bLyra_inst(clk, state_tmp, state_out);
endmodule
//////////////////////////////////////////
module reducedSqueezeRow0(
	input clk, 
	input [1023:0] state_i, 
	output reg [64*12*4-1:0] memMatrix,
	output reg [1023:0] state_o
);
integer j;
wire [1023:0] v_temp_in[0:3], v_temp_out[0:3];
    
assign v_temp_in[0] = state_i;
genvar i;
generate 
	for (i = 0; i < 3; i = i + 1)
		begin
			assign v_temp_in[i+1] = v_temp_out[i];
		end
endgenerate
  
round_lyra round_lyra_inst0(clk, v_temp_in[0], v_temp_out[0]);
round_lyra round_lyra_inst1(clk, v_temp_in[1], v_temp_out[1]);
round_lyra round_lyra_inst2(clk, v_temp_in[2], v_temp_out[2]);
round_lyra round_lyra_inst3(clk, v_temp_in[3], v_temp_out[3]);

localparam D1 = 15;
reg [1023:0] v_temp_in_0_reg[0:D1];
always @(posedge clk)
begin
	v_temp_in_0_reg[0] <= v_temp_in[0];
	for (j = 0; j < D1; j = j + 1)
		v_temp_in_0_reg[j+1] <= v_temp_in_0_reg[j];
end

localparam D2 = 11;
reg [1023:0] v_temp_in_1_reg[0:D2];
always @(posedge clk)
begin
	v_temp_in_1_reg[0] <= v_temp_in[1];
	for (j = 0; j < D2; j = j + 1)
		v_temp_in_1_reg[j+1] <= v_temp_in_1_reg[j];
end

localparam D3 = 7;
reg [1023:0] v_temp_in_2_reg[0:D3];
always @(posedge clk)
begin
	v_temp_in_2_reg[0] <= v_temp_in[2];
	for (j = 0; j < D3; j = j + 1)
		v_temp_in_2_reg[j+1] <= v_temp_in_2_reg[j];
end

localparam D4 = 3;
reg [1023:0] v_temp_in_3_reg[0:D4];
always @(posedge clk)
begin
	v_temp_in_3_reg[0] <= v_temp_in[3];
	for (j = 0; j < D4; j = j + 1)
		v_temp_in_3_reg[j+1] <= v_temp_in_3_reg[j];
end
always @(posedge clk)
begin
	memMatrix <= {v_temp_in_0_reg[D1][64*12-1:0], v_temp_in_1_reg[D2][64*12-1:0], v_temp_in_2_reg[D3][64*12-1:0], v_temp_in_3_reg[D4][64*12-1:0]};
	
	state_o <= v_temp_out[3];
end
endmodule
//////////////////////////////////////////
module reducedDuplexRow1(
	input clk, 
	input [1023:0] state_i, 
	input [64*12*4-1:0] memMatrix_i,
	output reg [1023:0] state_o,
	output reg [64*12*4-1:0] memMatrix_io,
	output reg [64*12*4-1:0] memMatrix_o
);
integer j;
wire [1023:0] v_temp_in[0:3], v_temp_out[0:3];
localparam D1 = 11;
reg [1023:0] v_temp_out_0_reg[0:D1];
always @(posedge clk)
begin
	v_temp_out_0_reg[0] <= v_temp_out[0];
	for (j = 0; j < D1; j = j + 1)
		v_temp_out_0_reg[j+1] <= v_temp_out_0_reg[j];
end

localparam D2 = 7;
reg [1023:0] v_temp_out_1_reg[0:D2];
always @(posedge clk)
begin
	v_temp_out_1_reg[0] <= v_temp_out[1];
	for (j = 0; j < D2; j = j + 1)
		v_temp_out_1_reg[j+1] <= v_temp_out_1_reg[j];
end

localparam D3 = 3;
reg [1023:0] v_temp_out_2_reg[0:D3];
always @(posedge clk)
begin
	v_temp_out_2_reg[0] <= v_temp_out[2];
	for (j = 0; j < D3; j = j + 1)
		v_temp_out_2_reg[j+1] <= v_temp_out_2_reg[j];
end

localparam D4 = 15;
reg [64*12*4-1:0] memMatrix_i_reg[0:D4];
always @(posedge clk)
begin
	memMatrix_i_reg[0] <= memMatrix_i;
	for (j = 0; j < D4; j = j + 1)
		memMatrix_i_reg[j+1] <= memMatrix_i_reg[j];
end


assign v_temp_in[0] = state_i ^ memMatrix_i[64*12-1:0];
assign v_temp_in[1] = v_temp_out[0] ^ memMatrix_i_reg[3][64*12*2-1:64*12*1];
assign v_temp_in[2] = v_temp_out[1] ^ memMatrix_i_reg[7][64*12*3-1:64*12*2];
assign v_temp_in[3] = v_temp_out[2] ^ memMatrix_i_reg[11][64*12*4-1:64*12*3];
	   
round_lyra round_lyra_inst0(clk, v_temp_in[0], v_temp_out[0]);
round_lyra round_lyra_inst1(clk, v_temp_in[1], v_temp_out[1]);
round_lyra round_lyra_inst2(clk, v_temp_in[2], v_temp_out[2]);
round_lyra round_lyra_inst3(clk, v_temp_in[3], v_temp_out[3]);

always @(posedge clk)
begin
	memMatrix_o <= {v_temp_out_0_reg[D1][64*12-1:0] ^ memMatrix_i_reg[D4][64*12-1:0], v_temp_out_1_reg[D2][64*12-1:0] ^ memMatrix_i_reg[D4][64*12*2-1:64*12*1], 
					    v_temp_out_2_reg[D3][64*12-1:0] ^ memMatrix_i_reg[D4][64*12*3-1:64*12*2], v_temp_out[3][64*12-1:0] ^ memMatrix_i_reg[D4][64*12*4-1:64*12*3]};
	state_o <= v_temp_out[3];
	memMatrix_io <= memMatrix_i_reg[D4];
end
endmodule
//////////////////////////////////////////
module reducedDuplexRowSetup(
	input clk, 
	input [1023:0] state_i, 
	input [64*12*4-1:0] memMatrix_i0,
	input [64*12*4-1:0] memMatrix_i1,
	output reg [1023:0] state_o,
	output reg [64*12*4-1:0] memMatrix_o0,
	output reg [64*12*4-1:0] memMatrix_o1,
	output reg [64*12*4-1:0] memMatrix_o2
);
genvar i;
integer j;

localparam D4 = 15;
reg [64*12*4-1:0] memMatrix_i0_reg[0:D4];
always @(posedge clk)
begin
	memMatrix_i0_reg[0] <= memMatrix_i0;
	for (j = 0; j < D4; j = j + 1)
		memMatrix_i0_reg[j+1] <= memMatrix_i0_reg[j];
end

reg [64*12*4-1:0] memMatrix_i1_reg[0:D4];
always @(posedge clk)
begin
	memMatrix_i1_reg[0] <= memMatrix_i1;
	for (j = 0; j < D4; j = j + 1)
		memMatrix_i1_reg[j+1] <= memMatrix_i1_reg[j];
end

wire [1023:0] v_temp_in[0:3], v_temp_out[0:3];
wire [63:0] sum_i0_i1_0[0:11];
generate 
	for (i = 0; i < 12; i = i + 1)
	begin
		assign sum_i0_i1_0[i] = memMatrix_i0[64*(i+1)-1:64*(i)] + memMatrix_i1[64*(i+1)-1:64*(i)];
	end
endgenerate

wire [63:0] sum_i0_i1_1[0:11];
generate 
	for (i = 0; i < 12; i = i + 1)
	begin
		assign sum_i0_i1_1[i] = memMatrix_i0_reg[3][64*(i+1+12)-1:64*(i+12)] + memMatrix_i1_reg[3][64*(i+1+12)-1:64*(i+12)];
	end
endgenerate

wire [63:0] sum_i0_i1_2[0:11];
generate 
	for (i = 0; i < 12; i = i + 1)
	begin
		assign sum_i0_i1_2[i] = memMatrix_i0_reg[7][64*(i+1+24)-1:64*(i+24)] + memMatrix_i1_reg[7][64*(i+1+24)-1:64*(i+24)];
	end
endgenerate

wire [63:0] sum_i0_i1_3[0:11];
generate 
	for (i = 0; i < 12; i = i + 1)
	begin
		assign sum_i0_i1_3[i] = memMatrix_i0_reg[11][64*(i+1+36)-1:64*(i+36)] + memMatrix_i1_reg[11][64*(i+1+36)-1:64*(i+36)];
	end
endgenerate

assign v_temp_in[0] = state_i ^ {sum_i0_i1_0[11], sum_i0_i1_0[10], sum_i0_i1_0[9], sum_i0_i1_0[8], 
											sum_i0_i1_0[7], sum_i0_i1_0[6], sum_i0_i1_0[5], sum_i0_i1_0[4], 
											sum_i0_i1_0[3], sum_i0_i1_0[2], sum_i0_i1_0[1], sum_i0_i1_0[0]};										
assign v_temp_in[1] = v_temp_out[0] ^ {sum_i0_i1_1[11], sum_i0_i1_1[10], sum_i0_i1_1[9], sum_i0_i1_1[8], 
												   sum_i0_i1_1[7], sum_i0_i1_1[6], sum_i0_i1_1[5], sum_i0_i1_1[4], 
												   sum_i0_i1_1[3], sum_i0_i1_1[2], sum_i0_i1_1[1], sum_i0_i1_1[0]};
assign v_temp_in[2] = v_temp_out[1] ^ {sum_i0_i1_2[11], sum_i0_i1_2[10], sum_i0_i1_2[9], sum_i0_i1_2[8], 
												   sum_i0_i1_2[7], sum_i0_i1_2[6], sum_i0_i1_2[5], sum_i0_i1_2[4], 
												   sum_i0_i1_2[3], sum_i0_i1_2[2], sum_i0_i1_2[1], sum_i0_i1_2[0]};
assign v_temp_in[3] = v_temp_out[2] ^ {sum_i0_i1_3[11], sum_i0_i1_3[10], sum_i0_i1_3[9], sum_i0_i1_3[8], 
												   sum_i0_i1_3[7], sum_i0_i1_3[6], sum_i0_i1_3[5], sum_i0_i1_3[4], 
												   sum_i0_i1_3[3], sum_i0_i1_3[2], sum_i0_i1_3[1], sum_i0_i1_3[0]};
  
round_lyra round_lyra_inst0(clk, v_temp_in[0], v_temp_out[0]);
round_lyra round_lyra_inst1(clk, v_temp_in[1], v_temp_out[1]);
round_lyra round_lyra_inst2(clk, v_temp_in[2], v_temp_out[2]);
round_lyra round_lyra_inst3(clk, v_temp_in[3], v_temp_out[3]);

localparam D1 = 11;
reg [1023:0] v_temp_out_0_reg[0:D1];
always @(posedge clk)
begin
	v_temp_out_0_reg[0] <= v_temp_out[0];
	for (j = 0; j < D1; j = j + 1)
		v_temp_out_0_reg[j+1] <= v_temp_out_0_reg[j];
end

localparam D2 = 7;
reg [1023:0] v_temp_out_1_reg[0:D2];
always @(posedge clk)
begin
	v_temp_out_1_reg[0] <= v_temp_out[1];
	for (j = 0; j < D2; j = j + 1)
		v_temp_out_1_reg[j+1] <= v_temp_out_1_reg[j];
end

localparam D3 = 3;
reg [1023:0] v_temp_out_2_reg[0:D3];
always @(posedge clk)
begin
	v_temp_out_2_reg[0] <= v_temp_out[2];
	for (j = 0; j < D3; j = j + 1)
		v_temp_out_2_reg[j+1] <= v_temp_out_2_reg[j];
end


always @(posedge clk)
begin
	memMatrix_o2 <= memMatrix_i0_reg[D4];
	
	memMatrix_o1 <= {v_temp_out_0_reg[D1][64*12-1:0] ^ memMatrix_i0_reg[D4][64*12-1:0], v_temp_out_1_reg[D2][64*12-1:0] ^ memMatrix_i0_reg[D4][64*12*2-1:64*12*1], 
					     v_temp_out_2_reg[D3][64*12-1:0] ^ memMatrix_i0_reg[D4][64*12*3-1:64*12*2], v_temp_out[3][64*12-1:0] ^ memMatrix_i0_reg[D4][64*12*4-1:64*12*3]};
						  
	memMatrix_o0 <= {{v_temp_out[3][64*11-1:0], v_temp_out[3][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12*4-1:64*12*3], {v_temp_out_2_reg[D3][64*11-1:0], v_temp_out_2_reg[D3][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12*3-1:64*12*2],
						  {v_temp_out_1_reg[D2][64*11-1:0], v_temp_out_1_reg[D2][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12*2-1:64*12*1], {v_temp_out_0_reg[D1][64*11-1:0], v_temp_out_0_reg[D1][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12-1:0]};
	
	state_o <= v_temp_out[3];
end
endmodule
//////////////////////////////////////////
module reducedDuplexRow(
	input clk, 
	input [1023:0] state_i, 
	input [64*12*4-1:0] memMatrix_i0,
	input [64*12*4-1:0] memMatrix_i1,
	input [64*12*4-1:0] memMatrix_i2,
	output reg [1023:0] state_o,
	output reg [64*12*4-1:0] memMatrix_o0,
	output reg [64*12*4-1:0] memMatrix_o1,
	output reg [64*12*4-1:0] memMatrix_o2
);
genvar i;
integer j;


localparam D4 = 15;
reg [64*12*4-1:0] memMatrix_i2_reg[0:D4];
always @(posedge clk)
begin
	memMatrix_i2_reg[0] <= memMatrix_i2;
	for (j = 0; j < D4; j = j + 1)
		memMatrix_i2_reg[j+1] <= memMatrix_i2_reg[j];
end

reg [64*12*4-1:0] memMatrix_i1_reg[0:D4];
always @(posedge clk)
begin
	memMatrix_i1_reg[0] <= memMatrix_i1;
	for (j = 0; j < D4; j = j + 1)
		memMatrix_i1_reg[j+1] <= memMatrix_i1_reg[j];
end

reg [64*12*4-1:0] memMatrix_i0_reg[0:D4];
always @(posedge clk)
begin
	memMatrix_i0_reg[0] <= memMatrix_i0;
	for (j = 0; j < D4; j = j + 1)
		memMatrix_i0_reg[j+1] <= memMatrix_i0_reg[j];
end

wire [1023:0] v_temp_in[0:3], v_temp_out[0:3];

wire [63:0] sum_i0_i1_0[0:11];
generate 
	for (i = 0; i < 12; i = i + 1)
	begin
		assign sum_i0_i1_0[i] = memMatrix_i0[64*(i+1)-1:64*(i)] + memMatrix_i1[64*(i+1)-1:64*(i)];
	end
endgenerate

wire [63:0] sum_i0_i1_1[0:11];
generate 
	for (i = 0; i < 12; i = i + 1)
	begin
		assign sum_i0_i1_1[i] = memMatrix_i0_reg[3][64*(i+1+12)-1:64*(i+12)] + memMatrix_i1_reg[3][64*(i+1+12)-1:64*(i+12)];
	end
endgenerate

wire [63:0] sum_i0_i1_2[0:11];
generate 
	for (i = 0; i < 12; i = i + 1)
	begin
		assign sum_i0_i1_2[i] = memMatrix_i0_reg[7][64*(i+1+24)-1:64*(i+24)] + memMatrix_i1_reg[7][64*(i+1+24)-1:64*(i+24)];
	end
endgenerate

wire [63:0] sum_i0_i1_3[0:11];
generate 
	for (i = 0; i < 12; i = i + 1)
    begin
		assign sum_i0_i1_3[i] = memMatrix_i0_reg[11][64*(i+1+36)-1:64*(i+36)] + memMatrix_i1_reg[11][64*(i+1+36)-1:64*(i+36)];
	end
endgenerate

assign v_temp_in[0] = state_i ^ {sum_i0_i1_0[11], sum_i0_i1_0[10], sum_i0_i1_0[9], sum_i0_i1_0[8], 
											sum_i0_i1_0[7], sum_i0_i1_0[6], sum_i0_i1_0[5], sum_i0_i1_0[4], 
											sum_i0_i1_0[3], sum_i0_i1_0[2], sum_i0_i1_0[1], sum_i0_i1_0[0]};										
assign v_temp_in[1] = v_temp_out[0] ^ {sum_i0_i1_1[11], sum_i0_i1_1[10], sum_i0_i1_1[9], sum_i0_i1_1[8], 
												   sum_i0_i1_1[7], sum_i0_i1_1[6], sum_i0_i1_1[5], sum_i0_i1_1[4], 
												   sum_i0_i1_1[3], sum_i0_i1_1[2], sum_i0_i1_1[1], sum_i0_i1_1[0]};
assign v_temp_in[2] = v_temp_out[1] ^ {sum_i0_i1_2[11], sum_i0_i1_2[10], sum_i0_i1_2[9], sum_i0_i1_2[8], 
												   sum_i0_i1_2[7], sum_i0_i1_2[6], sum_i0_i1_2[5], sum_i0_i1_2[4], 
												   sum_i0_i1_2[3], sum_i0_i1_2[2], sum_i0_i1_2[1], sum_i0_i1_2[0]};
assign v_temp_in[3] = v_temp_out[2] ^ {sum_i0_i1_3[11], sum_i0_i1_3[10], sum_i0_i1_3[9], sum_i0_i1_3[8], 
												   sum_i0_i1_3[7], sum_i0_i1_3[6], sum_i0_i1_3[5], sum_i0_i1_3[4], 
												   sum_i0_i1_3[3], sum_i0_i1_3[2], sum_i0_i1_3[1], sum_i0_i1_3[0]};
  
round_lyra round_lyra_inst0(clk, v_temp_in[0], v_temp_out[0]);
round_lyra round_lyra_inst1(clk, v_temp_in[1], v_temp_out[1]);
round_lyra round_lyra_inst2(clk, v_temp_in[2], v_temp_out[2]);
round_lyra round_lyra_inst3(clk, v_temp_in[3], v_temp_out[3]);

localparam D1 = 11;
reg [1023:0] v_temp_out_0_reg[0:D1];
always @(posedge clk)
begin
	v_temp_out_0_reg[0] <= v_temp_out[0];
	for (j = 0; j < D1; j = j + 1)
		v_temp_out_0_reg[j+1] <= v_temp_out_0_reg[j];
end

localparam D2 = 7;
reg [1023:0] v_temp_out_1_reg[0:D2];
always @(posedge clk)
begin
	v_temp_out_1_reg[0] <= v_temp_out[1];
	for (j = 0; j < D2; j = j + 1)
		v_temp_out_1_reg[j+1] <= v_temp_out_1_reg[j];
end

localparam D3 = 3;
reg [1023:0] v_temp_out_2_reg[0:D3];
always @(posedge clk)
begin
	v_temp_out_2_reg[0] <= v_temp_out[2];
	for (j = 0; j < D3; j = j + 1)
		v_temp_out_2_reg[j+1] <= v_temp_out_2_reg[j];
end

always @(posedge clk)
begin
	memMatrix_o2 <= {v_temp_out[3][64*12-1:0] ^ {v_temp_out[3][64*11-1:0], v_temp_out[3][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12*4-1:64*12*3], v_temp_out_2_reg[D3][64*12-1:0] ^ {v_temp_out_2_reg[D3][64*11-1:0], v_temp_out_2_reg[D3][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12*3-1:64*12*2],
						  v_temp_out_1_reg[D2][64*12-1:0] ^ {v_temp_out_1_reg[D2][64*11-1:0], v_temp_out_1_reg[D2][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12*2-1:64*12*1], v_temp_out_0_reg[D1][64*12-1:0] ^ {v_temp_out_0_reg[D1][64*11-1:0], v_temp_out_0_reg[D1][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12-1:0]};
						  
	memMatrix_o1 <= {v_temp_out[3][64*12-1:0] ^ memMatrix_i2_reg[D4][64*12*4-1:64*12*3], v_temp_out_2_reg[D3][64*12-1:0] ^ memMatrix_i2_reg[D4][64*12*3-1:64*12*2],
						  v_temp_out_1_reg[D2][64*12-1:0] ^ memMatrix_i2_reg[D4][64*12*2-1:64*12*1], v_temp_out_0_reg[D1][64*12-1:0] ^ memMatrix_i2_reg[D4][64*12-1:0]};
						  
	memMatrix_o0 <= {{v_temp_out[3][64*11-1:0], v_temp_out[3][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12*4-1:64*12*3], {v_temp_out_2_reg[D3][64*11-1:0], v_temp_out_2_reg[D3][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12*3-1:64*12*2],
						  {v_temp_out_1_reg[D2][64*11-1:0], v_temp_out_1_reg[D2][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12*2-1:64*12*1], {v_temp_out_0_reg[D1][64*11-1:0], v_temp_out_0_reg[D1][64*12-1:64*11]} ^ memMatrix_i1_reg[D4][64*12-1:0]};
						  
	state_o <= v_temp_out[3];
end
endmodule
//////////////////////////////////////////
module absorb(
	input clk, 
	input [1023:0] state, 
	input [64*12-1:0] msg, 
	output [1023:0] state_out
);
reg [1023:0] state_tmp;

always @(posedge clk)
begin
	state_tmp <= state ^ msg;
end
    
blake2bLyra blake2bLyra_inst(clk, state_tmp, state_out);
endmodule
//////////////////////////////////////////
module rowa_selection(
	input [1023:0] state, 
	input [63:0] instance_in, 
	output [1:0] rowa,
	output [63:0] instance_out
);
genvar i;
wire [63:0] ST[0:15];

generate
for (i = 0; i < 16; i = i + 1)
    begin
	   assign ST[i] = state[64*(i+1)-1:64*i];
	end
endgenerate
    
assign instance_out = ST[instance_in[3:0]];
assign rowa = ST[instance_out[3:0]] & 2'b11;
endmodule
//////////////////////////////////////////
module reducedDuplexRow_extend_0(
	input clk, 
	input [1023:0] state_i, 
	input [63:0] instance_i,
	input [64*12*4-1:0] memMatrix_i0,
	input [64*12*4-1:0] memMatrix_i1,
	input [64*12*4-1:0] memMatrix_i2,
	input [64*12*4-1:0] memMatrix_i3,
	output [1023:0] state_o,
	output [63:0] instance_o,
	output [1:0] rowa, 
	output [64*12*4-1:0] memMatrix_o0,
	output [64*12*4-1:0] memMatrix_o1,
	output [64*12*4-1:0] memMatrix_o2,
	output [64*12*4-1:0] memMatrix_o3
);
integer j;
wire [63:0] instance_temp;
wire [1:0] rowa_temp;
rowa_selection rowa_selection_inst0(state_i, instance_i, rowa_temp, instance_temp);											
reg [64*12*4-1:0] memMatrix_i;

localparam D = 17;
reg [1:0] rowa_reg[0:D];
reg [63:0] instance_reg[0:D];
reg [64*12*4-1:0] memMatrix_i0_reg[0:D], memMatrix_i1_reg[0:D], memMatrix_i2_reg[0:D], memMatrix_i3_reg[0:D];
reg [1023:0] state_i_reg;

always @(posedge clk)
begin
	memMatrix_i <= (rowa_temp == 0) ? memMatrix_i0 :
					  (rowa_temp == 1) ? memMatrix_i1 :
					  (rowa_temp == 2) ? memMatrix_i2 : memMatrix_i3;
end

wire [64*12*4-1:0] memMatrix_temp[0:2];

reducedDuplexRow reducedDuplexRow_inst(clk, state_i_reg, memMatrix_i3_reg[0], memMatrix_i, memMatrix_i0_reg[0],
														  state_o, memMatrix_temp[0], memMatrix_temp[1], memMatrix_temp[2]);	
				

always @(posedge clk)
begin
	state_i_reg <= state_i;
	rowa_reg[0] <= rowa_temp;
	instance_reg[0] <= instance_temp;
	memMatrix_i0_reg[0] <= memMatrix_i0;
	memMatrix_i1_reg[0] <= memMatrix_i1;
	memMatrix_i2_reg[0] <= memMatrix_i2;
	memMatrix_i3_reg[0] <= memMatrix_i3;
	for (j = 0; j < D; j = j + 1)
		begin
			rowa_reg[j+1] <= rowa_reg[j];
			instance_reg[j+1] <= instance_reg[j];
			memMatrix_i0_reg[j+1] <= memMatrix_i0_reg[j];
			memMatrix_i1_reg[j+1] <= memMatrix_i1_reg[j];
			memMatrix_i2_reg[j+1] <= memMatrix_i2_reg[j];
			memMatrix_i3_reg[j+1] <= memMatrix_i3_reg[j];
		end
end
				
assign rowa = rowa_reg[D];
assign instance_o = instance_reg[D];

assign memMatrix_o0 = (rowa == 0) ? memMatrix_temp[2] : memMatrix_temp[1];
assign memMatrix_o1 = (rowa == 1) ? memMatrix_temp[0] : memMatrix_i1_reg[D];
assign memMatrix_o2 = (rowa == 2) ? memMatrix_temp[0] : memMatrix_i2_reg[D];
assign memMatrix_o3 = (rowa == 3) ? memMatrix_temp[0] : memMatrix_i3_reg[D];
endmodule
//////////////////////////////////////////
module reducedDuplexRow_extend_1(
	input clk, 
	input [1023:0] state_i, 
	input [63:0] instance_i,
	input [64*12*4-1:0] memMatrix_i0,
	input [64*12*4-1:0] memMatrix_i1,
	input [64*12*4-1:0] memMatrix_i2,
	input [64*12*4-1:0] memMatrix_i3,
	output [1023:0] state_o,
	output [63:0] instance_o,
	output [1:0] rowa, 
	output [64*12*4-1:0] memMatrix_o0,
	output [64*12*4-1:0] memMatrix_o1,
	output [64*12*4-1:0] memMatrix_o2,
	output [64*12*4-1:0] memMatrix_o3
);
integer j;
wire [63:0] instance_temp;
wire [1:0] rowa_temp;
rowa_selection rowa_selection_inst0(state_i, instance_i, rowa_temp, instance_temp);
reg [64*12*4-1:0] memMatrix_i;

localparam D = 17;
reg [1:0] rowa_reg[0:D];
reg [63:0] instance_reg[0:D];
reg [64*12*4-1:0] memMatrix_i0_reg[0:D], memMatrix_i1_reg[0:D], memMatrix_i2_reg[0:D], memMatrix_i3_reg[0:D];
reg [1023:0] state_i_reg;

always @(posedge clk)
begin
	memMatrix_i <= (rowa_temp == 0) ? memMatrix_i0 :
					  (rowa_temp == 1) ? memMatrix_i1 :
					  (rowa_temp == 2) ? memMatrix_i2 : memMatrix_i3;
end

wire [64*12*4-1:0] memMatrix_temp[0:2];

reducedDuplexRow reducedDuplexRow_inst(clk, state_i_reg, memMatrix_i0_reg[0], memMatrix_i, memMatrix_i1_reg[0],
														  state_o, memMatrix_temp[0], memMatrix_temp[1], memMatrix_temp[2]);	
				

always @(posedge clk)
begin
	state_i_reg <= state_i;
	rowa_reg[0] <= rowa_temp;
	instance_reg[0] <= instance_temp;
	memMatrix_i0_reg[0] <= memMatrix_i0;
	memMatrix_i1_reg[0] <= memMatrix_i1;
	memMatrix_i2_reg[0] <= memMatrix_i2;
	memMatrix_i3_reg[0] <= memMatrix_i3;
	for (j = 0; j < D; j = j + 1)
		begin
			rowa_reg[j+1] <= rowa_reg[j];
			instance_reg[j+1] <= instance_reg[j];
			memMatrix_i0_reg[j+1] <= memMatrix_i0_reg[j];
			memMatrix_i1_reg[j+1] <= memMatrix_i1_reg[j];
			memMatrix_i2_reg[j+1] <= memMatrix_i2_reg[j];
			memMatrix_i3_reg[j+1] <= memMatrix_i3_reg[j];
		end
end
				
assign rowa = rowa_reg[D];
assign instance_o = instance_reg[D];

assign memMatrix_o0 = (rowa == 0) ? memMatrix_temp[0] : memMatrix_i0_reg[D];
assign memMatrix_o1 = (rowa == 1) ? memMatrix_temp[2] : memMatrix_temp[1];
assign memMatrix_o2 = (rowa == 2) ? memMatrix_temp[0] : memMatrix_i2_reg[D];
assign memMatrix_o3 = (rowa == 3) ? memMatrix_temp[0] : memMatrix_i3_reg[D];
endmodule
//////////////////////////////////////////
module reducedDuplexRow_extend_2(
	input clk, 
	input [1023:0] state_i, 
	input [63:0] instance_i,
	input [64*12*4-1:0] memMatrix_i0,
	input [64*12*4-1:0] memMatrix_i1,
	input [64*12*4-1:0] memMatrix_i2,
	input [64*12*4-1:0] memMatrix_i3,
	output [1023:0] state_o,
	output [63:0] instance_o,
	output [1:0] rowa, 
	output [64*12*4-1:0] memMatrix_o0,
	output [64*12*4-1:0] memMatrix_o1,
	output [64*12*4-1:0] memMatrix_o2,
	output [64*12*4-1:0] memMatrix_o3
);
integer j;
wire [63:0] instance_temp;
wire [1:0] rowa_temp;
rowa_selection rowa_selection_inst0(state_i, instance_i, rowa_temp, instance_temp);
reg [64*12*4-1:0] memMatrix_i;

localparam D = 17;
reg [1:0] rowa_reg[0:D];
reg [63:0] instance_reg[0:D];
reg [64*12*4-1:0] memMatrix_i0_reg[0:D], memMatrix_i1_reg[0:D], memMatrix_i2_reg[0:D], memMatrix_i3_reg[0:D];
reg [1023:0] state_i_reg;

always @(posedge clk)
begin
	memMatrix_i <= (rowa_temp == 0) ? memMatrix_i0 :
					  (rowa_temp == 1) ? memMatrix_i1 :
					  (rowa_temp == 2) ? memMatrix_i2 : memMatrix_i3;
end

wire [64*12*4-1:0] memMatrix_temp[0:2];

reducedDuplexRow reducedDuplexRow_inst(clk, state_i_reg, memMatrix_i1_reg[0], memMatrix_i, memMatrix_i2_reg[0],
														  state_o, memMatrix_temp[0], memMatrix_temp[1], memMatrix_temp[2]);	
				

always @(posedge clk)
begin
	state_i_reg <= state_i;
	rowa_reg[0] <= rowa_temp;
	instance_reg[0] <= instance_temp;
	memMatrix_i0_reg[0] <= memMatrix_i0;
	memMatrix_i1_reg[0] <= memMatrix_i1;
	memMatrix_i2_reg[0] <= memMatrix_i2;
	memMatrix_i3_reg[0] <= memMatrix_i3;
	for (j = 0; j < D; j = j + 1)
		begin
			rowa_reg[j+1] <= rowa_reg[j];
			instance_reg[j+1] <= instance_reg[j];
			memMatrix_i0_reg[j+1] <= memMatrix_i0_reg[j];
			memMatrix_i1_reg[j+1] <= memMatrix_i1_reg[j];
			memMatrix_i2_reg[j+1] <= memMatrix_i2_reg[j];
			memMatrix_i3_reg[j+1] <= memMatrix_i3_reg[j];
		end
end
				
assign rowa = rowa_reg[D];
assign instance_o = instance_reg[D];

assign memMatrix_o0 = (rowa == 0) ? memMatrix_temp[0] : memMatrix_i0_reg[D];
assign memMatrix_o1 = (rowa == 1) ? memMatrix_temp[0] : memMatrix_i1_reg[D];
assign memMatrix_o2 = (rowa == 2) ? memMatrix_temp[2] : memMatrix_temp[1];
assign memMatrix_o3 = (rowa == 3) ? memMatrix_temp[0] : memMatrix_i3_reg[D];
endmodule
//////////////////////////////////////////
module reducedDuplexRow_extend_3(
	input clk, 
	input [1023:0] state_i, 
	input [63:0] instance_i,
	input [64*12*4-1:0] memMatrix_i0,
	input [64*12*4-1:0] memMatrix_i1,
	input [64*12*4-1:0] memMatrix_i2,
	input [64*12*4-1:0] memMatrix_i3,
	output [1023:0] state_o,
	output [63:0] instance_o,
	output [1:0] rowa, 
	output [64*12*4-1:0] memMatrix_o0,
	output [64*12*4-1:0] memMatrix_o1,
	output [64*12*4-1:0] memMatrix_o2,
	output [64*12*4-1:0] memMatrix_o3
);
integer j;
wire [63:0] instance_temp;
wire [1:0] rowa_temp;
rowa_selection rowa_selection_inst0(state_i, instance_i, rowa_temp, instance_temp);

localparam D = 17;
reg [1:0] rowa_reg[0:D];
reg [63:0] instance_reg[0:D];
reg [64*12*4-1:0] memMatrix_i0_reg[0:D], memMatrix_i1_reg[0:D], memMatrix_i2_reg[0:D], memMatrix_i3_reg[0:D];
reg [1023:0] state_i_reg;

reg [64*12*4-1:0] memMatrix_i;

always @(posedge clk)
begin
	memMatrix_i <= (rowa_temp == 0) ? memMatrix_i0 :
					  (rowa_temp == 1) ? memMatrix_i1 :
					  (rowa_temp == 2) ? memMatrix_i2 : memMatrix_i3;
end

wire [64*12*4-1:0] memMatrix_temp[0:2];

reducedDuplexRow reducedDuplexRow_inst(clk, state_i_reg, memMatrix_i2_reg[0], memMatrix_i, memMatrix_i3_reg[0],
														  state_o, memMatrix_temp[0], memMatrix_temp[1], memMatrix_temp[2]);	
				

always @(posedge clk)
begin
	state_i_reg <= state_i;
	rowa_reg[0] <= rowa_temp;
	instance_reg[0] <= instance_temp;
	memMatrix_i0_reg[0] <= memMatrix_i0;
	memMatrix_i1_reg[0] <= memMatrix_i1;
	memMatrix_i2_reg[0] <= memMatrix_i2;
	memMatrix_i3_reg[0] <= memMatrix_i3;
	for (j = 0; j < D; j = j + 1)
		begin
			rowa_reg[j+1] <= rowa_reg[j];
			instance_reg[j+1] <= instance_reg[j];
			memMatrix_i0_reg[j+1] <= memMatrix_i0_reg[j];
			memMatrix_i1_reg[j+1] <= memMatrix_i1_reg[j];
			memMatrix_i2_reg[j+1] <= memMatrix_i2_reg[j];
			memMatrix_i3_reg[j+1] <= memMatrix_i3_reg[j];
		end
end
				
assign rowa = rowa_reg[D];
assign instance_o = instance_reg[D];

assign memMatrix_o0 = (rowa == 0) ? memMatrix_temp[0] : memMatrix_i0_reg[D];
assign memMatrix_o1 = (rowa == 1) ? memMatrix_temp[0] : memMatrix_i1_reg[D];
assign memMatrix_o2 = (rowa == 2) ? memMatrix_temp[0] : memMatrix_i2_reg[D];
assign memMatrix_o3 = (rowa == 3) ? memMatrix_temp[2] : memMatrix_temp[1];
endmodule