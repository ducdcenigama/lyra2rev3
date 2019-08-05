`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2019 01:45:36 PM
// Design Name: 
// Module Name: miner_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module miner_tb(
);

reg clk = 0;
reg reset = 0;

reg [639:0] block = 0;
reg [31 :0] nonce_start = 0;
reg [31 :0] nonce_stop = 100;

wire nonce_found;
wire core_stop;
wire [31:0] nonce_out;

miner miner_inst(clk, reset, block, nonce_start, nonce_stop, nonce_found, core_stop, nonce_out);

always #10 clk = ~clk;

initial
begin
    reset = 1;
    #1000;
    reset = 0;
    #1000;
    reset = 0;
end

endmodule
