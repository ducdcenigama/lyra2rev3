//---------------------------------------------------------------
// file: mmcm_blk.v
// 
// (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// clk_out1___125.000______0.000______50.0_______95.671_____73.940
// clk_out2___250.000______0.000______50.0_______91.831_____73.940
// clk_out3___300.000______0.000______50.0_______88.814_____73.940
// clk_out4___350.000______0.000______50.0_______87.118_____73.940
// clk_out5___400.000______0.000______50.0_______85.263_____73.940
// clk_out6___450.000______0.000______50.0_______83.210_____73.940
// clk_out7___500.000______0.000______50.0_______80.905_____73.940
// clk_out8___550.000______0.000______50.0_______95.671_____73.940
// clk_out9___600.000______0.000______50.0_______91.831_____73.940
// clk_outA___650.000______0.000______50.0_______88.814_____73.940

//
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_________125.000____________0.010

//`timescale 1ps/1ps

module mmcm_blk

 (// Clock in ports
  // Clock out ports
  output        clk_out0,
  //output        clk_out2,
  //output        clk_out3,
  //output        clk_out4,
  //output        clk_out5,
  //output        clk_out6,
  //output        clk_out7,
  // Status and control signals
  input         resetn,
  //output        locked,
  input         clk_in1,
  input [3:0] 	clk_sel,
  input  	core_clk_enb
  );
  // Input buffering
  //------------------------------------
wire clk_in1_obf;
//wire clk_in2_clk_wiz_0;
  IBUF clkin1_ibuf
   (.O (clk_in1_obf),
    .I (clk_in1));


//----------------------------------------------------------------------------
// Clocking wiz_1
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// clk_out1___300.000______0.000______50.0______152.330____222.305
// clk_out2___600.000______0.000______50.0______138.255____222.305
// clk_out3___400.000______0.000______50.0______146.303____222.305
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_________125.000____________0.010
//------------------------------------
//wire clk_in1_clk_wiz_1;
//wire clk_in2_clk_wiz_1;
//  IBUF clkin1_ibuf
//   (.O (clk_in1_clk_wiz_1),
//    .I (clk_in1));
  wire        clk_out1_clk_wiz_1;
  wire        clk_out2_clk_wiz_1;
  wire        clk_out3_clk_wiz_1;
//  wire        clk_out4_clk_wiz_1;
//  wire        clk_out5_clk_wiz_1;
//  wire        clk_out6_clk_wiz_1;
//  wire        clk_out7_clk_wiz_1;

//  wire [15:0] 	do_unused;
//  wire        	drdy_unused;
//  wire        	psdone_unused;
  wire        	locked_int;
  wire        	clkfbout_clk_wiz_1;
//  wire        	clkfboutb_unused;
//  wire 			clkout0b_unused;
//  wire clkout1b_unused;
//  wire clkout2b_unused;
//  wire clkout3_unused;
//  wire clkout3b_unused;
//  wire clkout4_unused;
//  wire        clkout5_unused;
//  wire        clkout6_unused;
//  wire        clkfbstopped_unused;
//  wire        clkinstopped_unused;
  wire        reset_high;


    MMCME4_ADV

  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("AUTO"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (5),
    .CLKFBOUT_MULT_F      (48.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (8.000),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (4),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKOUT2_DIVIDE       (6),
    .CLKOUT2_PHASE        (0.000),
    .CLKOUT2_DUTY_CYCLE   (0.500),
    .CLKOUT2_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (8.000))
  
  mmcme4_adv_inst01
    // Output clocks
   (
    .CLKFBOUT            (clkfbout_clk_wiz_1),
//    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (clk_out1_clk_wiz_1),
//    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (clk_out2_clk_wiz_1),
//    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clk_out3_clk_wiz_1),
//    .CLKOUT2B            (clkout2b_unused),
//    .CLKOUT3             (clkout3_unused),
//    .CLKOUT3B            (clkout3b_unused),
//    .CLKOUT4             (clkout4_unused),
//    .CLKOUT5             (clkout5_unused),
//    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_clk_wiz_1),
    .CLKIN1              (clk_in1_obf),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
//    .DO                  (do_unused),
//    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    .CDDCDONE            (),
    .CDDCREQ             (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
//    .PSDONE              (psdone_unused),
    // Other control and status signals
//    .LOCKED              (locked_int),
//    .CLKINSTOPPED        (clkinstopped_unused),
//    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (reset_high));
	
  assign reset_high = ~resetn; 
  //assign locked = locked_int;
  


//for the clock output
reg clk_t;

always@(*)
begin
	case (clk_sel[3:0])
		4'h0:clk_t=clk_in1_obf;  		//125-
		4'h1:clk_t=clk_out1_clk_wiz_1;	//300-
		4'h2:clk_t=clk_out3_clk_wiz_1;	//400-
		4'h3:clk_t=clk_out2_clk_wiz_1;	//600-
		default:clk_t=clk_in1_obf		;//125
	endcase
end


  BUFGCE_DIV
 #(
      .BUFGCE_DIVIDE(1),      // 1-8
      // Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
      .IS_CE_INVERTED(1'b0),  // Optional inversion for CE
      .IS_CLR_INVERTED(1'b0), // Optional inversion for CLR
      .IS_I_INVERTED(1'b0)    // Optional inversion for I
   )
  clkout0_buf
   (.O   (clk_out0),
    .CE  (core_clk_enb),   // 1-bit input: Buffer enable
    .CLR (reset_high),
    .I   (clk_t));
	
endmodule
