`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: axis_window
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
module axis_window #
(
	parameter integer C_PIXEL_WIDTH	= 8,
	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12
)
(
	input wire clk,
	input wire resetn,

	input wire [C_IMG_WBITS-1 : 0] win_left,
	input wire [C_IMG_HBITS-1 : 0] win_top,

	input wire [C_IMG_WBITS-1 : 0] win_width,
	input wire [C_IMG_HBITS-1 : 0] win_height,

	/// S_AXIS
	input  wire s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire s_axis_tuser,
	input  wire s_axis_tlast,
	output wire s_axis_tready,

	/// M_AXIS
	output wire  m_axis_tvalid,
	output wire  [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire  m_axis_tuser,
	output wire  m_axis_tlast,
	input  wire  m_axis_tready
);
	reg gap0;
	reg gap1;
	reg streaming;

	reg [C_PIXEL_WIDTH-1:0] idata;
	///reg iuser;
	reg ilast;
	reg ivalid;
	wire iready;
	wire inext;
	assign inext = ivalid && iready;
	assign s_axis_tready = (streaming && ~ilast) && (~ivalid || iready);

	wire mnext;
	assign mnext = m_axis_tvalid && m_axis_tready;
	wire snext;
	assign snext = s_axis_tvalid && s_axis_tready;

	always @(posedge clk) begin
		if (resetn == 1'b0)
			gap0 <= 0;
		else if (~streaming && ~gap0 && s_axis_tvalid)
			gap0 <= 1;
		else
			gap0 <= 0;
	end
	always @(posedge clk) begin
		if (resetn == 1'b0)
			gap1 <= 0;
		else
			gap1 <= gap0;
	end
	always @(posedge clk) begin
		if (resetn == 1'b0)
			streaming <= 0;
		else if (gap0)
			streaming <= 1;
		else if (inext && ilast)
			streaming <= 0;
		else
			streaming <= streaming;
	end
	always @(posedge clk) begin
		if (resetn == 1'b0 || gap0) begin
			idata <= 0;
			///iuser <= 0;
			ilast <= 0;
		end
		else if (snext) begin
			idata <= s_axis_tdata;
			///iuser <= s_axis_tuser;
			ilast <= s_axis_tlast;
		end
	end

	/**
	 * @NTOE: ensure the first 'col_update' of every line is at same clock
	 *        as corresponding row_update, i.e. the first clock of 'streaming'
	 */
	reg [C_IMG_WBITS-1 : 0] col_idx;
	reg [C_IMG_HBITS-1 : 0] row_idx;
	reg [C_IMG_WBITS-1 : 0] col_idx_bak;
	reg [C_IMG_HBITS-1 : 0] row_idx_bak;
	wire col_update;
	assign col_update = snext;
	wire row_update;
	assign row_update = gap1;
	wire fsync;
	assign fsync = gap0 && s_axis_tuser;
	wire lsync;
	assign lsync = gap0;

	always @ (posedge clk) begin
		if (resetn == 1'b0 || lsync) begin
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
		if (resetn == 1'b0 || fsync) begin
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

	wire s_need;

	axis_shifter_v2 # (
		.C_PIXEL_WIDTH(C_PIXEL_WIDTH),
		.C_IMG_WBITS(C_IMG_WBITS),
		.C_IMG_HBITS(C_IMG_HBITS)
	) axis_shifter_0 (
		.clk(clk),
		.resetn(resetn),
		.fsync(fsync),
		.lsync(lsync),

		.col_idx(col_idx),
		.col_idx_next(col_idx_bak),
		.col_update(col_update),
		.row_idx(row_idx),
		///.row_idx_next(row_idx_bak),
		.row_update(row_update),

		.s_win_left(win_left),
		.s_win_top(win_top),
		.s_win_width(win_width),
		.s_win_height(win_height),

		.s_need(s_need),
		.s_sof(m_axis_tuser),
		.s_eol(m_axis_tlast)
	);

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			ivalid <= 0;
		else if (snext)
			ivalid <= 1;
		else if (mnext)
			ivalid <= 0;
		else
			ivalid <= ivalid;
	end

	assign iready = ~s_need || m_axis_tready;
	assign m_axis_tvalid = s_need && ivalid;
	assign m_axis_tdata = idata;

endmodule
