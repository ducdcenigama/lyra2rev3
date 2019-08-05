`timescale 1ns / 1ps
module blake(
	input clk,
	
	input [80*8-1:0] m,
	output reg [32*8-1:0] m_o
);
/////////////////////
parameter DATA_WIDTH = 32;
parameter MESS_ARRAY_SIZE = 16;
parameter STATE_ARRAY_SIZE = 8;
/////////////////////
genvar i, j;
reg [DATA_WIDTH-1:0] iv[0:7];

initial
begin
	iv[0] = 32'h6A09E667;
	iv[1] = 32'hBB67AE85;
	iv[2] = 32'h3C6EF372;
	iv[3] = 32'hA54FF53A;
	iv[4] = 32'h510E527F;
	iv[5] = 32'h9B05688C;
	iv[6] = 32'h1F83D9AB;
	iv[7] = 32'h5BE0CD19;
end

wire [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] h, blake_core_h;
wire [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] blake_core_m_o;
wire [DATA_WIDTH-1:0] blake_core_t;
wire [DATA_WIDTH*MESS_ARRAY_SIZE-1:0] blake_core_m;
wire [80*8-1:0] m_temp; 

assign h = {iv[7], iv[6], iv[5], iv[4], iv[3], iv[2], iv[1], iv[0]};

generate
for (i = 0; i < 20; i = i + 1) begin 
	for (j = 0; j < 4; j = j + 1) begin
		assign m_temp[DATA_WIDTH*i+8*(j+1)-1:DATA_WIDTH*i+8*j] = m[DATA_WIDTH*i+8*(4-j)-1:DATA_WIDTH*i+8*(3-j)];
	end
end
endgenerate
							
reg [127:0] M_reg[0:114];
integer k;
always @(posedge clk)
begin
	M_reg[0] <= m_temp[639:512];
	
	for (k = 0; k < 114; k = k + 1)
		M_reg[k+1] <= M_reg[k];
end

reg state = 0;
reg [DATA_WIDTH*MESS_ARRAY_SIZE-1:0] blake_core_m_o_loop;
always @(posedge clk)
begin
	state <= ~state;
	blake_core_m_o_loop <= blake_core_m_o;
end		

assign blake_core_m = (~state) ? m_temp[511:0] : {32'h280, 32'h0, 32'h1, 256'h0, 32'h80000000, M_reg[114]};
assign blake_core_h = (~state) ? h : blake_core_m_o_loop;
assign blake_core_t = (~state) ? 32'h200 : 32'h280;

		
blake_core blake_core_inst0(clk, blake_core_m, blake_core_h, blake_core_t, blake_core_m_o);

generate
for (i = 0; i < 8; i = i + 1) begin 
	for (j = 0; j < 4; j = j + 1) begin
		always @(posedge clk)
			if (state)
				m_o[DATA_WIDTH*i+8*(j+1)-1:DATA_WIDTH*i+8*j] <= blake_core_m_o[DATA_WIDTH*i+8*(4-j)-1:DATA_WIDTH*i+8*(3-j)];
	end
end
endgenerate

endmodule
//////////////////////////////////////////////
`timescale 1ns / 1ps
module blake_core(
	input clk,
	
	input [DATA_WIDTH*MESS_ARRAY_SIZE-1:0] m,
	input [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] h,
	input [DATA_WIDTH-1:0] t,
	output reg [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] ht
);
/////////////////////
parameter DATA_WIDTH = 32;
parameter MESS_ARRAY_SIZE = 16;
parameter STATE_ARRAY_SIZE = 8;
/////////////////////
genvar i, k;
/////////////////////
reg [3:0] sigma[0:9][0:15];
reg [DATA_WIDTH-1:0] CB[0:15];

initial
begin
	sigma[0][0] = 0;
	sigma[0][1] = 1;
	sigma[0][2] = 2;
	sigma[0][3] = 3;
	sigma[0][4] = 4;
	sigma[0][5] = 5;
	sigma[0][6] = 6;
	sigma[0][7] = 7;
	sigma[0][8] = 8;
	sigma[0][9] = 9;
	sigma[0][10] = 10;
	sigma[0][11] = 11;
	sigma[0][12] = 12;
	sigma[0][13] = 13;
	sigma[0][14] = 14;
	sigma[0][15] = 15;
	
	sigma[1][0] = 14;
	sigma[1][1] = 10;
	sigma[1][2] = 4;
	sigma[1][3] = 8;
	sigma[1][4] = 9;
	sigma[1][5] = 15;
	sigma[1][6] = 13;
	sigma[1][7] = 6;
	sigma[1][8] = 1;
	sigma[1][9] = 12;
	sigma[1][10] = 0;
	sigma[1][11] = 2;
	sigma[1][12] = 11;
	sigma[1][13] = 7;
	sigma[1][14] = 5;
	sigma[1][15] = 3;

	sigma[2][0] = 11;
	sigma[2][1] = 8;
	sigma[2][2] = 12;
	sigma[2][3] = 0;
	sigma[2][4] = 5;
	sigma[2][5] = 2;
	sigma[2][6] = 15;
	sigma[2][7] = 13;
	sigma[2][8] = 10;
	sigma[2][9] = 14;
	sigma[2][10] = 3;
	sigma[2][11] = 6;
	sigma[2][12] = 7;
	sigma[2][13] = 1;
	sigma[2][14] = 9;
	sigma[2][15] = 4;
	
	sigma[3][0] = 7;
	sigma[3][1] = 9;
	sigma[3][2] = 3;
	sigma[3][3] = 1;
	sigma[3][4] = 13;
	sigma[3][5] = 12;
	sigma[3][6] = 11;
	sigma[3][7] = 14;
	sigma[3][8] = 2;
	sigma[3][9] = 6;
	sigma[3][10] = 5;
	sigma[3][11] = 10;
	sigma[3][12] = 4;
	sigma[3][13] = 0;
	sigma[3][14] = 15;
	sigma[3][15] = 8;
	
	sigma[4][0] = 9;
	sigma[4][1] = 0;
	sigma[4][2] = 5;
	sigma[4][3] = 7;
	sigma[4][4] = 2;
	sigma[4][5] = 4;
	sigma[4][6] = 10;
	sigma[4][7] = 15;
	sigma[4][8] = 14;
	sigma[4][9] = 1;
	sigma[4][10] = 11;
	sigma[4][11] = 12;
	sigma[4][12] = 6;
	sigma[4][13] = 8;
	sigma[4][14] = 3;
	sigma[4][15] = 13;

	sigma[5][0] = 2;
	sigma[5][1] = 12;
	sigma[5][2] = 6;
	sigma[5][3] = 10;
	sigma[5][4] = 0;
	sigma[5][5] = 11;
	sigma[5][6] = 8;
	sigma[5][7] = 3;
	sigma[5][8] = 4;
	sigma[5][9] = 13;
	sigma[5][10] = 7;
	sigma[5][11] = 5;
	sigma[5][12] = 15;
	sigma[5][13] = 14;
	sigma[5][14] = 1;
	sigma[5][15] = 9;
	
	sigma[6][0] = 12;
	sigma[6][1] = 5;
	sigma[6][2] = 1;
	sigma[6][3] = 15;
	sigma[6][4] = 14;
	sigma[6][5] = 13;
	sigma[6][6] = 4;
	sigma[6][7] = 10;
	sigma[6][8] = 0;
	sigma[6][9] = 7;
	sigma[6][10] = 6;
	sigma[6][11] = 3;
	sigma[6][12] = 9;
	sigma[6][13] = 2;
	sigma[6][14] = 8;
	sigma[6][15] = 11;
	
	sigma[7][0] = 13;
	sigma[7][1] = 11;
	sigma[7][2] = 7;
	sigma[7][3] = 14;
	sigma[7][4] = 12;
	sigma[7][5] = 1;
	sigma[7][6] = 3;
	sigma[7][7] = 9;
	sigma[7][8] = 5;
	sigma[7][9] = 0;
	sigma[7][10] = 15;
	sigma[7][11] = 4;
	sigma[7][12] = 8;
	sigma[7][13] = 6;
	sigma[7][14] = 2;
	sigma[7][15] = 10;
	
	sigma[8][0] = 6;
	sigma[8][1] = 15;
	sigma[8][2] = 14;
	sigma[8][3] = 9;
	sigma[8][4] = 11;
	sigma[8][5] = 3;
	sigma[8][6] = 0;
	sigma[8][7] = 8;
	sigma[8][8] = 12;
	sigma[8][9] = 2;
	sigma[8][10] = 13;
	sigma[8][11] = 7;
	sigma[8][12] = 1;
	sigma[8][13] = 4;
	sigma[8][14] = 10;
	sigma[8][15] = 5;
	
	sigma[9][0] = 10;
	sigma[9][1] = 2;
	sigma[9][2] = 8;
	sigma[9][3] = 4;
	sigma[9][4] = 7;
	sigma[9][5] = 6;
	sigma[9][6] = 1;
	sigma[9][7] = 5;
	sigma[9][8] = 15;
	sigma[9][9] = 11;
	sigma[9][10] = 9;
	sigma[9][11] = 14;
	sigma[9][12] = 3;
	sigma[9][13] = 12;
	sigma[9][14] = 13;
	sigma[9][15] = 0;
	
	CB[0] = 32'h243F6A88;
	CB[1] = 32'h85A308D3;
	CB[2] = 32'h13198A2E;
	CB[3] = 32'h03707344;
	CB[4] = 32'hA4093822;
	CB[5] = 32'h299F31D0;
	CB[6] = 32'h082EFA98;
	CB[7] = 32'hEC4E6C89;
	CB[8] = 32'h452821E6;
	CB[9] = 32'h38D01377;
	CB[10] = 32'hBE5466CF;
	CB[11] = 32'h34E90C6C;
	CB[12] = 32'hC0AC29B7;
	CB[13] = 32'hC97C50DD;
	CB[14] = 32'h3F84D5B5;
	CB[15] = 32'hB5470917;
end
/////////////////////
wire [DATA_WIDTH-1:0] v[0:15];

assign v[0] = h[DATA_WIDTH*(0+1)-1:DATA_WIDTH*0];
assign v[1] = h[DATA_WIDTH*(1+1)-1:DATA_WIDTH*1];
assign v[2] = h[DATA_WIDTH*(2+1)-1:DATA_WIDTH*2];
assign v[3] = h[DATA_WIDTH*(3+1)-1:DATA_WIDTH*3];
assign v[4] = h[DATA_WIDTH*(4+1)-1:DATA_WIDTH*4];
assign v[5] = h[DATA_WIDTH*(5+1)-1:DATA_WIDTH*5];
assign v[6] = h[DATA_WIDTH*(6+1)-1:DATA_WIDTH*6];
assign v[7] = h[DATA_WIDTH*(7+1)-1:DATA_WIDTH*7];

assign v[8] = CB[0];
assign v[9] = CB[1];
assign v[10] = CB[2];
assign v[11] = CB[3];
assign v[12] = t ^ CB[4];
assign v[13] = t ^ CB[5];
assign v[14] = CB[6];
assign v[15] = CB[7];
/////////////////////
integer j;
reg [DATA_WIDTH*MESS_ARRAY_SIZE-1:0] V_reg[0:27];
reg [DATA_WIDTH*MESS_ARRAY_SIZE-1:0] M_reg[0:108];
reg [DATA_WIDTH*STATE_ARRAY_SIZE-1:0] H_reg[0:112];
wire [DATA_WIDTH-1:0] M_reg_temp[0:108][0:MESS_ARRAY_SIZE-1];
wire [DATA_WIDTH*MESS_ARRAY_SIZE-1:0] nV_reg[0:27];

always @(posedge clk)
begin
	V_reg[0] <= {v[15], v[14], v[13], v[12], v[11], v[10], v[9], v[8], v[7], v[6], v[5], v[4], v[3], v[2], v[1], v[0]};
	
	M_reg[0] <= m;
	
	H_reg[0] <= h;
	
	for (j = 0; j < 108; j = j + 1)
		begin
			M_reg[j+1] <= M_reg[j];
		end
	
	for (j = 0; j < 112; j = j + 1)
		begin
			H_reg[j+1] <= H_reg[j];
		end
end

always @*
begin
	for (j = 0; j < 27; j = j + 1)
		begin
			V_reg[j+1] <= nV_reg[j];
		end
end

generate 
for (i = 0; i <= 108; i = i + 1) begin 
	for (k = 0; k < 16; k = k + 1) begin
		assign M_reg_temp[i][k] = M_reg[i][DATA_WIDTH*(k+1)-1:DATA_WIDTH*k];
	end
end
endgenerate


generate
for (i = 0; i < 14; i = i + 1) begin 
	mix mix_round0(
		.clk(clk),

		.a(V_reg[2*i][DATA_WIDTH*(0+1)-1:DATA_WIDTH*0]),
		.b(V_reg[2*i][DATA_WIDTH*(4+1)-1:DATA_WIDTH*4]),
		.c(V_reg[2*i][DATA_WIDTH*(8+1)-1:DATA_WIDTH*8]),
		.d(V_reg[2*i][DATA_WIDTH*(12+1)-1:DATA_WIDTH*12]),
		.m0(M_reg_temp[8*i][sigma[i%10][0]]),
		.m1(M_reg_temp[8*i][sigma[i%10][1]]),
		.c0(CB[sigma[i%10][0]]),
		.c1(CB[sigma[i%10][1]]),

		.a_o(nV_reg[2*i][DATA_WIDTH*(0+1)-1:DATA_WIDTH*0]),
		.b_o(nV_reg[2*i][DATA_WIDTH*(4+1)-1:DATA_WIDTH*4]),
		.c_o(nV_reg[2*i][DATA_WIDTH*(8+1)-1:DATA_WIDTH*8]),
		.d_o(nV_reg[2*i][DATA_WIDTH*(12+1)-1:DATA_WIDTH*12])
	);

	mix mix_round1(
		.clk(clk),

		.a(V_reg[2*i][DATA_WIDTH*(1+1)-1:DATA_WIDTH*1]),
		.b(V_reg[2*i][DATA_WIDTH*(5+1)-1:DATA_WIDTH*5]),
		.c(V_reg[2*i][DATA_WIDTH*(9+1)-1:DATA_WIDTH*9]),
		.d(V_reg[2*i][DATA_WIDTH*(13+1)-1:DATA_WIDTH*13]),
		.m0(M_reg_temp[8*i][sigma[i%10][2]]),
		.m1(M_reg_temp[8*i][sigma[i%10][3]]),
		.c0(CB[sigma[i%10][2]]),
		.c1(CB[sigma[i%10][3]]),

		.a_o(nV_reg[2*i][DATA_WIDTH*(1+1)-1:DATA_WIDTH*1]),
		.b_o(nV_reg[2*i][DATA_WIDTH*(5+1)-1:DATA_WIDTH*5]),
		.c_o(nV_reg[2*i][DATA_WIDTH*(9+1)-1:DATA_WIDTH*9]),
		.d_o(nV_reg[2*i][DATA_WIDTH*(13+1)-1:DATA_WIDTH*13])
	);

	mix mix_round2(
		.clk(clk),

		.a(V_reg[2*i][DATA_WIDTH*(2+1)-1:DATA_WIDTH*2]),
		.b(V_reg[2*i][DATA_WIDTH*(6+1)-1:DATA_WIDTH*6]),
		.c(V_reg[2*i][DATA_WIDTH*(10+1)-1:DATA_WIDTH*10]),
		.d(V_reg[2*i][DATA_WIDTH*(14+1)-1:DATA_WIDTH*14]),
		.m0(M_reg_temp[8*i][sigma[i%10][4]]),
		.m1(M_reg_temp[8*i][sigma[i%10][5]]),
		.c0(CB[sigma[i%10][4]]),
		.c1(CB[sigma[i%10][5]]),

		.a_o(nV_reg[2*i][DATA_WIDTH*(2+1)-1:DATA_WIDTH*2]),
		.b_o(nV_reg[2*i][DATA_WIDTH*(6+1)-1:DATA_WIDTH*6]),
		.c_o(nV_reg[2*i][DATA_WIDTH*(10+1)-1:DATA_WIDTH*10]),
		.d_o(nV_reg[2*i][DATA_WIDTH*(14+1)-1:DATA_WIDTH*14])
	);

	mix mix_round3(
		.clk(clk),

		.a(V_reg[2*i][DATA_WIDTH*(3+1)-1:DATA_WIDTH*3]),
		.b(V_reg[2*i][DATA_WIDTH*(7+1)-1:DATA_WIDTH*7]),
		.c(V_reg[2*i][DATA_WIDTH*(11+1)-1:DATA_WIDTH*11]),
		.d(V_reg[2*i][DATA_WIDTH*(15+1)-1:DATA_WIDTH*15]),
		.m0(M_reg_temp[8*i][sigma[i%10][6]]),
		.m1(M_reg_temp[8*i][sigma[i%10][7]]),
		.c0(CB[sigma[i%10][6]]),
		.c1(CB[sigma[i%10][7]]),

		.a_o(nV_reg[2*i][DATA_WIDTH*(3+1)-1:DATA_WIDTH*3]),
		.b_o(nV_reg[2*i][DATA_WIDTH*(7+1)-1:DATA_WIDTH*7]),
		.c_o(nV_reg[2*i][DATA_WIDTH*(11+1)-1:DATA_WIDTH*11]),
		.d_o(nV_reg[2*i][DATA_WIDTH*(15+1)-1:DATA_WIDTH*15])
	);


	mix mix_round4(
		.clk(clk),

		.a(V_reg[2*i+1][DATA_WIDTH*(0+1)-1:DATA_WIDTH*0]),
		.b(V_reg[2*i+1][DATA_WIDTH*(5+1)-1:DATA_WIDTH*5]),
		.c(V_reg[2*i+1][DATA_WIDTH*(10+1)-1:DATA_WIDTH*10]),
		.d(V_reg[2*i+1][DATA_WIDTH*(15+1)-1:DATA_WIDTH*15]),
		.m0(M_reg_temp[8*i+4][sigma[i%10][8]]),
		.m1(M_reg_temp[8*i+4][sigma[i%10][9]]),
		.c0(CB[sigma[i%10][8]]),
		.c1(CB[sigma[i%10][9]]),

		.a_o(nV_reg[2*i+1][DATA_WIDTH*(0+1)-1:DATA_WIDTH*0]),
		.b_o(nV_reg[2*i+1][DATA_WIDTH*(5+1)-1:DATA_WIDTH*5]),
		.c_o(nV_reg[2*i+1][DATA_WIDTH*(10+1)-1:DATA_WIDTH*10]),
		.d_o(nV_reg[2*i+1][DATA_WIDTH*(15+1)-1:DATA_WIDTH*15])
	);

	mix mix_round5(
		.clk(clk),

		.a(V_reg[2*i+1][DATA_WIDTH*(1+1)-1:DATA_WIDTH*1]),
		.b(V_reg[2*i+1][DATA_WIDTH*(6+1)-1:DATA_WIDTH*6]),
		.c(V_reg[2*i+1][DATA_WIDTH*(11+1)-1:DATA_WIDTH*11]),
		.d(V_reg[2*i+1][DATA_WIDTH*(12+1)-1:DATA_WIDTH*12]),
		.m0(M_reg_temp[8*i+4][sigma[i%10][10]]),
		.m1(M_reg_temp[8*i+4][sigma[i%10][11]]),
		.c0(CB[sigma[i%10][10]]),
		.c1(CB[sigma[i%10][11]]),

		.a_o(nV_reg[2*i+1][DATA_WIDTH*(1+1)-1:DATA_WIDTH*1]),
		.b_o(nV_reg[2*i+1][DATA_WIDTH*(6+1)-1:DATA_WIDTH*6]),
		.c_o(nV_reg[2*i+1][DATA_WIDTH*(11+1)-1:DATA_WIDTH*11]),
		.d_o(nV_reg[2*i+1][DATA_WIDTH*(12+1)-1:DATA_WIDTH*12])
	);

	mix mix_round6(
		.clk(clk),

		.a(V_reg[2*i+1][DATA_WIDTH*(2+1)-1:DATA_WIDTH*2]),
		.b(V_reg[2*i+1][DATA_WIDTH*(7+1)-1:DATA_WIDTH*7]),
		.c(V_reg[2*i+1][DATA_WIDTH*(8+1)-1:DATA_WIDTH*8]),
		.d(V_reg[2*i+1][DATA_WIDTH*(13+1)-1:DATA_WIDTH*13]),
		.m0(M_reg_temp[8*i+4][sigma[i%10][12]]),
		.m1(M_reg_temp[8*i+4][sigma[i%10][13]]),
		.c0(CB[sigma[i%10][12]]),
		.c1(CB[sigma[i%10][13]]),

		.a_o(nV_reg[2*i+1][DATA_WIDTH*(2+1)-1:DATA_WIDTH*2]),
		.b_o(nV_reg[2*i+1][DATA_WIDTH*(7+1)-1:DATA_WIDTH*7]),
		.c_o(nV_reg[2*i+1][DATA_WIDTH*(8+1)-1:DATA_WIDTH*8]),
		.d_o(nV_reg[2*i+1][DATA_WIDTH*(13+1)-1:DATA_WIDTH*13])
	);

	mix mix_round7(
		.clk(clk),

		.a(V_reg[2*i+1][DATA_WIDTH*(3+1)-1:DATA_WIDTH*3]),
		.b(V_reg[2*i+1][DATA_WIDTH*(4+1)-1:DATA_WIDTH*4]),
		.c(V_reg[2*i+1][DATA_WIDTH*(9+1)-1:DATA_WIDTH*9]),
		.d(V_reg[2*i+1][DATA_WIDTH*(14+1)-1:DATA_WIDTH*14]),
		.m0(M_reg_temp[8*i+4][sigma[i%10][14]]),
		.m1(M_reg_temp[8*i+4][sigma[i%10][15]]),
		.c0(CB[sigma[i%10][14]]),
		.c1(CB[sigma[i%10][15]]),

		.a_o(nV_reg[2*i+1][DATA_WIDTH*(3+1)-1:DATA_WIDTH*3]),
		.b_o(nV_reg[2*i+1][DATA_WIDTH*(4+1)-1:DATA_WIDTH*4]),
		.c_o(nV_reg[2*i+1][DATA_WIDTH*(9+1)-1:DATA_WIDTH*9]),
		.d_o(nV_reg[2*i+1][DATA_WIDTH*(14+1)-1:DATA_WIDTH*14])
	);

end
endgenerate
/////////////////////
generate
for (i = 0; i < STATE_ARRAY_SIZE; i = i + 1) begin 
	always @(posedge clk)
		begin
			ht[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] <= H_reg[112][DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] ^ nV_reg[27][DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] ^ nV_reg[27][DATA_WIDTH*(i+1 + 8)-1:DATA_WIDTH*(i+8)];
		end
end
endgenerate
/////////////////////
endmodule
////////////////////////////////////////
`timescale 1ns / 1ps
module mix(
	input clk,

	input [DATA_WIDTH-1:0] a,
	input [DATA_WIDTH-1:0] b,
	input [DATA_WIDTH-1:0] c,
	input [DATA_WIDTH-1:0] d,
	input [DATA_WIDTH-1:0] m0,
	input [DATA_WIDTH-1:0] m1,
	input [DATA_WIDTH-1:0] c0,
	input [DATA_WIDTH-1:0] c1,
	
	output [DATA_WIDTH-1:0] a_o,
	output [DATA_WIDTH-1:0] b_o,
	output [DATA_WIDTH-1:0] c_o,
	output [DATA_WIDTH-1:0] d_o
    );
/////////////////////
parameter DATA_WIDTH = 32;
/////////////////////
reg [DATA_WIDTH-1:0] a_temp[0:3], b_temp[0:3], c_temp[0:3], d_temp[0:3], m1_temp[0:1], c0_temp[0:1];
reg [DATA_WIDTH-1:0] na_temp[0:3], nb_temp[0:3], nc_temp[0:3], nd_temp[0:3], nm1_temp[0:1], nc0_temp[0:1];
/////////////////////
integer i;
always @(posedge clk)
begin
	for (i = 0; i < 4; i = i + 1)
		begin
			b_temp[i] <= nb_temp[i];
			c_temp[i] <= nc_temp[i];
		end	
		
	for (i = 0; i < 4; i = i + 1)
		begin
			a_temp[i] <= na_temp[i];
			d_temp[i] <= nd_temp[i];
		end
		
	for (i = 0; i < 2; i = i + 1)
		begin
			m1_temp[i] <= nm1_temp[i];
			c0_temp[i] <= nc0_temp[i];
		end
end
/////////////////////
always @*
begin
	//stage1
	na_temp[0] = a + b + (m0 ^ c1);
	nd_temp[0] = ((d ^ na_temp[0]) >> 16) | ((d ^ na_temp[0]) << 16);
	nc_temp[0] = c;
	nb_temp[0] = b;
	nm1_temp[0] = m1;
	nc0_temp[0] = c0;	
	
	//stage2
	na_temp[1] = a_temp[0];
	nd_temp[1] = d_temp[0];
	nc_temp[1] = c_temp[0] + d_temp[0];
	nb_temp[1] = ((b_temp[0] ^ nc_temp[1]) >> 12) | ((b_temp[0] ^ nc_temp[1]) << 20);
	nm1_temp[1] = m1_temp[0];
	nc0_temp[1] = c0_temp[0];	
	
	//stage3
	na_temp[2] = a_temp[1] + b_temp[1] + (m1_temp[1] ^ c0_temp[1]);
	nd_temp[2] = ((d_temp[1] ^ na_temp[2]) >> 8) | ((d_temp[1] ^ na_temp[2]) << 24);
	nc_temp[2] = c_temp[1];
	nb_temp[2] = b_temp[1];
	
	//stage4
	na_temp[3] = a_temp[2];
	nd_temp[3] = d_temp[2];
	nc_temp[3] = c_temp[2] + d_temp[2]; 
	nb_temp[3] = ((b_temp[2] ^ nc_temp[3]) >> 7) | ((b_temp[2] ^ nc_temp[3]) << 25);
end
/////////////////////
assign a_o = a_temp[3];
assign b_o = b_temp[3];
assign c_o = c_temp[3];
assign d_o = d_temp[3];
endmodule
