// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Wed Jul 13 18:12:47 2022
// Host        : mcassinerio running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/mcassinerio/Documents/GitHub/HTGK7-NRCA-DMA/HTGK7-NRCA-DMA.srcs/sources_1/ip/bar_ram/bar_ram_stub.v
// Design      : bar_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tfbg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_3,Vivado 2019.1" *)
module bar_ram(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[7:0],dina[63:0],clkb,addrb[7:0],doutb[63:0]" */;
  input clka;
  input [0:0]wea;
  input [7:0]addra;
  input [63:0]dina;
  input clkb;
  input [7:0]addrb;
  output [63:0]doutb;
endmodule
