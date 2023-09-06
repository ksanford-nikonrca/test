// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Thu Jul 14 09:00:20 2022
// Host        : mcassinerio running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/mcassinerio/Documents/GitHub/HTGK7-NRCA-DMA/HTGK7-NRCA-DMA.srcs/sources_1/ip/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tfbg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "ila,Vivado 2019.1" *)
module ila_0(clk, trig_in, trig_in_ack, probe0, probe1, probe2, 
  probe3, probe4, probe5)
/* synthesis syn_black_box black_box_pad_pin="clk,trig_in,trig_in_ack,probe0[63:0],probe1[7:0],probe2[0:0],probe3[0:0],probe4[0:0],probe5[21:0]" */;
  input clk;
  input trig_in;
  output trig_in_ack;
  input [63:0]probe0;
  input [7:0]probe1;
  input [0:0]probe2;
  input [0:0]probe3;
  input [0:0]probe4;
  input [21:0]probe5;
endmodule
