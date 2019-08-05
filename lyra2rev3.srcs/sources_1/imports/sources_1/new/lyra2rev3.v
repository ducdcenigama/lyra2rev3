`timescale 1ns / 1ps
module lyra2rev3(
    input clk,
    input [639:0] data,
    output reg [31:0] hash
    );
wire [255:0] blake_hash, lyra2_hash_in, lyra2_hash_out, cube_hash, bmw_hash;
blake blake_inst(clk, data, blake_hash);

reg state = 0;

always @(posedge clk)
    state <= ~state;
    
assign lyra2_hash_in = (~state) ? blake_hash : cube_hash;

lyra2 lyra2_inst0(clk, lyra2_hash_in, lyra2_hash_out);

cubehash cubehash_inst(clk, lyra2_hash_out, cube_hash);

bmw bmw_inst(clk, lyra2_hash_out, bmw_hash);

always @(posedge clk)
    hash <= bmw_hash[255:224];
endmodule
