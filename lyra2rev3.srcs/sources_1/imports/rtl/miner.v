/*
 * Copyright (c) 2017 Sprocket
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License with
 * additional permissions to the one published by the Free Software
 * Foundation, either version 3 of the License, or (at your option)
 * any later version. For more information see LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
`timescale 1ns / 1ps

module miner # (parameter CORES = 32'd1)
(
   input  clk,
   input  reset,

   input [639:0] block,
   input [31 :0] nonce_start,
   input [31 :0] nonce_stop,

   output        nonce_found,
   output        core_stop,
   output[31 :0] nonce_out
);
   localparam OFFSET = 32'd425;

   wire[31 :0] hash;


   wire [607 :0] midstate;
   wire [31 :0] target;
   reg [31 :0] nonce;
   reg [31 :0] nonce_out;
   reg         nonce_found;
   reg         reset_f;
   wire reset_q;
   reg         hash_stp_d1;

   reg [10:0] cnt;
   wire      hash_stp;
   
   reg state = 0;

   assign core_stop = (nonce_out == nonce_stop) & (~hash_stp_d1);

   assign midstate = block[639:32];
   assign target = block[31:0];

   lyra2rev3 lyra2rev3_inst(clk, {nonce[7:0], nonce[15:8], nonce[23:16], nonce[31:24], midstate}, hash);

   always @(posedge clk)
      if(reset_q)
              state <= 0;
      else
              state <= ~state;

always@(posedge clk) begin
      if(reset_q)
              cnt <= 0;
      else if ((state) && cnt < OFFSET)
              cnt <= cnt + 1;
end

   assign hash_stp = (cnt < (OFFSET-1));

   always@(posedge clk)
      	hash_stp_d1 <= hash_stp;

   always@(posedge clk) reset_f <= reset;
   BUFG u_reset_buf (.I(reset_f), .O(reset_q));

   always@(posedge clk) begin
      	if(reset_q)
      		nonce <= nonce_start;
      	else
      	if (state)
      		nonce <= nonce + 1'b1;
   end

   always@(posedge clk) begin
	   if(reset_q) 
            	nonce_found <= 1'b0;
	   else 
	   if(state)
	   begin
                if(hash <= target)
                	nonce_found <= ~hash_stp_d1;
                else
                	nonce_found <= 1'b0;
           end
   end

   always@(posedge clk) begin
	   if(reset_q) 
            	nonce_out <= nonce_start - OFFSET + 1;
	   else 
	   if (state)
                nonce_out <= nonce_out + 1'b1;
   end

endmodule
