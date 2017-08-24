`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: axis_shifter
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
module axis_shifter #
(
	parameter integer C_PIXEL_WIDTH	= 8,
	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12
)
(
	input wire clk,
	input wire resetn,

	input wire [C_IMG_WBITS-1 : 0] col_idx,
	input wire [C_IMG_HBITS-1 : 0] row_idx,

	input wire [C_IMG_WBITS-1 : 0] s_win_left,
	input wire [C_IMG_HBITS-1 : 0] s_win_top,
	input wire [C_IMG_WBITS-1 : 0] s_win_width,
	input wire [C_IMG_HBITS-1 : 0] s_win_height,

	/// S0_AXIS
	input  wire s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire s_axis_tuser,
	input  wire s_axis_tlast,
	output wire s_axis_tready,

	/// M_AXIS
	output wire m_axis_need,
	output reg m_axis_valid,
	output reg  [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	input  wire m_axis_next
);
	assign m_axis_need = (s_win_left <= col_idx && col_idx < s_win_left + s_win_width)
			&& (s_win_top <= row_idx && row_idx < s_win_top + s_win_height);
	wire s_ds_ready;
	assign s_ds_ready = (m_axis_need && m_axis_next);
	wire s_next;
	assign s_next = s_axis_tvalid && s_axis_tready;
	assign s_axis_tready = (~m_axis_valid | s_ds_ready);

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_valid <= 0;
		else if (s_next)
			m_axis_valid <= 1;
		else if (s_ds_ready)
			m_axis_valid <= 0;
		else
			m_axis_valid <= m_axis_valid;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tdata <= 0;
		else if (s_next)
			m_axis_tdata <= s_axis_tdata;
		else
			m_axis_tdata <= m_axis_tdata;
	end

endmodule
