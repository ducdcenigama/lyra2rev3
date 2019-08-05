module bmw(
	input clk,
		
	input [32*8-1:0] m,
	output reg [32*8-1:0] m_o
);
/////////////////////
parameter DATA_WIDTH = 32;
parameter MESS_ARRAY_SIZE = 16;
parameter STATE_ARRAY_SIZE = 16;
/////////////////////
genvar i, k;
wire [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] h, h_f;
reg [DATA_WIDTH-1:0] H[0:STATE_ARRAY_SIZE-1], H_F[0:STATE_ARRAY_SIZE-1];
generate
for (i = 0; i < STATE_ARRAY_SIZE; i = i + 1) begin 
	 assign h[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] = H[i]; 
	 assign h_f[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] = H_F[i]; 
end
endgenerate

initial
begin
	H[0] = 32'h40414243;
	H[1] = 32'h44454647;
	H[2] = 32'h48494a4b;
	H[3] = 32'h4c4d4e4f;
	H[4] = 32'h50515253;
	H[5] = 32'h54555657;
	H[6] = 32'h58595a5b;
	H[7] = 32'h5c5d5e5f;
	H[8] = 32'h60616263;
	H[9] = 32'h64656667;
	H[10] = 32'h68696a6b;
	H[11] = 32'h6c6d6e6f;
	H[12] = 32'h70717273;
	H[13] = 32'h74757677;
	H[14] = 32'h78797a7b;
	H[15] = 32'h7c7d7e7f;
	
	H_F[0] = 32'haaaaaaa0;
	H_F[1] = 32'haaaaaaa1;
	H_F[2] = 32'haaaaaaa2;
	H_F[3] = 32'haaaaaaa3;
	H_F[4] = 32'haaaaaaa4;
	H_F[5] = 32'haaaaaaa5;
	H_F[6] = 32'haaaaaaa6;
	H_F[7] = 32'haaaaaaa7;
	H_F[8] = 32'haaaaaaa8;
	H_F[9] = 32'haaaaaaa9;
	H_F[10] = 32'haaaaaaaa;
	H_F[11] = 32'haaaaaaab;
	H_F[12] = 32'haaaaaaac;
	H_F[13] = 32'haaaaaaad;
	H_F[14] = 32'haaaaaaae;
	H_F[15] = 32'haaaaaaaf;
end
/////////////////////
reg [DATA_WIDTH*MESS_ARRAY_SIZE-1:0] bmw_round_m;
reg [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] bmw_round_h, bmw_round_h_loop;
/////////////////////
wire [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] bmw_round_ht;

reg state = 0;
always @(posedge clk)
begin
	state <= ~state;
	bmw_round_h_loop <= bmw_round_ht;
end

bmw_round bmw_round_inst0(clk, bmw_round_m, bmw_round_h, bmw_round_ht);
/////////////////////
always @*
begin
	bmw_round_m = (~state) ? {32'h0, 32'h100, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h80, m[32*8-1:0]} : bmw_round_h_loop;
	bmw_round_h = (~state) ? h : h_f;
end

always @(posedge clk)
	if (state)
		m_o <= bmw_round_ht[511:256];
endmodule
//////////////////////////////////////////
module bmw_round(
	input clk,
	
	input [DATA_WIDTH*MESS_ARRAY_SIZE-1:0] m,
	input [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] h,
	output [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] ht
);
/////////////////////
parameter DATA_WIDTH = 32;
parameter MESS_ARRAY_SIZE = 16;
parameter STATE_ARRAY_SIZE = 16;
/////////////////////
genvar i, k;
wire [DATA_WIDTH-1:0] M[0:MESS_ARRAY_SIZE-1], H[0:STATE_ARRAY_SIZE-1], Ht[0:STATE_ARRAY_SIZE-1];

generate
for (i = 0; i < MESS_ARRAY_SIZE; i = i + 1) begin 
    assign M[i] = m[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]; 
end
endgenerate

generate
for (i = 0; i < STATE_ARRAY_SIZE; i = i + 1) begin 
    assign H[i] = h[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
	 assign ht[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] = Ht[i];
end
endgenerate
/////////////////////
reg [DATA_WIDTH-1:0] Kb[0:15];
initial
begin
	Kb[0] = 32'h55555550;
	Kb[1] = 32'h5aaaaaa5;
	Kb[2] = 32'h5ffffffa;
	Kb[3] = 32'h6555554f;
	Kb[4] = 32'h6aaaaaa4;
	Kb[5] = 32'h6ffffff9;
	Kb[6] = 32'h7555554e;
	Kb[7] = 32'h7aaaaaa3;
	Kb[8] = 32'h7ffffff8;
	Kb[9] = 32'h8555554d;
	Kb[10] = 32'h8aaaaaa2;
	Kb[11] = 32'h8ffffff7;
	Kb[12] = 32'h9555554c;
	Kb[13] = 32'h9aaaaaa1;
	Kb[14] = 32'h9ffffff6;
	Kb[15] = 32'ha555554b;
end
///////////////////////
integer j;
reg [DATA_WIDTH-1:0] MxH[0:STATE_ARRAY_SIZE-1];
reg [DATA_WIDTH-1:0] Wb_reg[0:STATE_ARRAY_SIZE-1];
wire [DATA_WIDTH-1:0] Wb_next[0:STATE_ARRAY_SIZE-1];
reg [DATA_WIDTH-1:0] H_reg[0:47][0:STATE_ARRAY_SIZE-1];
reg [DATA_WIDTH-1:0] M_reg[0:53][0:STATE_ARRAY_SIZE-1];
wire [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] qt[0:16];
reg [DATA_WIDTH-1:0] qt_init[0:50][0:STATE_ARRAY_SIZE-1];
reg [DATA_WIDTH-1:0] H_low_reg[0:1][0:STATE_ARRAY_SIZE/2-1];
reg [DATA_WIDTH-1:0] H_high_reg[0:STATE_ARRAY_SIZE/2-1];
reg [DATA_WIDTH-1:0] xl[0:1], xh[0:1];
/////////////////////
generate
for (i = 0; i < 16; i = i + 1) begin 
	always @(posedge clk)
	begin
        MxH[i] <= M[i] ^ H[i];
	end
end
endgenerate

always @(posedge clk)
begin
    for (j = 0; j < 16; j = j + 1)
        H_reg[0][j] <= H[j];
    
    for (j = 0; j < 16; j = j + 1)
        M_reg[0][j] <= M[j];
end

generate
for (k = 0; k < 53; k = k + 1) begin
	for (i = 0; i < 16; i = i + 1) begin 
		always @(posedge clk)
		begin
            M_reg[k+1][i] <= M_reg[k][i]; 
		end
	end
end
endgenerate

generate
for (k = 0; k < 47; k = k + 1) begin
	for (i = 0; i < 16; i = i + 1) begin 
		always @(posedge clk)
		begin
            H_reg[k+1][i] <= H_reg[k][i];
		end
	end
end
endgenerate
/////////////////////
assign Wb_next[0] = MxH[5] - MxH[7] + MxH[10] + MxH[13] + MxH[14];
assign Wb_next[1] = MxH[6] - MxH[8] + MxH[11] + MxH[14] - MxH[15];
assign Wb_next[2] = MxH[0] + MxH[7] + MxH[9] - MxH[12] + MxH[15];
assign Wb_next[3] = MxH[0] - MxH[1] + MxH[8] - MxH[10] + MxH[13];
assign Wb_next[4] = MxH[1] + MxH[2] + MxH[9] - MxH[11] - MxH[14];
assign Wb_next[5] = MxH[3] - MxH[2] + MxH[10] - MxH[12] + MxH[15];
assign Wb_next[6] = MxH[4] - MxH[0] - MxH[3] - MxH[11] + MxH[13];
assign Wb_next[7] = MxH[1] - MxH[4] - MxH[5] - MxH[12] - MxH[14];
assign Wb_next[8] = MxH[2] - MxH[5] - MxH[6] + MxH[13] - MxH[15];
assign Wb_next[9] = MxH[0] - MxH[3] + MxH[6] - MxH[7] + MxH[14];
assign Wb_next[10] = MxH[8] - MxH[1] - MxH[4] - MxH[7] + MxH[15];
assign Wb_next[11] = MxH[8] - MxH[0] - MxH[2] - MxH[5] + MxH[9];
assign Wb_next[12] = MxH[1] + MxH[3] - MxH[6] - MxH[9] + MxH[10];
assign Wb_next[13] = MxH[2] + MxH[4] + MxH[7] + MxH[10] + MxH[11];
assign Wb_next[14] = MxH[3] - MxH[5] + MxH[8] - MxH[11] - MxH[12];
assign Wb_next[15] = MxH[12] - MxH[4] - MxH[6] - MxH[9] + MxH[13];

generate
for (i = 0; i < 16; i = i + 1) begin 
	always @(posedge clk)
	begin
        Wb_reg[i] <= Wb_next[i];
	end
end
endgenerate
/////////////////////
always @(posedge clk)
begin
    qt_init[0][0] <= sb0(Wb_reg[0]) + H_reg[1][1]; 
    qt_init[0][1] <= sb1(Wb_reg[1]) + H_reg[1][2]; 
    qt_init[0][2] <= sb2(Wb_reg[2]) + H_reg[1][3]; 
    qt_init[0][3] <= sb3(Wb_reg[3]) + H_reg[1][4]; 
    qt_init[0][4] <= sb4(Wb_reg[4]) + H_reg[1][5]; 
    qt_init[0][5] <= sb0(Wb_reg[5]) + H_reg[1][6]; 
    qt_init[0][6] <= sb1(Wb_reg[6]) + H_reg[1][7]; 
    qt_init[0][7] <= sb2(Wb_reg[7]) + H_reg[1][8]; 
    qt_init[0][8] <= sb3(Wb_reg[8]) + H_reg[1][9]; 
    qt_init[0][9] <= sb4(Wb_reg[9]) + H_reg[1][10]; 
    qt_init[0][10] <= sb0(Wb_reg[10]) + H_reg[1][11]; 
    qt_init[0][11] <= sb1(Wb_reg[11]) + H_reg[1][12]; 
    qt_init[0][12] <= sb2(Wb_reg[12]) + H_reg[1][13]; 
    qt_init[0][13] <= sb3(Wb_reg[13]) + H_reg[1][14]; 
    qt_init[0][14] <= sb4(Wb_reg[14]) + H_reg[1][15];
end

always @(posedge clk)
begin
    qt_init[0][15] <= sb0(Wb_reg[15]) + H_reg[1][0];
end

generate
for (k = 0; k < 50; k = k + 1) begin
	for (i = 0; i < 16; i = i + 1) begin 
		always @(posedge clk)
		begin
            qt_init[k+1][i] <= qt_init[k][i]; 
		end
	end
end
endgenerate

generate
for (i = 0; i < 16; i = i + 1) begin 
	assign qt[0][DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] = qt_init[0][i];
end
endgenerate
/////////////////////
qt0 qt0_qt1(clk, qt[0], M_reg[2][0], M_reg[2][3], M_reg[2][10], Kb[0], H_reg[2][7], 1, 4, 11, qt[1]);
/////////////////////
qt0 qt0_qt2(clk, qt[1], M_reg[5][1], M_reg[5][4], M_reg[5][11], Kb[1], H_reg[5][8], 2, 5, 12, qt[2]);
/////////////////////
qt1 qt1_qt3(clk, qt[2], M_reg[8][2], M_reg[8][5], M_reg[8][12], Kb[2], H_reg[8][9], 3, 6, 13, qt[3]);
/////////////////////
qt1 qt1_qt4(clk, qt[3], M_reg[11][3], M_reg[11][6], M_reg[11][13], Kb[3], H_reg[11][10], 4, 7, 14, qt[4]);
/////////////////////
qt1 qt1_qt5(clk, qt[4], M_reg[14][4], M_reg[14][7], M_reg[14][14], Kb[4], H_reg[14][11], 5, 8, 15, qt[5]);
/////////////////////
qt1 qt1_qt6(clk, qt[5], M_reg[17][5], M_reg[17][8], M_reg[17][15], Kb[5], H_reg[17][12], 6, 9, 16, qt[6]);
/////////////////////
qt1 qt1_qt7(clk, qt[6], M_reg[20][6], M_reg[20][9], M_reg[20][0], Kb[6], H_reg[20][13], 7, 10, 1, qt[7]);
/////////////////////
qt1 qt1_qt8(clk, qt[7], M_reg[23][7], M_reg[23][10], M_reg[23][1], Kb[7], H_reg[23][14], 8, 11, 2, qt[8]);
/////////////////////
qt1 qt1_qt9(clk, qt[8], M_reg[26][8], M_reg[26][11], M_reg[26][2], Kb[8], H_reg[26][15], 9, 12, 3, qt[9]);
/////////////////////
qt1 qt1_qt10(clk, qt[9], M_reg[29][9], M_reg[29][12], M_reg[29][3], Kb[9], H_reg[29][0], 10, 13, 4, qt[10]);
/////////////////////
qt1 qt1_qt11(clk, qt[10], M_reg[32][10], M_reg[32][13], M_reg[32][4], Kb[10], H_reg[32][1], 11, 14, 5, qt[11]);
/////////////////////
qt1 qt1_qt12(clk, qt[11], M_reg[35][11], M_reg[35][14], M_reg[35][5], Kb[11], H_reg[35][2], 12, 15, 6, qt[12]);
/////////////////////
qt1 qt1_qt13(clk, qt[12], M_reg[38][12], M_reg[38][15], M_reg[38][6], Kb[12], H_reg[38][3], 13, 16, 7, qt[13]);
/////////////////////
qt1 qt1_qt14(clk, qt[13], M_reg[41][13], M_reg[41][0], M_reg[41][7], Kb[13], H_reg[41][4], 14, 1, 8, qt[14]);
/////////////////////
qt1 qt1_qt15(clk, qt[14], M_reg[44][14], M_reg[44][1], M_reg[44][8], Kb[14], H_reg[44][5], 15, 2, 9, qt[15]);
/////////////////////
qt1 qt1_qt16(clk, qt[15], M_reg[47][15], M_reg[47][2], M_reg[47][9], Kb[15], H_reg[47][6], 16, 3, 10, qt[16]);
/////////////////////
reg [DATA_WIDTH-1:0] Qt[0:2][0:15];

generate
	for (i = 0; i < 16; i = i + 1)
		begin
			always @(*)
				begin
					Qt[0][i] <= qt[0+16][DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
				end
		end
endgenerate

generate
	for (i = 0; i < 2; i = i + 1)
		begin
			for (k = 0; k < 16; k = k + 1)
				begin
					always @(posedge clk)
						begin
                            Qt[i+1][k] <= Qt[i][k]; 
						end
				end
		end
endgenerate
/////////////////////
always @(posedge clk)
begin
    xl[0] <= Qt[0][0] ^ Qt[0][1] ^ Qt[0][2] ^ Qt[0][3] ^ Qt[0][4] ^ Qt[0][5] ^ Qt[0][6] ^ Qt[0][7];
    xh[0] <= Qt[0][0] ^ Qt[0][1] ^ Qt[0][2] ^ Qt[0][3] ^ Qt[0][4] ^ Qt[0][5] ^ Qt[0][6] ^ Qt[0][7] ^
                Qt[0][8] ^ Qt[0][9] ^ Qt[0][10] ^ Qt[0][11] ^ Qt[0][12] ^ Qt[0][13] ^ Qt[0][14] ^ Qt[0][15];
    xl[1] <= xl[0];
    xh[1] <= xh[0];
end
/////////////////////
always @(posedge clk)
begin
    H_low_reg[0][0] <= ((xh[0] <<  5) ^ (Qt[1][0] >>  5) ^ M_reg[51][ 0]) + (xl[0] ^ Qt[1][8] ^ qt_init[49][ 0]);  
    H_low_reg[0][1] <= ((xh[0] >>  7) ^ (Qt[1][1] <<  8) ^ M_reg[51][ 1]) + (xl[0] ^ Qt[1][9] ^ qt_init[49][ 1]);  
    H_low_reg[0][2] <= ((xh[0] >>  5) ^ (Qt[1][2] <<  5) ^ M_reg[51][ 2]) + (xl[0] ^ Qt[1][10] ^ qt_init[49][ 2]);  
    H_low_reg[0][3] <= ((xh[0] >>  1) ^ (Qt[1][3] <<  5) ^ M_reg[51][ 3]) + (xl[0] ^ Qt[1][11] ^ qt_init[49][ 3]);  
    H_low_reg[0][4] <= ((xh[0] >>  3) ^ (Qt[1][4] <<  0) ^ M_reg[51][ 4]) + (xl[0] ^ Qt[1][12] ^ qt_init[49][ 4]);  
    H_low_reg[0][5] <= ((xh[0] <<  6) ^ (Qt[1][5] >>  6) ^ M_reg[51][ 5]) + (xl[0] ^ Qt[1][13] ^ qt_init[49][ 5]);  
    H_low_reg[0][6] <= ((xh[0] >>  4) ^ (Qt[1][6] <<  6) ^ M_reg[51][ 6]) + (xl[0] ^ Qt[1][14] ^ qt_init[49][ 6]);  
    H_low_reg[0][7] <= ((xh[0] >> 11) ^ (Qt[1][7] <<  2) ^ M_reg[51][ 7]) + (xl[0] ^ Qt[1][15] ^ qt_init[49][ 7]);
    
    H_low_reg[1][0] <= H_low_reg[0][0];
    H_low_reg[1][1] <= H_low_reg[0][1];
    H_low_reg[1][2] <= H_low_reg[0][2];
    H_low_reg[1][3] <= H_low_reg[0][3];
    H_low_reg[1][4] <= H_low_reg[0][4];
    H_low_reg[1][5] <= H_low_reg[0][5];
    H_low_reg[1][6] <= H_low_reg[0][6];
    H_low_reg[1][7] <= H_low_reg[0][7];
end
/////////////////////
always @(posedge clk)
begin
    H_high_reg[0] = ROTL64(H_low_reg[0][4],  9) + (xh[1] ^ Qt[2][8] ^ M_reg[52][ 8]) + ((xl[1] << 8) ^ Qt[2][7] ^ qt_init[50][ 8]);  
    H_high_reg[1] = ROTL64(H_low_reg[0][5], 10) + (xh[1] ^ Qt[2][9] ^ M_reg[52][ 9]) + ((xl[1] >> 6) ^ Qt[2][0] ^ qt_init[50][ 9]);  
    H_high_reg[2] = ROTL64(H_low_reg[0][6], 11) + (xh[1] ^ Qt[2][10] ^ M_reg[52][10]) + ((xl[1] << 6) ^ Qt[2][1] ^ qt_init[50][10]);  
    H_high_reg[3] = ROTL64(H_low_reg[0][7], 12) + (xh[1] ^ Qt[2][11] ^ M_reg[52][11]) + ((xl[1] << 4) ^ Qt[2][2] ^ qt_init[50][11]);  
    H_high_reg[4] = ROTL64(H_low_reg[0][0], 13) + (xh[1] ^ Qt[2][12] ^ M_reg[52][12]) + ((xl[1] >> 3) ^ Qt[2][3] ^ qt_init[50][12]);  
    H_high_reg[5] = ROTL64(H_low_reg[0][1], 14) + (xh[1] ^ Qt[2][13] ^ M_reg[52][13]) + ((xl[1] >> 4) ^ Qt[2][4] ^ qt_init[50][13]);  
    H_high_reg[6] = ROTL64(H_low_reg[0][2], 15) + (xh[1] ^ Qt[2][14] ^ M_reg[52][14]) + ((xl[1] >> 7) ^ Qt[2][5] ^ qt_init[50][14]);  
    H_high_reg[7] = ROTL64(H_low_reg[0][3], 16) + (xh[1] ^ Qt[2][15] ^ M_reg[52][15]) + ((xl[1] >> 2) ^ Qt[2][6] ^ qt_init[50][15]);  
end

assign Ht[0] = H_low_reg[1][0];
assign Ht[1] = H_low_reg[1][1];
assign Ht[2] = H_low_reg[1][2];
assign Ht[3] = H_low_reg[1][3];
assign Ht[4] = H_low_reg[1][4];
assign Ht[5] = H_low_reg[1][5];
assign Ht[6] = H_low_reg[1][6];
assign Ht[7] = H_low_reg[1][7];
assign Ht[8] = H_high_reg[0];
assign Ht[9] = H_high_reg[1];
assign Ht[10] = H_high_reg[2];
assign Ht[11] = H_high_reg[3];
assign Ht[12] = H_high_reg[4];
assign Ht[13] = H_high_reg[5];
assign Ht[14] = H_high_reg[6];
assign Ht[15] = H_high_reg[7];
/////////////////////
function [DATA_WIDTH-1:0] ROTL64;
input [DATA_WIDTH-1:0] in, n;
begin
	ROTL64 = (in << n) | (in >> (DATA_WIDTH - n));
end
endfunction

function [DATA_WIDTH-1:0] sb0;
input [DATA_WIDTH-1:0] x;
begin
	sb0 = (x >> 1) ^ (x << 3) ^ ROTL64(x,  4) ^ ROTL64(x, 19);
end
endfunction

function [DATA_WIDTH-1:0] sb1;
input [DATA_WIDTH-1:0] x;
begin
	sb1 = (x >> 1) ^ (x << 2) ^ ROTL64(x,  8) ^ ROTL64(x, 23);
end
endfunction

function [DATA_WIDTH-1:0] sb2;
input [DATA_WIDTH-1:0] x;
begin
	sb2 = (x >> 2) ^ (x << 1) ^ ROTL64(x,  12) ^ ROTL64(x, 25);
end
endfunction

function [DATA_WIDTH-1:0] sb3;
input [DATA_WIDTH-1:0] x;
begin
	sb3 = (x >> 2) ^ (x << 2) ^ ROTL64(x,  15) ^ ROTL64(x, 29);
end
endfunction
	
function [DATA_WIDTH-1:0] sb4;
input [DATA_WIDTH-1:0] x;
begin
	sb4 = (x >> 1) ^ x;
end
endfunction

function [DATA_WIDTH-1:0] sb5;
input [DATA_WIDTH-1:0] x;
begin
	sb5 = (x >> 2) ^ x;
end
endfunction

function [DATA_WIDTH-1:0] rb1;
input [DATA_WIDTH-1:0] x;
begin
	rb1 = ROTL64(x, 3);
end
endfunction

function [DATA_WIDTH-1:0] rb2;
input [DATA_WIDTH-1:0] x;
begin
	rb2 = ROTL64(x, 7);
end
endfunction

function [DATA_WIDTH-1:0] rb3;
input [DATA_WIDTH-1:0] x;
begin
	rb3 = ROTL64(x, 13);
end
endfunction

function [DATA_WIDTH-1:0] rb4;
input [DATA_WIDTH-1:0] x;
begin
	rb4 = ROTL64(x, 16);
end
endfunction

function [DATA_WIDTH-1:0] rb5;
input [DATA_WIDTH-1:0] x;
begin
	rb5 = ROTL64(x, 19);
end
endfunction

function [DATA_WIDTH-1:0] rb6;
input [DATA_WIDTH-1:0] x;
begin
	rb6 = ROTL64(x, 23);
end
endfunction

function [DATA_WIDTH-1:0] rb7;
input [DATA_WIDTH-1:0] x;
begin
	rb7 = ROTL64(x, 27);
end
endfunction
endmodule
//////////////////////////////////////////
module qt0(
	input clk,
		
	input [DATA_WIDTH*16-1:0] qt,
	
	input [DATA_WIDTH-1:0] m0, m1, m2, kb, h0,
	input [4:0] rol0, rol1, rol2,
	
	output [DATA_WIDTH*16-1:0] qto
);
/////////////////////
parameter DATA_WIDTH = 32;
/////////////////////
genvar i;
reg [DATA_WIDTH*16-1:0] qt_temp[0:2];
wire [DATA_WIDTH-1:0] Qt[0:15];

generate
for (i = 0; i < 16; i = i + 1) begin 
    assign Qt[i] = qt[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
end
endgenerate

reg [DATA_WIDTH-1:0] temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9, temp10, temp11, temp12, temp13, temp14;
reg [DATA_WIDTH-1:0] h0_temp;
wire [DATA_WIDTH-1:0] res = temp2 + temp5 + temp8 + temp11 + temp14;
always @(posedge clk)
begin
    temp0 <= sb1(Qt[0]) + sb2(Qt[1]); temp1 <= sb3(Qt[2]) + sb0(Qt[3]); temp2 <= temp0 + temp1;
    temp3 <= sb1(Qt[4]) + sb2(Qt[5]); temp4 <= sb3(Qt[6]) + sb0(Qt[7]); temp5 <= temp3 + temp4;
    temp6 <= sb1(Qt[8]) + sb2(Qt[9]); temp7 <= sb3(Qt[10]) + sb0(Qt[11]); temp8 <= temp6 + temp7;
    temp9 <= sb1(Qt[12]) + sb2(Qt[13]); temp10 <= sb3(Qt[14]) + sb0(Qt[15]); temp11 <= temp9 + temp10;
    temp12 <= ROTL64(m0, rol0) + ROTL64(m1, rol1); temp13 <= kb - ROTL64(m2, rol2); h0_temp <= h0; temp14 <= (temp12 + temp13) ^ h0_temp;
    
    qt_temp[0] <= qt; qt_temp[1] <= qt_temp[0]; qt_temp[2] <= {res, qt_temp[1][DATA_WIDTH*16-1:DATA_WIDTH]}; 
end

assign qto = qt_temp[2];
/////////////////////
function [DATA_WIDTH-1:0] ROTL64;
input [DATA_WIDTH-1:0] in, n;
begin
	ROTL64 = (in << n) | (in >> (DATA_WIDTH - n));
end
endfunction

function [DATA_WIDTH-1:0] sb0;
input [DATA_WIDTH-1:0] x;
begin
	sb0 = (x >> 1) ^ (x << 3) ^ ROTL64(x,  4) ^ ROTL64(x, 19);
end
endfunction

function [DATA_WIDTH-1:0] sb1;
input [DATA_WIDTH-1:0] x;
begin
	sb1 = (x >> 1) ^ (x << 2) ^ ROTL64(x,  8) ^ ROTL64(x, 23);
end
endfunction

function [DATA_WIDTH-1:0] sb2;
input [DATA_WIDTH-1:0] x;
begin
	sb2 = (x >> 2) ^ (x << 1) ^ ROTL64(x,  12) ^ ROTL64(x, 25);
end
endfunction

function [DATA_WIDTH-1:0] sb3;
input [DATA_WIDTH-1:0] x;
begin
	sb3 = (x >> 2) ^ (x << 2) ^ ROTL64(x,  15) ^ ROTL64(x, 29);
end
endfunction
	
function [DATA_WIDTH-1:0] sb4;
input [DATA_WIDTH-1:0] x;
begin
	sb4 = (x >> 1) ^ x;
end
endfunction

function [DATA_WIDTH-1:0] sb5;
input [DATA_WIDTH-1:0] x;
begin
	sb5 = (x >> 2) ^ x;
end
endfunction

function [DATA_WIDTH-1:0] rb1;
input [DATA_WIDTH-1:0] x;
begin
	rb1 = ROTL64(x, 3);
end
endfunction

function [DATA_WIDTH-1:0] rb2;
input [DATA_WIDTH-1:0] x;
begin
	rb2 = ROTL64(x, 7);
end
endfunction

function [DATA_WIDTH-1:0] rb3;
input [DATA_WIDTH-1:0] x;
begin
	rb3 = ROTL64(x, 13);
end
endfunction

function [DATA_WIDTH-1:0] rb4;
input [DATA_WIDTH-1:0] x;
begin
	rb4 = ROTL64(x, 16);
end
endfunction

function [DATA_WIDTH-1:0] rb5;
input [DATA_WIDTH-1:0] x;
begin
	rb5 = ROTL64(x, 19);
end
endfunction

function [DATA_WIDTH-1:0] rb6;
input [DATA_WIDTH-1:0] x;
begin
	rb6 = ROTL64(x, 23);
end
endfunction

function [DATA_WIDTH-1:0] rb7;
input [DATA_WIDTH-1:0] x;
begin
	rb7 = ROTL64(x, 27);
end
endfunction

endmodule
//////////////////////////////////////////
module qt1(
	input clk,
	
	input [DATA_WIDTH*16-1:0] qt,
	
	input [DATA_WIDTH-1:0] m0, m1, m2, kb, h0,
	input [4:0] rol0, rol1, rol2,
	
	output [DATA_WIDTH*16-1:0] qto
);
/////////////////////
parameter DATA_WIDTH = 32;
/////////////////////
genvar i;
reg [DATA_WIDTH*16-1:0] qt_temp[0:2];
wire [DATA_WIDTH-1:0] Qt[0:15];

generate
for (i = 0; i < 16; i = i + 1) begin 
    assign Qt[i] = qt[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
end
endgenerate

reg [DATA_WIDTH-1:0] temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9, temp10, temp11, temp12, temp13, temp14;
reg [DATA_WIDTH-1:0] h0_temp;
wire [DATA_WIDTH-1:0] res = temp2 + temp5 + temp8 + temp11 + temp14;
always @(posedge clk)
begin
    temp0 <= Qt[0] + rb1(Qt[1]); temp1 <= Qt[2] + rb2(Qt[3]); temp2 <= temp0 + temp1;
    temp3 <= Qt[4] + rb3(Qt[5]); temp4 <= Qt[6] + rb4(Qt[7]); temp5 <= temp3 + temp4;
    temp6 <= Qt[8] + rb5(Qt[9]); temp7 <= Qt[10] + rb6(Qt[11]); temp8 <= temp6 + temp7;
    temp9 <= Qt[12] + rb7(Qt[13]); temp10 <= sb4(Qt[14]) + sb5(Qt[15]); temp11 <= temp9 + temp10;
    temp12 <= ROTL64(m0, rol0) + ROTL64(m1, rol1); temp13 <= kb - ROTL64(m2, rol2); h0_temp <= h0; temp14 <= (temp12 + temp13) ^ h0_temp;
    
    qt_temp[0] <= qt; qt_temp[1] <= qt_temp[0]; qt_temp[2] <= {res, qt_temp[1][DATA_WIDTH*16-1:DATA_WIDTH]}; 
end

assign qto = qt_temp[2];
/////////////////////
function [DATA_WIDTH-1:0] ROTL64;
input [DATA_WIDTH-1:0] in, n;
begin
	ROTL64 = (in << n) | (in >> (DATA_WIDTH - n));
end
endfunction

function [DATA_WIDTH-1:0] sb0;
input [DATA_WIDTH-1:0] x;
begin
	sb0 = (x >> 1) ^ (x << 3) ^ ROTL64(x,  4) ^ ROTL64(x, 19);
end
endfunction

function [DATA_WIDTH-1:0] sb1;
input [DATA_WIDTH-1:0] x;
begin
	sb1 = (x >> 1) ^ (x << 2) ^ ROTL64(x,  8) ^ ROTL64(x, 23);
end
endfunction

function [DATA_WIDTH-1:0] sb2;
input [DATA_WIDTH-1:0] x;
begin
	sb2 = (x >> 2) ^ (x << 1) ^ ROTL64(x,  12) ^ ROTL64(x, 25);
end
endfunction

function [DATA_WIDTH-1:0] sb3;
input [DATA_WIDTH-1:0] x;
begin
	sb3 = (x >> 2) ^ (x << 2) ^ ROTL64(x,  15) ^ ROTL64(x, 29);
end
endfunction
	
function [DATA_WIDTH-1:0] sb4;
input [DATA_WIDTH-1:0] x;
begin
	sb4 = (x >> 1) ^ x;
end
endfunction

function [DATA_WIDTH-1:0] sb5;
input [DATA_WIDTH-1:0] x;
begin
	sb5 = (x >> 2) ^ x;
end
endfunction

function [DATA_WIDTH-1:0] rb1;
input [DATA_WIDTH-1:0] x;
begin
	rb1 = ROTL64(x, 3);
end
endfunction

function [DATA_WIDTH-1:0] rb2;
input [DATA_WIDTH-1:0] x;
begin
	rb2 = ROTL64(x, 7);
end
endfunction

function [DATA_WIDTH-1:0] rb3;
input [DATA_WIDTH-1:0] x;
begin
	rb3 = ROTL64(x, 13);
end
endfunction

function [DATA_WIDTH-1:0] rb4;
input [DATA_WIDTH-1:0] x;
begin
	rb4 = ROTL64(x, 16);
end
endfunction

function [DATA_WIDTH-1:0] rb5;
input [DATA_WIDTH-1:0] x;
begin
	rb5 = ROTL64(x, 19);
end
endfunction

function [DATA_WIDTH-1:0] rb6;
input [DATA_WIDTH-1:0] x;
begin
	rb6 = ROTL64(x, 23);
end
endfunction

function [DATA_WIDTH-1:0] rb7;
input [DATA_WIDTH-1:0] x;
begin
	rb7 = ROTL64(x, 27);
end
endfunction

endmodule