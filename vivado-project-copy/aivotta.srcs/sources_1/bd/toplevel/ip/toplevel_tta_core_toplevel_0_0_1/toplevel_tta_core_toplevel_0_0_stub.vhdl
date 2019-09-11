-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
-- Date        : Thu Sep  5 19:57:05 2019
-- Host        : floran-HP-ZBook-Studio-G5 running 64-bit Ubuntu 19.04
-- Command     : write_vhdl -force -mode synth_stub
--               /home/floran/Vivado/aivotta/aivotta.srcs/sources_1/bd/toplevel/ip/toplevel_tta_core_toplevel_0_0_1/toplevel_tta_core_toplevel_0_0_stub.vhdl
-- Design      : toplevel_tta_core_toplevel_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity toplevel_tta_core_toplevel_0_0 is
  Port ( 
    clk : in STD_LOGIC;
    rstx : in STD_LOGIC;
    s_axi_awid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 18 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_arid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_araddr : in STD_LOGIC_VECTOR ( 18 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    locked : out STD_LOGIC;
    fu_DMA_m_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    fu_DMA_m_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    fu_DMA_m_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    fu_DMA_m_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    fu_DMA_m_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    fu_DMA_m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    fu_DMA_m_axi_awvalid : out STD_LOGIC;
    fu_DMA_m_axi_awready : in STD_LOGIC;
    fu_DMA_m_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    fu_DMA_m_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    fu_DMA_m_axi_wlast : out STD_LOGIC;
    fu_DMA_m_axi_wvalid : out STD_LOGIC;
    fu_DMA_m_axi_wready : in STD_LOGIC;
    fu_DMA_m_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    fu_DMA_m_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    fu_DMA_m_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    fu_DMA_m_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    fu_DMA_m_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    fu_DMA_m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    fu_DMA_m_axi_arvalid : out STD_LOGIC;
    fu_DMA_m_axi_arready : in STD_LOGIC;
    fu_DMA_m_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    fu_DMA_m_axi_rvalid : in STD_LOGIC;
    fu_DMA_m_axi_rready : out STD_LOGIC;
    fu_DMA_m_axi_bvalid : in STD_LOGIC;
    fu_DMA_m_axi_bready : out STD_LOGIC;
    fu_DMA_m_axi_rlast : in STD_LOGIC
  );

end toplevel_tta_core_toplevel_0_0;

architecture stub of toplevel_tta_core_toplevel_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,rstx,s_axi_awid[11:0],s_axi_awaddr[18:0],s_axi_awlen[7:0],s_axi_awsize[2:0],s_axi_awburst[1:0],s_axi_awvalid,s_axi_awready,s_axi_wdata[31:0],s_axi_wstrb[3:0],s_axi_wvalid,s_axi_wready,s_axi_bid[11:0],s_axi_bresp[1:0],s_axi_bvalid,s_axi_bready,s_axi_arid[11:0],s_axi_araddr[18:0],s_axi_arlen[7:0],s_axi_arsize[2:0],s_axi_arburst[1:0],s_axi_arvalid,s_axi_arready,s_axi_rid[11:0],s_axi_rdata[31:0],s_axi_rresp[1:0],s_axi_rlast,s_axi_rvalid,s_axi_rready,locked,fu_DMA_m_axi_awaddr[31:0],fu_DMA_m_axi_awcache[3:0],fu_DMA_m_axi_awlen[7:0],fu_DMA_m_axi_awsize[2:0],fu_DMA_m_axi_awburst[1:0],fu_DMA_m_axi_awprot[2:0],fu_DMA_m_axi_awvalid,fu_DMA_m_axi_awready,fu_DMA_m_axi_wdata[31:0],fu_DMA_m_axi_wstrb[3:0],fu_DMA_m_axi_wlast,fu_DMA_m_axi_wvalid,fu_DMA_m_axi_wready,fu_DMA_m_axi_araddr[31:0],fu_DMA_m_axi_arcache[3:0],fu_DMA_m_axi_arlen[7:0],fu_DMA_m_axi_arsize[2:0],fu_DMA_m_axi_arburst[1:0],fu_DMA_m_axi_arprot[2:0],fu_DMA_m_axi_arvalid,fu_DMA_m_axi_arready,fu_DMA_m_axi_rdata[31:0],fu_DMA_m_axi_rvalid,fu_DMA_m_axi_rready,fu_DMA_m_axi_bvalid,fu_DMA_m_axi_bready,fu_DMA_m_axi_rlast";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "tta_core_toplevel,Vivado 2018.2";
begin
end;