 
`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: axi_combiner
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
module axi_combiner #
(
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M_AXI_DATA_WIDTH	= 32
)
(
	/// M_AXI_W
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_awaddr,
	output wire [7 : 0] m_axi_awlen,
	output wire [2 : 0] m_axi_awsize,
	output wire [1 : 0] m_axi_awburst,
	output wire  m_axi_awlock,
	output wire [3 : 0] m_axi_awcache,
	output wire [2 : 0] m_axi_awprot,
	output wire [3 : 0] m_axi_awqos,
	output wire  m_axi_awvalid,
	input wire  m_axi_awready,
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_wdata,
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb,
	output wire  m_axi_wlast,
	output wire  m_axi_wvalid,
	input wire  m_axi_wready,
	input wire [1 : 0] m_axi_bresp,
	input wire  m_axi_bvalid,
	output wire  m_axi_bready,
	// M_AXI_R
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr,
	output wire [7 : 0] m_axi_arlen,
	output wire [2 : 0] m_axi_arsize,
	output wire [1 : 0] m_axi_arburst,
	output wire  m_axi_arlock,
	output wire [3 : 0] m_axi_arcache,
	output wire [2 : 0] m_axi_arprot,
	output wire [3 : 0] m_axi_arqos,
	output wire  m_axi_arvalid,
	input wire  m_axi_arready,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
	input wire [1 : 0] m_axi_rresp,
	input wire  m_axi_rlast,
	input wire  m_axi_rvalid,
	output wire  m_axi_rready,

	/// S_AXI_W
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
	input wire [7 : 0] s_axi_awlen,
	input wire [2 : 0] s_axi_awsize,
	input wire [1 : 0] s_axi_awburst,
	input wire  s_axi_awlock,
	input wire [3 : 0] s_axi_awcache,
	input wire [2 : 0] s_axi_awprot,
	input wire [3 : 0] s_axi_awqos,
	input wire  s_axi_awvalid,
	output wire  s_axi_awready,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
	input wire [C_M_AXI_DATA_WIDTH/8-1 : 0] s_axi_wstrb,
	input wire  s_axi_wlast,
	input wire  s_axi_wvalid,
	output wire  s_axi_wready,
	output wire [1 : 0] s_axi_bresp,
	output wire  s_axi_bvalid,
	input wire  s_axi_bready,
	// S_AXI_R
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
	input wire [7 : 0] s_axi_arlen,
	input wire [2 : 0] s_axi_arsize,
	input wire [1 : 0] s_axi_arburst,
	input wire  s_axi_arlock,
	input wire [3 : 0] s_axi_arcache,
	input wire [2 : 0] s_axi_arprot,
	input wire [3 : 0] s_axi_arqos,
	input wire  s_axi_arvalid,
	output wire  s_axi_arready,
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
	output wire [1 : 0] s_axi_rresp,
	output wire  s_axi_rlast,
	output wire  s_axi_rvalid,
	input wire  s_axi_rready
);
	assign m_axi_awaddr = s_axi_awaddr;
	assign m_axi_awlen = s_axi_awlen;
	assign m_axi_awsize = s_axi_awsize;
	assign m_axi_awburst = s_axi_awburst;
	assign m_axi_awlock = s_axi_awlock;
	assign m_axi_awcache = s_axi_awcache;
	assign m_axi_awprot = s_axi_awprot;
	assign m_axi_awqos = s_axi_awqos;
	assign m_axi_awvalid = s_axi_awvalid;
	assign s_axi_awready = m_axi_awready;
	assign m_axi_wdata = s_axi_wdata;
	assign m_axi_wstrb = s_axi_wstrb;
	assign m_axi_wlast = s_axi_wlast;
	assign m_axi_wvalid = s_axi_wvalid;
	assign s_axi_wready = m_axi_wready;
	assign s_axi_bresp = m_axi_bresp;
	assign s_axi_bvalid = m_axi_bvalid;
	assign m_axi_bready = s_axi_bready;
	// M_AXI_R
	assign m_axi_araddr = s_axi_araddr;
	assign m_axi_arlen = s_axi_arlen;
	assign m_axi_arsize = s_axi_arsize;
	assign m_axi_arburst = s_axi_arburst;
	assign m_axi_arlock = s_axi_arlock;
	assign m_axi_arcache = s_axi_arcache;
	assign m_axi_arprot = s_axi_arprot;
	assign m_axi_arqos = s_axi_arqos;
	assign m_axi_arvalid = s_axi_arvalid;
	assign s_axi_arready = m_axi_arready;
	assign s_axi_rdata = m_axi_rdata;
	assign s_axi_rresp = m_axi_rresp;
	assign s_axi_rlast = m_axi_rlast;
	assign s_axi_rvalid = m_axi_rvalid;
	assign m_axi_rready = s_axi_rready;

endmodule
