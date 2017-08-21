`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: axis_blender
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
module axis_blender #
(
	parameter integer C_S0_PIXEL_WIDTH	= 32,
	parameter integer C_S1_PIXEL_WIDTH	= 8,
	parameter integer C_S2_PIXEL_WIDTH	= 8,
	parameter integer C_M_PIXEL_WIDTH	= 24,
	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12
)
(
	input wire clk,
	input wire resetn,

	input wire order_1over2,

	input wire [C_IMG_WBITS-1 : 0] out_width,
	input wire [C_IMG_HBITS-1 : 0] out_height,

	/// S0_AXIS
	input  wire s0_axis_tvalid,
	input  wire [C_S0_PIXEL_WIDTH-1:0] s0_axis_tdata,
	input  wire s0_axis_tuser,
	input  wire s0_axis_tlast,
	output wire s0_axis_tready,

	input wire [C_IMG_WBITS-1 : 0] s0_win_left,
	input wire [C_IMG_HBITS-1 : 0] s0_win_top,
	input wire [C_IMG_WBITS-1 : 0] s0_win_width,
	input wire [C_IMG_HBITS-1 : 0] s0_win_height,

	/// S1_AXIS
	input  wire s1_axis_tvalid,
	input  wire [C_S1_PIXEL_WIDTH-1:0] s1_axis_tdata,
	input  wire s1_axis_tuser,
	input  wire s1_axis_tlast,
	output wire s1_axis_tready,

	input wire [C_IMG_WBITS-1 : 0] s1_win_left,
	input wire [C_IMG_HBITS-1 : 0] s1_win_top,
	input wire [C_IMG_WBITS-1 : 0] s1_win_width,
	input wire [C_IMG_HBITS-1 : 0] s1_win_height,

	/// S2_AXIS
	input  wire s2_axis_tvalid,
	input  wire [C_S2_PIXEL_WIDTH-1:0] s2_axis_tdata,
	input  wire s2_axis_tuser,
	input  wire s2_axis_tlast,
	output wire s2_axis_tready,

	input wire [C_IMG_WBITS-1 : 0] s2_win_left,
	input wire [C_IMG_HBITS-1 : 0] s2_win_top,
	input wire [C_IMG_WBITS-1 : 0] s2_win_width,
	input wire [C_IMG_HBITS-1 : 0] s2_win_height,

	/// M_AXIS
	output wire m_axis_tvalid,
	output wire [C_M_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire m_axis_tuser,
	output wire m_axis_tlast,
	input  wire m_axis_tready
);
	wire out_tvalid;
	wire out_tuser;
	wire out_tlast;
	wire out_tready;

	wire mnext;
	assign mnext = out_tvalid && out_tready;

	/// next pixel row/col index
	reg [C_IMG_WBITS-1 : 0] col_idx;
	reg [C_IMG_HBITS-1 : 0] row_idx;
	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			col_idx <= 0;
			row_idx <= 0;
		end
		else if (mnext) begin
			if (col_idx != out_width - 1) begin
				col_idx <= col_idx + 1;
				row_idx <= row_idx;
			end
			else if (row_idx != out_height - 1) begin
				col_idx <= 0;
				row_idx <= row_idx + 1;
			end
			else begin
				col_idx <= 0;
				row_idx <= 0;
			end
		end
		else begin
			col_idx <= col_idx;
			row_idx <= row_idx;
		end
	end

	wire s0_valid;
	wire s0_need;
	wire[C_S0_PIXEL_WIDTH-1:0] s0_data;

	axis_shifter # (
		.C_PIXEL_WIDTH(C_S0_PIXEL_WIDTH),
		.C_IMG_WBITS(C_IMG_WBITS),
		.C_IMG_HBITS(C_IMG_HBITS)
	) axis_shifter_0 (
		.clk(clk),
		.resetn(resetn),
		.col_idx(col_idx),
		.row_idx(row_idx),

		.s_axis_tvalid(s0_axis_tvalid),
		.s_axis_tdata(s0_axis_tdata),
		.s_axis_tuser(s0_axis_tuser),
		.s_axis_tlast(s0_axis_tlast),
		.s_axis_tready(s0_axis_tready),

		.s_win_left(s0_win_left),
		.s_win_top(s0_win_top),
		.s_win_width(s0_win_width),
		.s_win_height(s0_win_height),

		.m_axis_need(s0_need),
		.m_axis_valid(s0_valid),
		.m_axis_tdata(s0_data),
		.m_axis_next(mnext)
	);

	wire s1_valid;
	wire s1_need;
	wire[C_S1_PIXEL_WIDTH-1:0] s1_data;

	axis_shifter # (
		.C_PIXEL_WIDTH(C_S1_PIXEL_WIDTH),
		.C_IMG_WBITS(C_IMG_WBITS),
		.C_IMG_HBITS(C_IMG_HBITS)
	) axis_shifter_1 (
		.clk(clk),
		.resetn(resetn),
		.col_idx(col_idx),
		.row_idx(row_idx),

		.s_axis_tvalid(s1_axis_tvalid),
		.s_axis_tdata(s1_axis_tdata),
		.s_axis_tuser(s1_axis_tuser),
		.s_axis_tlast(s1_axis_tlast),
		.s_axis_tready(s1_axis_tready),

		.s_win_left(s1_win_left),
		.s_win_top(s1_win_top),
		.s_win_width(s1_win_width),
		.s_win_height(s1_win_height),

		.m_axis_need(s1_need),
		.m_axis_valid(s1_valid),
		.m_axis_tdata(s1_data),
		.m_axis_next(mnext)
	);

	wire s2_valid;
	wire s2_need;
	wire[C_S2_PIXEL_WIDTH-1:0] s2_data;

	axis_shifter # (
		.C_PIXEL_WIDTH(C_S2_PIXEL_WIDTH),
		.C_IMG_WBITS(C_IMG_WBITS),
		.C_IMG_HBITS(C_IMG_HBITS)
	) axis_shifter_2 (
		.clk(clk),
		.resetn(resetn),
		.col_idx(col_idx),
		.row_idx(row_idx),

		.s_axis_tvalid(s2_axis_tvalid),
		.s_axis_tdata(s2_axis_tdata),
		.s_axis_tuser(s2_axis_tuser),
		.s_axis_tlast(s2_axis_tlast),
		.s_axis_tready(s2_axis_tready),

		.s_win_left(s2_win_left),
		.s_win_top(s2_win_top),
		.s_win_width(s2_win_width),
		.s_win_height(s2_win_height),

		.m_axis_need(s2_need),
		.m_axis_valid(s2_valid),
		.m_axis_tdata(s2_data),
		.m_axis_next(mnext)
	);
/// m
	assign out_tuser = (col_idx == 0 && row_idx == 0);
	assign out_tlast = (col_idx == out_width - 1);
	assign out_tvalid = (~s0_need || s0_valid)
	 		&& (~s1_need || s1_valid)
			&& (~s2_need || s2_valid);
	//assign out_tdata = s0_data;
	assign out_tready = (~out_tvalid || m_axis_tready);

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tuser <= 0;
		else if (mnext)
			m_axis_tuser <= out_tuser;
		else
			m_axis_tuser <= m_axis_tuser;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tlast <= 0;
		else if (mnext)
			m_axis_tlast <= out_tlast;
		else
			m_axis_tlast <= m_axis_tlast;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tvalid <= 0;
		else if (mnext)
			m_axis_tvalid <= 1;
		else if (m_axis_tready)
			m_axis_tvalid <= 0;
		else
			m_axis_tvalid <= m_axis_tvalid;
	end

	wire [7:0] data1_shrink;
	assign data1_shrink = s1_data[C_S1_PIXEL_WIDTH-1:C_S1_PIXEL_WIDTH-8];
	wire [7:0] data2_shrink;
	assign data2_shrink = s1_data[C_S2_PIXEL_WIDTH-1:C_S2_PIXEL_WIDTH-8];

	wire [7:0] data_12;
	assign data_12 = (order_1over2 ?
		 	(s1_need ? data1_shrink : data2_shrink) :
			(s2_need ? data2_shrink : data1_shrink));

	wire[7:0] alpha;
	assign alpha = s0_data[31:24];

`define ALPHA(A, B) (((B*256 - B) - (A+B) * alpha) >> 8)

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tdata <= 0;
		else if (mnext)
			if (s1_need || s2_need) begin
				m_axis_tdata[23:16] <= `ALPHA(data12, s0_data[23:16]);
				m_axis_tdata[15: 8] <= `ALPHA(data12, s0_data[15: 8]);
				m_axis_tdata[ 7: 0] <= `ALPHA(data12, s0_data[ 7: 0]);
			end
			else
				m_axis_tdata <= s0_data;
		else
			m_axis_tdata <= m_axis_tdata;
	end

endmodule
