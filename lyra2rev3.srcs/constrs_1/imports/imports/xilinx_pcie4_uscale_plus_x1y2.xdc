#set_property MARK_DEBUG false [get_nets pcie4_uscale_plus_0_i/inst/store_ltssm]
##-----------------------------------------------------------------------------
##
## (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
##
## Project    : UltraScale+ FPGA PCI Express v4.0 Integrated Block
## File       : xilinx_pcie4_uscale_plus_x1y2.xdc
## Version    : 1.3
##-----------------------------------------------------------------------------
#
###############################################################################
# Vivado - PCIe GUI / User Configuration
###############################################################################
#
# Link Speed   - Gen2 - Gb/s
# Link Width   - X4
# AXIST Width  - 128-bit
# AXIST Frequ  - 125 MHz = User Clock
# Core Clock   - 250 MHz
# Pipe Clock   - 125 MHz (Gen1) / 250 MHz (Gen2/Gen3/Gen4)
#
# Family       - virtexuplus
# Part         - xcvu9p
# Package      - fsgd2104
# Speed grade  - -2L
# PCIe Block   - X1Y2
# Xilinx Reference Board is VCU1525
#
#
# PLL TYPE     - QPLL1
#
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
#
set_property PULLUP true [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
set_property PACKAGE_PIN BD21 [get_ports sys_rst_n]
#
set_property PACKAGE_PIN AM10 [get_ports sys_clk_n]
set_property PACKAGE_PIN AM11 [get_ports sys_clk_p]
#
#
#
#
#
# CLOCK_ROOT LOCKing to Reduce CLOCK SKEW
# Add/Edit  Clock Routing Option to improve clock path skew
#
# BITFILE/BITSTREAM compress options
# Flash type constraints. These should be modified to match the target board.
#
#
#
# sys_clk vs TXOUTCLK
#
#
#
#
#
#
# ASYNC CLOCK GROUPINGS
# sys_clk vs user_clk
#
#
# Timing improvement
# Add/Edit Pblock slice constraints for init_ctr module to improve timing
#create_pblock init_ctr_rst; add_cells_to_pblock [get_pblocks init_ctr_rst] [get_cells pcie4_uscale_plus_0_i/inst/pcie_4_0_pipe_inst/pcie_4_0_init_ctrl_inst]
# Keep This Logic Left/Right Side Of The PCIe Block (Whichever is near to the FPGA Boundary)
#resize_pblock [get_pblocks init_ctr_rst] -add {SLICE_X157Y300:SLICE_X168Y370}
#










#set_multicycle_path -setup -start -rise_to [get_pins {pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/monero_top/u_core_*/u_monreo/u_phase2/mul_16b*/DSP_OUTPUT_INST/ALU_OUT[*]}] 2
#set_multicycle_path -setup -start -rise_to [get_pins pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/monero_top/u_core_*/u_monreo/u_phase2/mul_16b*/D] 2

#set_property MARK_DEBUG true [get_nets pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/monero_top/u_mmcm_blk/user_clk]
#create_generated_clock -name clk_DLL -source [get_pins pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/user_clk] -multiply_by 2 -add -master_clock user_clk [get_pins -hierarchical **u_mmcm_blk*/CLK*]




create_clock -period 10.000 -name sys_clk [get_ports sys_clk_p]
set_false_path -from [get_ports sys_rst_n]
set_clock_groups -name async18 -asynchronous -group [get_clocks sys_clk] -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gtye4_channel_inst[*].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -name async19 -asynchronous -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gtye4_channel_inst[*].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks sys_clk]
set_clock_groups -name async5 -asynchronous -group [get_clocks sys_clk] -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_clock_groups -name async6 -asynchronous -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks sys_clk]
set_clock_groups -name async24 -asynchronous -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_intclk/O]] -group [get_clocks sys_clk]
#create_clock -period 3.600 -name clk_DLL -waveform {0.000 1.800} [get_pins pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/monero_top/u_mmcm_blk/clkout1_buf/O]


set_false_path -through [get_nets -hierarchical -regexp .*softreset_sig.*]
#set_false_path -through [get_nets -hierarchical -regexp .*softreset_sig.*]

set_property CONFIG_MODE SPIx4 [current_design]

#create_clock -period 4.000 -name clk_DLL -waveform {0.000 2.000} [get_pins pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/monero_top/u_mmcm_blk/clkout1_buf/O]
#create_clock -period 3.600 -name clk_DLL -waveform {0.000 1.800} [get_pins pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/monero_top/u_mmcm_blk/clkout1_buf/O]
create_clock -period 8.000 -name clk_DLL0 -waveform {0.000 4.000} [get_pins pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_mmcm_blk/clkout0_buf/O]


set_false_path -from [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks clk_DLL*]
set_false_path -from [get_clocks *clk_DLL*] -to [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks *user_clk*] -to [get_clocks {*clk_DLL*}]
set_false_path -from [get_clocks {*clk_DLL*}] -to [get_clocks *user_clk*]
set_false_path -from [get_clocks *sys_clk*] -to [get_clocks {*clk_DLL*}]
set_false_path -from [get_clocks {*clk_DLL*}] -to [get_clocks *sys_clk*]

#set_property BEL BUFCE [get_cells pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_mmcm_blk/clk_out1_clk_wiz_5_BUFG_inst]
#set_property LOC BUFGCE_X1Y229 [get_cells pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_mmcm_blk/clk_out1_clk_wiz_5_BUFG_inst]

set_false_path -through [get_nets -hierarchical *coreRstF1*]
set_false_path -from [get_pins {pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_tribus_regs/DLL_ctrl_reg[*]/C}]
set_false_path -through [get_pins {pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_tribus_regs/clk_sel*}]
set_false_path -through [get_pins {pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_tribus_regs/core_clk_enb*}]
set_false_path -through [get_pins {pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_tribus_regs/coreRst*}]
set_false_path -through [get_pins {pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_tribus_regs/softreset_sig*}]
set_false_path -from [get_pins pcie4_uscale_plus_0_i/inst/user_reset_reg/C] -to [get_pins pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_mmcm_blk/clkout*_buf/CLR]
set_false_path -through [get_pins pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_core_00/u_tribus_miner/reset_f_reg/C]
 

#set_false_path -from [get_pins {set_false_path -from [get_pins {pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_tribus_regs/DLL_ctrl_reg[*]/C}]}]

#set_clock_uncertainty 0.200 [get_pins -hierarchical *clk_DLL*]

#create_pblock pblock_u_core_02
#add_cells_to_pblock [get_pblocks pblock_u_core_02] [get_cells -quiet [list pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_core_02]]
#resize_pblock [get_pblocks pblock_u_core_02] -add {CLOCKREGION_X0Y0:CLOCKREGION_X5Y4}
#create_pblock pblock_u_core_00
#add_cells_to_pblock [get_pblocks pblock_u_core_00] [get_cells -quiet [list pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/ep_xpm_sdpram/tribus_top/u_core_00]]
#resize_pblock [get_pblocks pblock_u_core_00] -add {CLOCKREGION_X0Y10:CLOCKREGION_X5Y14}





