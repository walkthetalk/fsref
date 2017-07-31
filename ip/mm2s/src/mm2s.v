`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: mm2s
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
module mm2s #
(
	// Users to add parameters here
	parameter integer C_PIXEL_WIDTH	= 8,
	parameter integer C_IMG_WBITS	= 12,
	parameter integer C_IMG_HBITS	= 12,
	// User parameters ends

	// Parameters of Axi Master Bus Interface M_AXI
	parameter integer C_M_AXI_BURST_LEN	= 16,
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M_AXI_DATA_WIDTH	= 32
)
(
	input wire  resetn,

	input wire soft_reset,
	output wire resetting,
/// mm to fifo
	input wire m2f_aclk,

	input wire [C_IMG_WBITS-1:0] img_width,
	input wire [C_IMG_HBITS-1:0] img_height,

	input wire fsync,

	output wire r_sof,
	input wire [C_M_AXI_ADDR_WIDTH-1:0] r_addr,

	// Ports of Axi Master Bus Interface M_AXI
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

	input wire mm2s_full,
	output wire [C_M_AXI_DATA_WIDTH/C_PIXEL_WIDTH*(C_PIXEL_WIDTH+2)-1 : 0] mm2s_wr_data,
	output wire mm2s_wr_en,

/// fifo to stream
	input wire f2s_aclk,

	input wire	mm2s_empty,
	input wire [C_PIXEL_WIDTH+1 : 0] mm2s_rd_data,
	output wire	mm2s_rd_en,

	output wire m_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire m_axis_tuser,
	output wire m_axis_tlast,
	input wire m_axis_tready
);

	localparam C_PM1 = C_PIXEL_WIDTH - 1;
	localparam C_PP1 = C_PIXEL_WIDTH + 1;
	localparam C_PP2 = C_PIXEL_WIDTH + 2;

// mm to fifo
	/// use m2f_aclk
	wire [C_M_AXI_DATA_WIDTH-1 : 0] mm2s_pixel_data;

	generate
		genvar i;
		for (i = 0; i < C_M_AXI_DATA_WIDTH/C_PIXEL_WIDTH; i = i+1) begin: wr_pixel
			assign mm2s_wr_data[i*C_PP2+C_PM1 : i*C_PP2] = mm2s_pixel_data[i*C_PIXEL_WIDTH+C_PM1:i*C_PIXEL_WIDTH];
		end
		for (i = 1; i < C_M_AXI_DATA_WIDTH/C_PIXEL_WIDTH; i = i+1) begin: wr_sof
			assign mm2s_wr_data[i*C_PP2+C_PIXEL_WIDTH] = 1'b0;
		end
		for (i = 0; i < (C_M_AXI_DATA_WIDTH/C_PIXEL_WIDTH-1); i = i+1) begin: wr_eol
			assign mm2s_wr_data[i*C_PP2+C_PP1] = 1'b0;
		end
	endgenerate

	MM2FIFO # (
		.C_PIXEL_WIDTH(C_PIXEL_WIDTH),

		.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
		.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
	) read4mm_inst (
		.img_width(img_width),
		.img_height(img_height),

		.soft_reset(soft_reset),
		.resetting(resetting),
		.fsync(fsync),

		.sof(mm2s_wr_data[C_PIXEL_WIDTH]),
		.eol(mm2s_wr_data[C_M_AXI_DATA_WIDTH-1]),
		.dout(mm2s_pixel_data),
		.wr_en(mm2s_wr_en),
		.full(mm2s_full),

		.frame_pulse(r_sof),
		.base_addr(r_addr),

		.M_AXI_ACLK(m2f_aclk),
		.M_AXI_ARESETN(resetn),
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
		.M_AXI_RDATA(m_axi_rdata),
		.M_AXI_RRESP(m_axi_rresp),
		.M_AXI_RLAST(m_axi_rlast),
		.M_AXI_RVALID(m_axi_rvalid),
		.M_AXI_RREADY(m_axi_rready)
	);

// FIFO to stream
	/// use f2s_aclk
	reg mm2s_dvalid;
	assign m_axis_tdata = mm2s_rd_data[C_PIXEL_WIDTH-1:0];
	assign m_axis_tuser = mm2s_rd_data[C_PIXEL_WIDTH];
	assign m_axis_tlast = mm2s_rd_data[C_PIXEL_WIDTH+1];
	assign m_axis_tvalid = mm2s_dvalid;
	assign mm2s_rd_en = (~m_axis_tvalid | m_axis_tready) & ~mm2s_empty;
	always @(posedge f2s_aclk) begin
		if (resetn == 1'b0) begin
			mm2s_dvalid <= 0;
		end
		else if (mm2s_rd_en) begin
			mm2s_dvalid <= 1;
		end
		else if (m_axis_tready) begin
			mm2s_dvalid <= 0;
		end
		else begin
			mm2s_dvalid <= mm2s_dvalid;
		end
	end
endmodule
