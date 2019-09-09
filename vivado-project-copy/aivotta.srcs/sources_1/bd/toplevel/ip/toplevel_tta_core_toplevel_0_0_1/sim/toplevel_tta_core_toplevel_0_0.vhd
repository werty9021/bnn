-- (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:module_ref:tta_core_toplevel:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY toplevel_tta_core_toplevel_0_0 IS
  PORT (
    clk : IN STD_LOGIC;
    rstx : IN STD_LOGIC;
    s_axi_awid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s_axi_awaddr : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
    s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_awready : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_wvalid : IN STD_LOGIC;
    s_axi_wready : OUT STD_LOGIC;
    s_axi_bid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_arid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s_axi_araddr : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
    s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_arready : OUT STD_LOGIC;
    s_axi_rid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rlast : OUT STD_LOGIC;
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_rready : IN STD_LOGIC;
    locked : OUT STD_LOGIC;
    fu_DMA_m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    fu_DMA_m_axi_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    fu_DMA_m_axi_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    fu_DMA_m_axi_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    fu_DMA_m_axi_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    fu_DMA_m_axi_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    fu_DMA_m_axi_awvalid : OUT STD_LOGIC;
    fu_DMA_m_axi_awready : IN STD_LOGIC;
    fu_DMA_m_axi_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    fu_DMA_m_axi_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    fu_DMA_m_axi_wlast : OUT STD_LOGIC;
    fu_DMA_m_axi_wvalid : OUT STD_LOGIC;
    fu_DMA_m_axi_wready : IN STD_LOGIC;
    fu_DMA_m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    fu_DMA_m_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    fu_DMA_m_axi_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    fu_DMA_m_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    fu_DMA_m_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    fu_DMA_m_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    fu_DMA_m_axi_arvalid : OUT STD_LOGIC;
    fu_DMA_m_axi_arready : IN STD_LOGIC;
    fu_DMA_m_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    fu_DMA_m_axi_rvalid : IN STD_LOGIC;
    fu_DMA_m_axi_rready : OUT STD_LOGIC;
    fu_DMA_m_axi_bvalid : IN STD_LOGIC;
    fu_DMA_m_axi_bready : OUT STD_LOGIC;
    fu_DMA_m_axi_rlast : IN STD_LOGIC
  );
END toplevel_tta_core_toplevel_0_0;

ARCHITECTURE toplevel_tta_core_toplevel_0_0_arch OF toplevel_tta_core_toplevel_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF toplevel_tta_core_toplevel_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT tta_core_toplevel IS
    GENERIC (
      axi_addr_width_g : INTEGER;
      axi_id_width_g : INTEGER;
      local_mem_addrw_g : INTEGER
    );
    PORT (
      clk : IN STD_LOGIC;
      rstx : IN STD_LOGIC;
      s_axi_awid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      s_axi_awaddr : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
      s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_awvalid : IN STD_LOGIC;
      s_axi_awready : OUT STD_LOGIC;
      s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_wvalid : IN STD_LOGIC;
      s_axi_wready : OUT STD_LOGIC;
      s_axi_bid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_bvalid : OUT STD_LOGIC;
      s_axi_bready : IN STD_LOGIC;
      s_axi_arid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      s_axi_araddr : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
      s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_arvalid : IN STD_LOGIC;
      s_axi_arready : OUT STD_LOGIC;
      s_axi_rid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_rlast : OUT STD_LOGIC;
      s_axi_rvalid : OUT STD_LOGIC;
      s_axi_rready : IN STD_LOGIC;
      locked : OUT STD_LOGIC;
      fu_DMA_m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      fu_DMA_m_axi_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      fu_DMA_m_axi_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      fu_DMA_m_axi_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      fu_DMA_m_axi_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      fu_DMA_m_axi_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      fu_DMA_m_axi_awvalid : OUT STD_LOGIC;
      fu_DMA_m_axi_awready : IN STD_LOGIC;
      fu_DMA_m_axi_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      fu_DMA_m_axi_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      fu_DMA_m_axi_wlast : OUT STD_LOGIC;
      fu_DMA_m_axi_wvalid : OUT STD_LOGIC;
      fu_DMA_m_axi_wready : IN STD_LOGIC;
      fu_DMA_m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      fu_DMA_m_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      fu_DMA_m_axi_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      fu_DMA_m_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      fu_DMA_m_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      fu_DMA_m_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      fu_DMA_m_axi_arvalid : OUT STD_LOGIC;
      fu_DMA_m_axi_arready : IN STD_LOGIC;
      fu_DMA_m_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      fu_DMA_m_axi_rvalid : IN STD_LOGIC;
      fu_DMA_m_axi_rready : OUT STD_LOGIC;
      fu_DMA_m_axi_bvalid : IN STD_LOGIC;
      fu_DMA_m_axi_bready : OUT STD_LOGIC;
      fu_DMA_m_axi_rlast : IN STD_LOGIC
    );
  END COMPONENT tta_core_toplevel;
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF toplevel_tta_core_toplevel_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_rlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi RLAST";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_arburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi ARBURST";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_arsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi ARSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_arlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi ARLEN";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_arcache: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi ARCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_wlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi WLAST";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi AWPROT";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_awburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi AWBURST";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_awsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi AWSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_awlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi AWLEN";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_awcache: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi AWCACHE";
  ATTRIBUTE X_INTERFACE_PARAMETER OF fu_DMA_m_axi_awaddr: SIGNAL IS "XIL_INTERFACENAME fu_DMA_m_axi, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 66666672, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 0, HAS_RRESP 0, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN toplevel_processing_system7_0_0_FCLK_CLK0, NUM_READ_TH" & 
"READS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0";
  ATTRIBUTE X_INTERFACE_INFO OF fu_DMA_m_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 fu_DMA_m_axi AWADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi RLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi RID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi ARBURST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi ARSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi ARLEN";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi ARID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi BID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi AWBURST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi AWSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi AWLEN";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi AWADDR";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_axi_awid: SIGNAL IS "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 66666672, ID_WIDTH 12, ADDR_WIDTH 19, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN toplevel_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS " & 
"1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi AWID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF clk: SIGNAL IS "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF fu_DMA_m_axi:s_axi, FREQ_HZ 66666672, PHASE 0.000, CLK_DOMAIN toplevel_processing_system7_0_0_FCLK_CLK0";
  ATTRIBUTE X_INTERFACE_INFO OF clk: SIGNAL IS "xilinx.com:signal:clock:1.0 clk CLK";
BEGIN
  U0 : tta_core_toplevel
    GENERIC MAP (
      axi_addr_width_g => 19,
      axi_id_width_g => 12,
      local_mem_addrw_g => 0
    )
    PORT MAP (
      clk => clk,
      rstx => rstx,
      s_axi_awid => s_axi_awid,
      s_axi_awaddr => s_axi_awaddr,
      s_axi_awlen => s_axi_awlen,
      s_axi_awsize => s_axi_awsize,
      s_axi_awburst => s_axi_awburst,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,
      s_axi_wdata => s_axi_wdata,
      s_axi_wstrb => s_axi_wstrb,
      s_axi_wvalid => s_axi_wvalid,
      s_axi_wready => s_axi_wready,
      s_axi_bid => s_axi_bid,
      s_axi_bresp => s_axi_bresp,
      s_axi_bvalid => s_axi_bvalid,
      s_axi_bready => s_axi_bready,
      s_axi_arid => s_axi_arid,
      s_axi_araddr => s_axi_araddr,
      s_axi_arlen => s_axi_arlen,
      s_axi_arsize => s_axi_arsize,
      s_axi_arburst => s_axi_arburst,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,
      s_axi_rid => s_axi_rid,
      s_axi_rdata => s_axi_rdata,
      s_axi_rresp => s_axi_rresp,
      s_axi_rlast => s_axi_rlast,
      s_axi_rvalid => s_axi_rvalid,
      s_axi_rready => s_axi_rready,
      locked => locked,
      fu_DMA_m_axi_awaddr => fu_DMA_m_axi_awaddr,
      fu_DMA_m_axi_awcache => fu_DMA_m_axi_awcache,
      fu_DMA_m_axi_awlen => fu_DMA_m_axi_awlen,
      fu_DMA_m_axi_awsize => fu_DMA_m_axi_awsize,
      fu_DMA_m_axi_awburst => fu_DMA_m_axi_awburst,
      fu_DMA_m_axi_awprot => fu_DMA_m_axi_awprot,
      fu_DMA_m_axi_awvalid => fu_DMA_m_axi_awvalid,
      fu_DMA_m_axi_awready => fu_DMA_m_axi_awready,
      fu_DMA_m_axi_wdata => fu_DMA_m_axi_wdata,
      fu_DMA_m_axi_wstrb => fu_DMA_m_axi_wstrb,
      fu_DMA_m_axi_wlast => fu_DMA_m_axi_wlast,
      fu_DMA_m_axi_wvalid => fu_DMA_m_axi_wvalid,
      fu_DMA_m_axi_wready => fu_DMA_m_axi_wready,
      fu_DMA_m_axi_araddr => fu_DMA_m_axi_araddr,
      fu_DMA_m_axi_arcache => fu_DMA_m_axi_arcache,
      fu_DMA_m_axi_arlen => fu_DMA_m_axi_arlen,
      fu_DMA_m_axi_arsize => fu_DMA_m_axi_arsize,
      fu_DMA_m_axi_arburst => fu_DMA_m_axi_arburst,
      fu_DMA_m_axi_arprot => fu_DMA_m_axi_arprot,
      fu_DMA_m_axi_arvalid => fu_DMA_m_axi_arvalid,
      fu_DMA_m_axi_arready => fu_DMA_m_axi_arready,
      fu_DMA_m_axi_rdata => fu_DMA_m_axi_rdata,
      fu_DMA_m_axi_rvalid => fu_DMA_m_axi_rvalid,
      fu_DMA_m_axi_rready => fu_DMA_m_axi_rready,
      fu_DMA_m_axi_bvalid => fu_DMA_m_axi_bvalid,
      fu_DMA_m_axi_bready => fu_DMA_m_axi_bready,
      fu_DMA_m_axi_rlast => fu_DMA_m_axi_rlast
    );
END toplevel_tta_core_toplevel_0_0_arch;
