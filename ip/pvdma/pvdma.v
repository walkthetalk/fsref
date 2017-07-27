
`timescale 1 ns / 1 ps

module pvdma #
(
	// Users to add parameters here
	parameter integer C_PIXEL_WIDTH	= 8,
	parameter integer C_IMG_WH_WIDTH = 12,
	// User parameters ends

	// Parameters of Axi Master Bus Interface M_AXI
	parameter integer C_M_AXI_BURST_LEN	= 16,
	parameter integer C_M_AXI_ID_WIDTH	= 1,
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M_AXI_DATA_WIDTH	= 32
)
(
	// Users to add ports here
	input wire  clk,
	input wire  resetn,

	input wire [C_M_AXI_DATA_WIDTH/C_PIXEL_WIDTH*(C_PIXEL_WIDTH+2)-1 : 0] rd_data,
	input wire empty,
	output wire rd_en,

	input wire full,
	output wire [C_M_AXI_DATA_WIDTH/C_PIXEL_WIDTH*(C_PIXEL_WIDTH+2)-1 : 0] wr_data,
	output wire wr_en,

	output wire w_sof,
	input wire [C_M_AXI_ADDR_WIDTH-1:0] w_addr,
	output wire r_sof,
	input wire [C_M_AXI_ADDR_WIDTH-1:0] r_addr,

	input wire [C_IMG_WH_WIDTH-1:0] img_width,
	input wire [C_IMG_WH_WIDTH-1:0] img_height,

	// User ports ends
	// Do not modify the ports beyond this line

	// Ports of Axi Master Bus Interface M_AXI
	output wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_awid,
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
	input wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_bid,
	input wire [1 : 0] m_axi_bresp,
	input wire  m_axi_bvalid,
	output wire  m_axi_bready,

	output wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_arid,
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
	input wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_rid,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
	input wire [1 : 0] m_axi_rresp,
	input wire  m_axi_rlast,
	input wire  m_axi_rvalid,
	output wire  m_axi_rready
);

// Instantiation of Axi Bus Interface M_AXI_W

	wire s_rd_sof;
	wire [C_M_AXI_DATA_WIDTH-1 : 0] s_rd_data;
	wire s_empty;
	wire s_rd_en;

	assign s_rd_sof = rd_data[8];
	assign s_empty = empty;
	assign rd_en = s_rd_en;
	localparam C_PM1 = C_PIXEL_WIDTH - 1;
	localparam C_PP1 = C_PIXEL_WIDTH + 1;
	localparam C_PP2 = C_PIXEL_WIDTH + 2;
	genvar i;
	generate
		for (i = 0; i < C_M_AXI_DATA_WIDTH/8; i = i+1) begin: single_pixel
			assign s_rd_data[i*C_PIXEL_WIDTH + C_PM1 : i*C_PIXEL_WIDTH] = rd_data[i*C_PP2 + C_PM1 : i*C_PP2];
		end
	endgenerate

	PVDMA_M_AXI_W # (
		.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
	) PVDMA_M_AXI_W_inst (
		.sof(s_rd_sof),
		.din(s_rd_data),
		.empty(s_empty),
		.rd_en(s_rd_en),

		.frame_pulse(w_sof),
		.base_addr(w_addr),

		.M_AXI_ACLK(clk),
		.M_AXI_ARESETN(resetn),
		.M_AXI_AWID(m_axi_awid),
		.M_AXI_AWADDR(m_axi_awaddr),
		.M_AXI_AWLEN(m_axi_awlen),
		.M_AXI_AWSIZE(m_axi_awsize),
		.M_AXI_AWBURST(m_axi_awburst),
		.M_AXI_AWLOCK(m_axi_awlock),
		.M_AXI_AWCACHE(m_axi_awcache),
		.M_AXI_AWPROT(m_axi_awprot),
		.M_AXI_AWQOS(m_axi_awqos),
		.M_AXI_AWVALID(m_axi_awvalid),
		.M_AXI_AWREADY(m_axi_awready),
		.M_AXI_WDATA(m_axi_wdata),
		.M_AXI_WSTRB(m_axi_wstrb),
		.M_AXI_WLAST(m_axi_wlast),
		.M_AXI_WVALID(m_axi_wvalid),
		.M_AXI_WREADY(m_axi_wready),
		.M_AXI_BID(m_axi_bid),
		.M_AXI_BRESP(m_axi_bresp),
		.M_AXI_BVALID(m_axi_bvalid),
		.M_AXI_BREADY(m_axi_bready)
	);


// Instantiation of Axi Bus Interface M_AXI_R
	wire s_wr_sof;
	wire s_wr_eol;
	wire [C_M_AXI_DATA_WIDTH-1 : 0] s_wr_data;
	wire s_wr_en;
	wire s_full;

	assign wr_en = s_wr_en;
	assign s_full = full;
	generate
		for (i = 0; i < C_M_AXI_DATA_WIDTH/8; i = i+1) begin: wr_pixel
			assign wr_data[i*C_PP2+C_PM1 : i*C_PP2] = s_wr_data[i*C_PIXEL_WIDTH+C_PM1:i*C_PIXEL_WIDTH];
		end
		assign wr_data[C_PIXEL_WIDTH] = s_wr_sof;
		for (i = 1; i < C_M_AXI_DATA_WIDTH/8; i = i+1) begin: wr_sof
			assign wr_data[i*C_PP2+C_PIXEL_WIDTH] = 1'b0;
		end
		for (i = 0; i < (C_M_AXI_DATA_WIDTH/8-1); i = i+1) begin: wr_eol
			assign wr_data[i*C_PP2+C_PP1] = 1'b0;
		end
		assign wr_data[C_M_AXI_DATA_WIDTH/C_PIXEL_WIDTH*C_PP2-1] = s_wr_eol;
	endgenerate

	PVDMA_M_AXI_R # (
		.C_PIXEL_WIDTH(C_PIXEL_WIDTH),

		.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
	) PVDMA_M_AXI_R_inst (
		.sof(s_wr_sof),
		.eol(s_wr_eol),
		.dout(s_wr_data),
		.wr_en(s_wr_en),
		.full(s_full),

		.frame_pulse(r_sof),
		.base_addr(r_addr),

		.M_AXI_ACLK(clk),
		.M_AXI_ARESETN(resetn),
		.M_AXI_ARID(m_axi_arid),
		.M_AXI_ARADDR(m_axi_araddr),
		.M_AXI_ARLEN(m_axi_arlen),
		.M_AXI_ARSIZE(m_axi_arsize),
		.M_AXI_ARBURST(m_axi_arburst),
		.M_AXI_ARLOCK(m_axi_arlock),
		.M_AXI_ARCACHE(m_axi_arcache),
		.M_AXI_ARPROT(m_axi_arprot),
		.M_AXI_ARQOS(m_axi_arqos),
		.M_AXI_ARVALID(m_axi_arvalid),
		.M_AXI_ARREADY(m_axi_arready),
		.M_AXI_RID(m_axi_rid),
		.M_AXI_RDATA(m_axi_rdata),
		.M_AXI_RRESP(m_axi_rresp),
		.M_AXI_RLAST(m_axi_rlast),
		.M_AXI_RVALID(m_axi_rvalid),
		.M_AXI_RREADY(m_axi_rready)
	);

	// Add user logic here

	// User logic ends

endmodule
