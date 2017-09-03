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
	input wire fsync,

	input wire [C_IMG_WBITS-1 : 0] col_idx,
	input wire col_update,
	input wire [C_IMG_HBITS-1 : 0] row_idx,
	input wire row_update,

	input wire [C_IMG_WBITS-1 : 0] s_win_left,
	input wire [C_IMG_HBITS-1 : 0] s_win_top,
	input wire [C_IMG_WBITS-1 : 0] s_win_width,
	input wire [C_IMG_HBITS-1 : 0] s_win_height,

	output wire s_need
);
/// only for m_axis_need, can be split out.
	reg col_need;
	reg row_need;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || fsync)
			col_need <= 0;
		else if (col_update) begin
			if (col_idx == s_win_left + s_win_width)
				col_need <= 0;
			else if (col_idx == s_win_left)
				col_need <= 1;
			else
				col_need <= col_need;
		end
		else
			col_need <= col_need;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0 || fsync)
			row_need <= 0;
		else if (row_update) begin
			if (row_idx == s_win_top + s_win_height)
				row_need <= 0;
			else if (row_idx == s_win_top)
				row_need <= 1;
			else
				row_need <= row_need;
		end
		else
			row_need <= row_need;
	end

	assign s_need = (col_need && row_need);

endmodule
