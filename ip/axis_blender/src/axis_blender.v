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
	parameter integer C_IMG_HBITS = 12,
	parameter integer C_TEST = 0

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
	output reg m_axis_tvalid,
	output reg [C_M_PIXEL_WIDTH-1:0] m_axis_tdata,
	output reg m_axis_tuser,
	output reg m_axis_tlast,
	input  wire m_axis_tready
);
	wire out_tvalid;
	reg out_tuser;
	wire out_tlast;
	wire out_tready;

	wire mnext;
	assign mnext = out_tvalid && m_axis_tready;

	reg [C_IMG_WBITS-1 : 0] col_idx_bak;
	reg [C_IMG_HBITS-1 : 0] row_idx_bak;
	reg [C_IMG_WBITS-1 : 0] col_idx;
	reg [C_IMG_HBITS-1 : 0] row_idx;

	reg last_pixel;
	reg last_line;
	reg gap0;
	reg gap1;
	reg streaming;
	wire col_update;
	assign col_update = (gap1 || mnext);
	wire row_update;
	assign row_update = gap1;
	wire fsync;
	assign fsync = (last_line && gap0);

	always @(posedge clk) begin
		if (resetn == 1'b0)
			last_pixel <= 0;
		else if (col_update)
			last_pixel <= (col_idx_bak == out_width);
		else
			last_pixel <= last_pixel;
	end
	always @(posedge clk) begin
		if (resetn == 1'b0)
			last_line <= 0;
		else if (row_update)
			last_line <= (row_idx_bak == out_height);
		else
			last_line <= last_line;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)
			gap0 <= 0;
		else if (~gap0) begin
			if (~gap1 && ~streaming)
				gap0 <= (~last_line ? 1 : (s0_axis_tvalid && s0_axis_tuser));
			/// @NOTE: just for saving resource (add one more empty clock cycle between lines)
			//else if (mnext && last_pixel)
			//	gap0 <= (~last_line ? 1 : (s0_axis_tvalid && s0_axis_tuser));
			else
				gap0 <= 0;
		end
		else
			gap0 <= 0;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			gap1 <= 0;
		else
			gap1 <= gap0;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)
			streaming <= 0;
		else if (row_update)
			streaming <= 1;
		else if (mnext && last_pixel)
			streaming <= 0;
		else
			streaming <= streaming;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0 || gap0) begin
			col_idx <= 0;
			col_idx_bak <= 1;
		end
		else if (col_update) begin
			col_idx <= col_idx_bak;
			col_idx_bak <= col_idx_bak + 1;
		end
		else begin
			col_idx <= col_idx;
			col_idx_bak <= col_idx_bak;
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0 || (gap0 && last_line)) begin
			row_idx <= 0;
			row_idx_bak <= 1;
		end
		else if (row_update) begin
			row_idx <= row_idx_bak;
			row_idx_bak <= row_idx_bak + 1;
		end
		else begin
			row_idx <= row_idx;
			row_idx_bak <= row_idx_bak;
		end
	end

/// stream 0
	wire s0_valid;
	assign s0_valid = s0_axis_tvalid;
	wire s0_need;
	wire[C_S0_PIXEL_WIDTH-1:0] s0_data;
	assign s0_data = s0_axis_tdata;
	assign s0_axis_tready = mnext && s0_need;

	axis_shifter # (
		.C_PIXEL_WIDTH(C_S0_PIXEL_WIDTH),
		.C_IMG_WBITS(C_IMG_WBITS),
		.C_IMG_HBITS(C_IMG_HBITS)
	) axis_shifter_0 (
		.clk(clk),
		.resetn(resetn),
		.fsync(fsync),

		.col_idx(col_idx),
		.col_update(col_update),
		.row_idx(row_idx),
		.row_update(row_update),

		.s_win_left(s0_win_left),
		.s_win_top(s0_win_top),
		.s_win_width(s0_win_width),
		.s_win_height(s0_win_height),

		.s_need(s0_need)
	);

/// stream 1
	wire s1_valid;
	assign s1_valid = s1_axis_tvalid;
	wire s1_need;
	wire[7:0] s1_data;
	assign s1_data = s1_axis_tdata[C_S1_PIXEL_WIDTH-1:C_S1_PIXEL_WIDTH-8];
	assign s1_axis_tready = mnext && s1_need;

	axis_shifter # (
		.C_PIXEL_WIDTH(C_S1_PIXEL_WIDTH),
		.C_IMG_WBITS(C_IMG_WBITS),
		.C_IMG_HBITS(C_IMG_HBITS)
	) axis_shifter_1 (
		.clk(clk),
		.resetn(resetn),
		.fsync(fsync),

		.col_idx(col_idx),
		.col_update(col_update),
		.row_idx(row_idx),
		.row_update(row_update),

		.s_win_left(s1_win_left),
		.s_win_top(s1_win_top),
		.s_win_width(s1_win_width),
		.s_win_height(s1_win_height),

		.s_need(s1_need)
	);

/// stream 2
	wire s2_valid;
	assign s2_valid = s2_axis_tvalid;
	wire s2_need;
	wire[7:0] s2_data;
	assign s2_data = s2_axis_tdata[C_S2_PIXEL_WIDTH-1:C_S2_PIXEL_WIDTH-8];
	assign s2_axis_tready = mnext && s2_need;

	axis_shifter # (
		.C_PIXEL_WIDTH(C_S2_PIXEL_WIDTH),
		.C_IMG_WBITS(C_IMG_WBITS),
		.C_IMG_HBITS(C_IMG_HBITS)
	) axis_shifter_2 (
		.clk(clk),
		.resetn(resetn),
		.fsync(fsync),

		.col_idx(col_idx),
		.col_update(col_update),
		.row_idx(row_idx),
		.row_update(row_update),

		.s_win_left(s2_win_left),
		.s_win_top(s2_win_top),
		.s_win_width(s2_win_width),
		.s_win_height(s2_win_height),

		.s_need(s2_need)
	);
/// m
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			out_tuser <= 0;
		else if (col_update)
			out_tuser <= (col_idx == 0 && row_idx == 0);
		else
			out_tuser <= out_tuser;
	end
	assign out_tlast = last_pixel;
	assign out_tvalid = (~s0_need || s0_valid)
	 		&& (~s1_need || s1_valid)
			&& (~s2_need || s2_valid)
			&& streaming;
	//assign out_tdata = s0_data;
	assign out_tready = (~m_axis_tvalid || m_axis_tready);

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

	wire [7:0] data_12;
	assign data_12 = (order_1over2 ?
		 	(s1_need ? s1_data : s2_data) :
			(s2_need ? s2_data : s1_data));

	wire[7:0] alpha;
	assign alpha = s0_data[31:24];

`define ALPHA(A, B) (A > B ? (B + (((A-B) * alpha) >> 8)) : (B - (((B-A) * alpha) >> 8)))

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tdata <= 0;
		else if (mnext)
			if (s1_need || s2_need) begin
				if (C_TEST) begin
					if (s1_need)
						m_axis_tdata <= {s1_data, s1_data, s1_data};
					else
						m_axis_tdata <= s0_data;
				end
				else begin
					m_axis_tdata[23:16] <= `ALPHA(s0_data[23:16], data_12);
					m_axis_tdata[15: 8] <= `ALPHA(s0_data[15: 8], data_12);
					m_axis_tdata[ 7: 0] <= `ALPHA(s0_data[ 7: 0], data_12);
				end
			end
			else
				m_axis_tdata <= s0_data;
		else
			m_axis_tdata <= m_axis_tdata;
	end

endmodule
