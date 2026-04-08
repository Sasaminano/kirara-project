// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Mon Mar 30 06:52:18 2026
// Host        : user running 64-bit Ubuntu 24.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/user/Documents/kirara_final_demo/kirara_final_demo.srcs/sources_1/bd/system/ip/system_clk_wiz_1_0/system_clk_wiz_1_0_stub.v
// Design      : system_clk_wiz_1_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module system_clk_wiz_1_0(sys_clk, pix_clk, cam_clk, resetn, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="sys_clk,pix_clk,cam_clk,resetn,locked,clk_in1" */;
  output sys_clk;
  output pix_clk;
  output cam_clk;
  input resetn;
  output locked;
  input clk_in1;
endmodule
