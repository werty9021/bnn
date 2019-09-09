// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
// Date        : Thu Sep  5 19:56:47 2019
// Host        : floran-HP-ZBook-Studio-G5 running 64-bit Ubuntu 19.04
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ toplevel_tta_core_toplevel_0_0_stub.v
// Design      : toplevel_tta_core_toplevel_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "tta_core_toplevel,Vivado 2018.2" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk, rstx, s_axi_awid, s_axi_awaddr, s_axi_awlen, 
  s_axi_awsize, s_axi_awburst, s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb, 
  s_axi_wvalid, s_axi_wready, s_axi_bid, s_axi_bresp, s_axi_bvalid, s_axi_bready, s_axi_arid, 
  s_axi_araddr, s_axi_arlen, s_axi_arsize, s_axi_arburst, s_axi_arvalid, s_axi_arready, 
  s_axi_rid, s_axi_rdata, s_axi_rresp, s_axi_rlast, s_axi_rvalid, s_axi_rready, locked, 
  fu_DMA_m_axi_awaddr, fu_DMA_m_axi_awcache, fu_DMA_m_axi_awlen, fu_DMA_m_axi_awsize, 
  fu_DMA_m_axi_awburst, fu_DMA_m_axi_awprot, fu_DMA_m_axi_awvalid, fu_DMA_m_axi_awready, 
  fu_DMA_m_axi_wdata, fu_DMA_m_axi_wstrb, fu_DMA_m_axi_wlast, fu_DMA_m_axi_wvalid, 
  fu_DMA_m_axi_wready, fu_DMA_m_axi_araddr, fu_DMA_m_axi_arcache, fu_DMA_m_axi_arlen, 
  fu_DMA_m_axi_arsize, fu_DMA_m_axi_arburst, fu_DMA_m_axi_arprot, fu_DMA_m_axi_arvalid, 
  fu_DMA_m_axi_arready, fu_DMA_m_axi_rdata, fu_DMA_m_axi_rvalid, fu_DMA_m_axi_rready, 
  fu_DMA_m_axi_bvalid, fu_DMA_m_axi_bready, fu_DMA_m_axi_rlast)
/* synthesis syn_black_box black_box_pad_pin="clk,rstx,s_axi_awid[11:0],s_axi_awaddr[18:0],s_axi_awlen[7:0],s_axi_awsize[2:0],s_axi_awburst[1:0],s_axi_awvalid,s_axi_awready,s_axi_wdata[31:0],s_axi_wstrb[3:0],s_axi_wvalid,s_axi_wready,s_axi_bid[11:0],s_axi_bresp[1:0],s_axi_bvalid,s_axi_bready,s_axi_arid[11:0],s_axi_araddr[18:0],s_axi_arlen[7:0],s_axi_arsize[2:0],s_axi_arburst[1:0],s_axi_arvalid,s_axi_arready,s_axi_rid[11:0],s_axi_rdata[31:0],s_axi_rresp[1:0],s_axi_rlast,s_axi_rvalid,s_axi_rready,locked,fu_DMA_m_axi_awaddr[31:0],fu_DMA_m_axi_awcache[3:0],fu_DMA_m_axi_awlen[7:0],fu_DMA_m_axi_awsize[2:0],fu_DMA_m_axi_awburst[1:0],fu_DMA_m_axi_awprot[2:0],fu_DMA_m_axi_awvalid,fu_DMA_m_axi_awready,fu_DMA_m_axi_wdata[31:0],fu_DMA_m_axi_wstrb[3:0],fu_DMA_m_axi_wlast,fu_DMA_m_axi_wvalid,fu_DMA_m_axi_wready,fu_DMA_m_axi_araddr[31:0],fu_DMA_m_axi_arcache[3:0],fu_DMA_m_axi_arlen[7:0],fu_DMA_m_axi_arsize[2:0],fu_DMA_m_axi_arburst[1:0],fu_DMA_m_axi_arprot[2:0],fu_DMA_m_axi_arvalid,fu_DMA_m_axi_arready,fu_DMA_m_axi_rdata[31:0],fu_DMA_m_axi_rvalid,fu_DMA_m_axi_rready,fu_DMA_m_axi_bvalid,fu_DMA_m_axi_bready,fu_DMA_m_axi_rlast" */;
  input clk;
  input rstx;
  input [11:0]s_axi_awid;
  input [18:0]s_axi_awaddr;
  input [7:0]s_axi_awlen;
  input [2:0]s_axi_awsize;
  input [1:0]s_axi_awburst;
  input s_axi_awvalid;
  output s_axi_awready;
  input [31:0]s_axi_wdata;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;
  output s_axi_wready;
  output [11:0]s_axi_bid;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  input s_axi_bready;
  input [11:0]s_axi_arid;
  input [18:0]s_axi_araddr;
  input [7:0]s_axi_arlen;
  input [2:0]s_axi_arsize;
  input [1:0]s_axi_arburst;
  input s_axi_arvalid;
  output s_axi_arready;
  output [11:0]s_axi_rid;
  output [31:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rlast;
  output s_axi_rvalid;
  input s_axi_rready;
  output locked;
  output [31:0]fu_DMA_m_axi_awaddr;
  output [3:0]fu_DMA_m_axi_awcache;
  output [7:0]fu_DMA_m_axi_awlen;
  output [2:0]fu_DMA_m_axi_awsize;
  output [1:0]fu_DMA_m_axi_awburst;
  output [2:0]fu_DMA_m_axi_awprot;
  output fu_DMA_m_axi_awvalid;
  input fu_DMA_m_axi_awready;
  output [31:0]fu_DMA_m_axi_wdata;
  output [3:0]fu_DMA_m_axi_wstrb;
  output fu_DMA_m_axi_wlast;
  output fu_DMA_m_axi_wvalid;
  input fu_DMA_m_axi_wready;
  output [31:0]fu_DMA_m_axi_araddr;
  output [3:0]fu_DMA_m_axi_arcache;
  output [7:0]fu_DMA_m_axi_arlen;
  output [2:0]fu_DMA_m_axi_arsize;
  output [1:0]fu_DMA_m_axi_arburst;
  output [2:0]fu_DMA_m_axi_arprot;
  output fu_DMA_m_axi_arvalid;
  input fu_DMA_m_axi_arready;
  input [31:0]fu_DMA_m_axi_rdata;
  input fu_DMA_m_axi_rvalid;
  output fu_DMA_m_axi_rready;
  input fu_DMA_m_axi_bvalid;
  output fu_DMA_m_axi_bready;
  input fu_DMA_m_axi_rlast;
endmodule
